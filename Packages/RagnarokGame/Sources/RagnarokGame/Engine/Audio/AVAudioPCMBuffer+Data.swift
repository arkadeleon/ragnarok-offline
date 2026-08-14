//
//  AVAudioPCMBuffer+Data.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/15.
//

import AVFAudio
import Foundation

extension AVAudioPCMBuffer {
    static func load(from data: Data) -> AVAudioPCMBuffer? {
        let tempURL = URL.temporaryDirectory
            .appending(path: UUID().uuidString)
            .appendingPathExtension("audio")

        do {
            try data.write(to: tempURL)
            defer {
                try? FileManager.default.removeItem(at: tempURL)
            }

            let audioFile = try AVAudioFile(forReading: tempURL)
            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            ) else {
                return nil
            }

            try audioFile.read(into: buffer)
            return buffer
        } catch {
            try? FileManager.default.removeItem(at: tempURL)
            return nil
        }
    }
}
