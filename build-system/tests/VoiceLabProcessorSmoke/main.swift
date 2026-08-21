import Foundation

public struct VoiceLabConfiguration {
    public let isEnabled: Bool
    public let preset: String
    public let pitchSemitones: Float
    public let tone: Float
    public let robotMix: Float
    public let gainDb: Float

    public init(isEnabled: Bool, preset: String, pitchSemitones: Float, tone: Float, robotMix: Float, gainDb: Float) {
        self.isEnabled = isEnabled
        self.preset = preset
        self.pitchSemitones = pitchSemitones
        self.tone = tone
        self.robotMix = robotMix
        self.gainDb = gainDb
    }
}

func require(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() {
        fatalError(message)
    }
}

let sampleRate: Float = 48_000.0
let anonymousConfiguration = VoiceLabConfiguration(
    isEnabled: true,
    preset: "Anonymous Flux",
    pitchSemitones: 5.0,
    tone: 0.18,
    robotMix: 0.38,
    gainDb: -3.0
)
require(VoiceLabProcessor.isActive(anonymousConfiguration), "Anonymous preset must activate Voice Lab")

let frameCount = 9_600
var int16Samples = (0 ..< frameCount).map { index -> Int16 in
    let phase = 2.0 * Float.pi * 220.0 * Float(index) / sampleRate
    return Int16((sinf(phase) * 12_000.0).rounded())
}
let originalInt16Samples = int16Samples
let int16Processor = VoiceLabProcessor(configuration: anonymousConfiguration, sampleRate: sampleRate)
int16Samples.withUnsafeMutableBufferPointer { buffer in
    int16Processor.processInt16(samples: buffer.baseAddress!, frameCount: buffer.count)
}
require(int16Samples != originalInt16Samples, "Int16 Voice Lab output must differ from its input")

let deepConfiguration = VoiceLabConfiguration(
    isEnabled: true,
    preset: "Deep",
    pitchSemitones: -4.0,
    tone: -0.3,
    robotMix: 0.0,
    gainDb: 1.0
)
var int32StereoSamples = [Int32](repeating: 0, count: frameCount * 2)
for frame in 0 ..< frameCount {
    let leftPhase = 2.0 * Float.pi * 180.0 * Float(frame) / sampleRate
    let rightPhase = 2.0 * Float.pi * 440.0 * Float(frame) / sampleRate
    int32StereoSamples[frame * 2] = Int32((sinf(leftPhase) * 900_000_000.0).rounded())
    int32StereoSamples[frame * 2 + 1] = Int32((sinf(rightPhase) * 700_000_000.0).rounded())
}
let originalInt32StereoSamples = int32StereoSamples
let int32Processor = VoiceLabProcessor(configuration: deepConfiguration, sampleRate: sampleRate)
int32StereoSamples.withUnsafeMutableBufferPointer { buffer in
    int32Processor.processInt32(samples: buffer.baseAddress!, frameCount: frameCount, stride: 2)
}
require(stride(from: 0, to: int32StereoSamples.count, by: 2).contains { int32StereoSamples[$0] != originalInt32StereoSamples[$0] }, "Int32 Deep output must change the selected interleaved channel")
require(stride(from: 1, to: int32StereoSamples.count, by: 2).allSatisfy { int32StereoSamples[$0] == originalInt32StereoSamples[$0] }, "Strided Int32 processing must not modify adjacent channels")

var floatSamples = (0 ..< frameCount).map { index -> Float in
    if index == 37 {
        return .nan
    }
    let phase = 2.0 * Float.pi * 330.0 * Float(index) / sampleRate
    return sinf(phase) * 0.4
}
let floatProcessor = VoiceLabProcessor(configuration: anonymousConfiguration, sampleRate: sampleRate)
floatSamples.withUnsafeMutableBufferPointer { buffer in
    floatProcessor.processFloat32(samples: buffer.baseAddress!, frameCount: buffer.count)
}
require(floatSamples.allSatisfy { $0.isFinite && $0 >= -1.0 && $0 <= 1.0 }, "Float32 output must stay finite and normalized")

let neutralConfiguration = VoiceLabConfiguration(
    isEnabled: true,
    preset: "Natural",
    pitchSemitones: 0.0,
    tone: 0.0,
    robotMix: 0.0,
    gainDb: 0.0
)
require(!VoiceLabProcessor.isActive(neutralConfiguration), "Neutral configuration must use the zero-cost bypass")

print("VoiceLabProcessor smoke test passed")
