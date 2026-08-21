import Foundation

/// Stateful, allocation-free PCM processor shared by voice notes and camera recordings.
/// A separate instance must be used for every audio channel.
public final class VoiceLabProcessor {
    private static let oscillatorTableSize = 4_096
    private static let oscillatorTableMask = oscillatorTableSize - 1
    private static let oscillatorTableScale = Float(oscillatorTableSize) / (2.0 * Float.pi)
    private static let oscillatorTable: [Float] = (0 ..< oscillatorTableSize).map { index in
        sinf(2.0 * Float.pi * Float(index) / Float(oscillatorTableSize))
    }

    private let sampleRate: Float
    private let pitchRatio: Float
    private let pitchEnabled: Bool
    private let tone: Float
    private let toneLowpassAlpha: Float
    private let robotMix: Float
    private let robotPhaseIncrement: Float
    private let gain: Float
    private let privacyAmount: Float
    private let privacyPhaseIncrement: Float
    private let privacyDrive: Float
    private let privacyOutputGain: Float
    private let privacyNoiseGain: Float
    private let pitchDelaySamples: Float

    private var pitchBuffer: [Float]
    private var pitchWriteIndex = 0
    private var pitchPhase: Float = 0.5
    private var pitchSamplesWritten = 0

    private var toneLowpass: Float = 0.0
    private var dcPreviousInput: Float = 0.0
    private var dcPreviousOutput: Float = 0.0
    private var robotPhase: Float
    private var privacyPhase: Float
    private var noiseState: UInt32

    public static func isActive(_ configuration: VoiceLabConfiguration) -> Bool {
        guard configuration.isEnabled else {
            return false
        }
        return abs(configuration.pitchSemitones) > 0.001
            || abs(configuration.tone) > 0.001
            || configuration.robotMix > 0.001
            || abs(configuration.gainDb) > 0.001
            || configuration.preset.hasPrefix("Anonymous")
    }

    public init(configuration: VoiceLabConfiguration, sampleRate: Float) {
        // Warm the shared lookup table before any realtime audio callback uses it.
        _ = Self.oscillatorTable
        let safeSampleRate = min(192_000.0, max(8_000.0, sampleRate))
        self.sampleRate = safeSampleRate
        let pitchSemitones = min(24.0, max(-24.0, configuration.pitchSemitones))
        let pitchRatio = powf(2.0, pitchSemitones / 12.0)
        self.pitchRatio = pitchRatio
        let tone = min(1.0, max(-1.0, configuration.tone))
        self.tone = tone
        self.gain = powf(10.0, min(24.0, max(-24.0, configuration.gainDb)) / 20.0)
        let privacyAmount: Float
        if configuration.preset == "Anonymous Flux" {
            privacyAmount = 0.9
        } else if configuration.preset == "Anonymous Deep" {
            privacyAmount = 0.72
        } else {
            privacyAmount = 0.0
        }
        self.privacyAmount = privacyAmount
        let pitchEnabled = abs(pitchRatio - 1.0) >= 0.001 || privacyAmount > 0.0
        self.pitchEnabled = pitchEnabled

        let toneCutoff: Float = tone < 0.0 ? 1_800.0 : 3_400.0
        self.toneLowpassAlpha = 1.0 - expf(-2.0 * Float.pi * toneCutoff / safeSampleRate)
        self.robotMix = min(0.92, max(0.0, configuration.robotMix) + privacyAmount * 0.22)
        let robotFrequency: Float = privacyAmount > 0.8 ? 91.0 : 78.0
        self.robotPhaseIncrement = 2.0 * Float.pi * robotFrequency / safeSampleRate
        self.privacyPhaseIncrement = 2.0 * Float.pi * (privacyAmount > 0.8 ? 2.3 : 1.35) / safeSampleRate
        self.privacyDrive = 1.0 + privacyAmount * 2.6
        self.privacyOutputGain = 0.88 + privacyAmount * 0.08
        self.privacyNoiseGain = privacyAmount * 0.004
        self.robotPhase = Float.random(in: 0.0 ..< (2.0 * Float.pi))
        self.privacyPhase = Float.random(in: 0.0 ..< (2.0 * Float.pi))
        self.noiseState = UInt32.random(in: 1 ... UInt32.max)

        let pitchDelaySamples = min(8_192.0, max(768.0, safeSampleRate * 0.085))
        self.pitchDelaySamples = pitchDelaySamples
        if pitchEnabled {
            var bufferCount = 1
            let requiredCount = Int(ceil(pitchDelaySamples)) * 2
            while bufferCount < requiredCount {
                bufferCount <<= 1
            }
            self.pitchBuffer = [Float](repeating: 0.0, count: bufferCount)
        } else {
            self.pitchBuffer = [0.0]
        }
    }

    @inline(__always)
    private static func oscillatorSin(phase: Float) -> Float {
        return self.oscillatorTable[Int(phase * self.oscillatorTableScale) & self.oscillatorTableMask]
    }

    @inline(__always)
    private static func normalizedPhaseCos(phase: Float) -> Float {
        let index = Int(phase * Float(self.oscillatorTableSize)) + self.oscillatorTableSize / 4
        return self.oscillatorTable[index & self.oscillatorTableMask]
    }

    @inline(__always)
    private static func fastTanh(_ value: Float) -> Float {
        let x = min(3.0, max(-3.0, value))
        let squared = x * x
        return x * (27.0 + squared) / (27.0 + 9.0 * squared)
    }

    private func delayedSample(delay: Float) -> Float {
        var readPosition = Float(self.pitchWriteIndex) - delay
        let bufferCount = Float(self.pitchBuffer.count)
        if readPosition < 0.0 {
            readPosition += bufferCount * ceilf(-readPosition / bufferCount)
        }
        if readPosition >= bufferCount {
            readPosition -= bufferCount * floorf(readPosition / bufferCount)
        }
        let lowerIndex = Int(readPosition)
        let upperIndex = (lowerIndex + 1) & (self.pitchBuffer.count - 1)
        let fraction = readPosition - Float(lowerIndex)
        return self.pitchBuffer[lowerIndex] * (1.0 - fraction) + self.pitchBuffer[upperIndex] * fraction
    }

    private func processPitch(_ sample: Float) -> Float {
        self.pitchBuffer[self.pitchWriteIndex] = sample

        if abs(self.pitchRatio - 1.0) < 0.001 && self.privacyAmount == 0.0 {
            self.pitchWriteIndex = (self.pitchWriteIndex + 1) & (self.pitchBuffer.count - 1)
            self.pitchSamplesWritten += 1
            return sample
        }

        var secondPhase = self.pitchPhase + 0.5
        if secondPhase >= 1.0 {
            secondPhase -= 1.0
        }
        let timeVariance: Float
        if self.privacyAmount > 0.0 {
            timeVariance = 1.0 + self.privacyAmount * 0.075 * Self.oscillatorSin(phase: self.privacyPhase)
        } else {
            timeVariance = 1.0
        }
        let firstWeight = 0.5 - 0.5 * Self.normalizedPhaseCos(phase: self.pitchPhase)
        let shifted = self.delayedSample(delay: self.pitchPhase * self.pitchDelaySamples * timeVariance) * firstWeight
            + self.delayedSample(delay: secondPhase * self.pitchDelaySamples / timeVariance) * (1.0 - firstWeight)

        self.pitchPhase += (1.0 - self.pitchRatio) / self.pitchDelaySamples
        if self.pitchPhase < 0.0 {
            self.pitchPhase += 1.0
        } else if self.pitchPhase >= 1.0 {
            self.pitchPhase -= 1.0
        }

        self.pitchWriteIndex = (self.pitchWriteIndex + 1) & (self.pitchBuffer.count - 1)
        self.pitchSamplesWritten += 1
        let startup = min(1.0, Float(self.pitchSamplesWritten) / self.pitchDelaySamples)
        return sample * (1.0 - startup) + shifted * startup
    }

    private func processSample(_ input: Float) -> Float {
        var value = input.isFinite ? min(1.0, max(-1.0, input)) : 0.0

        let dcOutput = value - self.dcPreviousInput + 0.995 * self.dcPreviousOutput
        self.dcPreviousInput = value
        self.dcPreviousOutput = dcOutput
        value = self.pitchEnabled ? self.processPitch(dcOutput) : dcOutput

        self.toneLowpass += self.toneLowpassAlpha * (value - self.toneLowpass)
        if self.tone < 0.0 {
            value = value * (1.0 + self.tone) - self.toneLowpass * self.tone
        } else if self.tone > 0.0 {
            value += (value - self.toneLowpass) * self.tone * 1.35
        }

        if self.robotMix > 0.0 {
            let modulated = value * Self.oscillatorSin(phase: self.robotPhase)
            value = value * (1.0 - self.robotMix) + modulated * self.robotMix
            self.robotPhase += self.robotPhaseIncrement
            if self.robotPhase >= 2.0 * Float.pi {
                self.robotPhase -= 2.0 * Float.pi
            }
        }

        if self.privacyAmount > 0.0 {
            self.noiseState = self.noiseState &* 1_664_525 &+ 1_013_904_223
            let noise = Float(Int32(bitPattern: self.noiseState)) / Float(Int32.max)
            value = Self.fastTanh(value * self.privacyDrive) * self.privacyOutputGain
            value += noise * self.privacyNoiseGain
            self.privacyPhase += self.privacyPhaseIncrement
            if self.privacyPhase >= 2.0 * Float.pi {
                self.privacyPhase -= 2.0 * Float.pi
            }
        }

        value *= self.gain
        let magnitude = abs(value)
        if magnitude > 0.92 {
            let limited = 0.92 + 0.08 * Self.fastTanh((magnitude - 0.92) / 0.08)
            value = value < 0.0 ? -limited : limited
        }
        return min(1.0, max(-1.0, value))
    }

    public func processInt16(samples: UnsafeMutablePointer<Int16>, frameCount: Int, stride: Int = 1) {
        guard frameCount > 0, stride > 0 else {
            return
        }
        var index = 0
        for _ in 0 ..< frameCount {
            let value = self.processSample(Float(samples[index]) / 32_768.0)
            samples[index] = Int16((value * 32_767.0).rounded())
            index += stride
        }
    }

    public func processFloat32(samples: UnsafeMutablePointer<Float>, frameCount: Int, stride: Int = 1) {
        guard frameCount > 0, stride > 0 else {
            return
        }
        var index = 0
        for _ in 0 ..< frameCount {
            samples[index] = self.processSample(samples[index])
            index += stride
        }
    }
}
