//
//  AVAudioPCMBuffer+Data.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/15.
//

import AVFAudio
import Foundation

extension AVAudioPCMBuffer {
    /// Decodes the contents of an audio file, resampling and remixing them to `format`.
    @concurrent
    static func buffer(from data: Data, format: AVAudioFormat) async -> sending AVAudioPCMBuffer? {
        // Core Audio reads audio from files rather than from memory,
        // so the contents are written to a temporary file first.
        let temporaryURL = URL.temporaryDirectory
            .appending(path: UUID().uuidString)
            .appendingPathExtension("audio")
        defer {
            try? FileManager.default.removeItem(at: temporaryURL)
        }

        let decodedBuffer: AVAudioPCMBuffer
        let converter: AVAudioConverter
        do {
            try data.write(to: temporaryURL)

            let audioFile = try AVAudioFile(forReading: temporaryURL)
            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            ) else {
                return nil
            }

            try audioFile.read(into: buffer)

            guard let audioConverter = AVAudioConverter(from: buffer.format, to: format) else {
                return nil
            }

            decodedBuffer = buffer
            converter = audioConverter
        } catch {
            return nil
        }

        // Resampling stretches the buffer, and the filter can add a frame at the end.
        let frameRatio = format.sampleRate / decodedBuffer.format.sampleRate
        let frameCapacity = AVAudioFrameCount(Double(decodedBuffer.frameLength) * frameRatio) + 1
        guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else {
            return nil
        }

        // The converter asks for input on this thread, while `convert` runs, so nothing
        // below is touched concurrently.
        nonisolated(unsafe) let inputBuffer = decodedBuffer
        nonisolated(unsafe) var isBufferConsumed = false

        var conversionError: NSError?
        converter.convert(to: convertedBuffer, error: &conversionError) { _, inputStatus in
            if isBufferConsumed {
                inputStatus.pointee = .endOfStream
                return nil
            }

            isBufferConsumed = true
            inputStatus.pointee = .haveData
            return inputBuffer
        }

        guard conversionError == nil else {
            return nil
        }

        return convertedBuffer
    }
}
