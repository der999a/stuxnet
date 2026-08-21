import Foundation

final class StuxnetCallAudioRecorder {
    private enum Source {
        case microphone
        case remote
    }

    private let queue = DispatchQueue(label: "org.stuxnet.call-recorder", qos: .utility)
    private let path: String
    private var file: FileHandle?
    private var sampleRate: Int = 0
    private var microphone: [Int16] = []
    private var remote: [Int16] = []
    private var microphoneOffset = 0
    private var remoteOffset = 0
    private var writtenSamples: Int64 = 0
    private var finished = false

    init?() {
        let directory = (NSTemporaryDirectory() as NSString).appendingPathComponent("stuxnet-call-recordings")
        try? FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        self.path = (directory as NSString).appendingPathComponent("Stuxnet_Call_\(formatter.string(from: Date())).wav")
        guard FileManager.default.createFile(atPath: self.path, contents: Data(repeating: 0, count: 44)), let file = FileHandle(forWritingAtPath: self.path) else {
            return nil
        }
        self.file = file
        _ = try? file.seekToEnd()
    }

    func appendMicrophone(_ samples: UnsafeRawPointer, frameCount: Int, bytesPerSample: Int, channelCount: Int, sampleRate: Int) {
        self.append(.microphone, samples: samples, frameCount: frameCount, bytesPerSample: bytesPerSample, channelCount: channelCount, sampleRate: sampleRate)
    }

    func appendRemote(_ samples: UnsafeRawPointer, frameCount: Int, bytesPerSample: Int, channelCount: Int, sampleRate: Int) {
        self.append(.remote, samples: samples, frameCount: frameCount, bytesPerSample: bytesPerSample, channelCount: channelCount, sampleRate: sampleRate)
    }

    private func append(_ source: Source, samples: UnsafeRawPointer, frameCount: Int, bytesPerSample: Int, channelCount: Int, sampleRate: Int) {
        guard frameCount > 0, bytesPerSample == MemoryLayout<Int16>.size, channelCount > 0, sampleRate > 0 else {
            return
        }
        let data = Data(bytes: samples, count: frameCount * channelCount * bytesPerSample)
        self.queue.async { [self] in
            guard !self.finished, self.sampleRate == 0 || self.sampleRate == sampleRate else {
                return
            }
            self.sampleRate = sampleRate
            var mono = [Int16]()
            mono.reserveCapacity(frameCount)
            data.withUnsafeBytes { rawBuffer in
                let input = rawBuffer.bindMemory(to: Int16.self)
                for frame in 0 ..< frameCount {
                    var sum: Int32 = 0
                    for channel in 0 ..< channelCount {
                        sum += Int32(input[frame * channelCount + channel])
                    }
                    mono.append(Int16(clamping: sum / Int32(channelCount)))
                }
            }
            switch source {
            case .microphone:
                self.microphone.append(contentsOf: mono)
            case .remote:
                self.remote.append(contentsOf: mono)
            }
            self.flushPairedSamples()
        }
    }

    private func flushPairedSamples() {
        let count = min(self.microphone.count - self.microphoneOffset, self.remote.count - self.remoteOffset)
        guard count > 0 else {
            return
        }
        var mixed = [Int16]()
        mixed.reserveCapacity(count)
        for index in 0 ..< count {
            let value = (Int32(self.microphone[self.microphoneOffset + index]) + Int32(self.remote[self.remoteOffset + index])) / 2
            mixed.append(Int16(clamping: value))
        }
        self.write(mixed)
        self.microphoneOffset += count
        self.remoteOffset += count
        self.compactBuffersIfNeeded()
    }

    private func compactBuffersIfNeeded() {
        if self.microphoneOffset > 48_000 {
            self.microphone.removeFirst(self.microphoneOffset)
            self.microphoneOffset = 0
        }
        if self.remoteOffset > 48_000 {
            self.remote.removeFirst(self.remoteOffset)
            self.remoteOffset = 0
        }
    }

    private func write(_ samples: [Int16]) {
        guard let file = self.file, !samples.isEmpty else {
            return
        }
        let littleEndian = samples.map { $0.littleEndian }
        let data = littleEndian.withUnsafeBytes { Data($0) }
        try? file.write(contentsOf: data)
        self.writtenSamples += Int64(samples.count)
    }

    func finish(_ completion: @escaping (String, Int) -> Void) {
        self.queue.async { [self] in
            guard !self.finished else {
                return
            }
            self.finished = true
            let microphoneTail = Array(self.microphone[self.microphoneOffset...])
            let remoteTail = Array(self.remote[self.remoteOffset...])
            let count = max(microphoneTail.count, remoteTail.count)
            if count > 0 {
                var mixed = [Int16]()
                mixed.reserveCapacity(count)
                for index in 0 ..< count {
                    let local = index < microphoneTail.count ? Int32(microphoneTail[index]) : 0
                    let remote = index < remoteTail.count ? Int32(remoteTail[index]) : 0
                    mixed.append(Int16(clamping: (local + remote) / 2))
                }
                self.write(mixed)
            }
            guard let file = self.file, self.sampleRate > 0, self.writtenSamples > 0 else {
                try? self.file?.close()
                try? FileManager.default.removeItem(atPath: self.path)
                return
            }
            try? file.seek(toOffset: 0)
            try? file.write(contentsOf: Self.wavHeader(sampleRate: self.sampleRate, sampleCount: self.writtenSamples))
            try? file.close()
            self.file = nil
            let duration = Int(self.writtenSamples / Int64(self.sampleRate))
            DispatchQueue.main.async {
                completion(self.path, duration)
            }
        }
    }

    private static func wavHeader(sampleRate: Int, sampleCount: Int64) -> Data {
        let dataSize = UInt32(clamping: sampleCount * 2)
        var data = Data()
        func append(_ string: String) { data.append(string.data(using: .ascii)!) }
        func append16(_ value: UInt16) { var value = value.littleEndian; withUnsafeBytes(of: &value) { data.append(contentsOf: $0) } }
        func append32(_ value: UInt32) { var value = value.littleEndian; withUnsafeBytes(of: &value) { data.append(contentsOf: $0) } }
        append("RIFF"); append32(36 &+ dataSize); append("WAVE")
        append("fmt "); append32(16); append16(1); append16(1)
        append32(UInt32(sampleRate)); append32(UInt32(sampleRate * 2)); append16(2); append16(16)
        append("data"); append32(dataSize)
        return data
    }
}
