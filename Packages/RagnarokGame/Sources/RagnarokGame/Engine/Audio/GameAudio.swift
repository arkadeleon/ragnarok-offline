//
//  GameAudio.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/2.
//

import AVFAudio
import simd

enum GameAudio {
    /// The format every sound effect is decoded into.
    static let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!

    /// Where a sound effect comes from, and how far it carries, in world units.
    /// Only x and y count toward what the listener hears.
    struct Source {
        var position: SIMD3<Float>
        var range: Float

        func distance(toListenerAtPosition listenerPosition: SIMD3<Float>) -> Float {
            simd_distance(
                SIMD2(position.x, position.y),
                SIMD2(listenerPosition.x, listenerPosition.y)
            )
        }

        func isInRange(ofListenerAtPosition listenerPosition: SIMD3<Float>) -> Bool {
            distance(toListenerAtPosition: listenerPosition).rounded(.down) <= range
        }
    }
}
