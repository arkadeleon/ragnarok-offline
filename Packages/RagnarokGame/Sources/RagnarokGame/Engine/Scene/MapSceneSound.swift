//
//  MapSceneSound.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/2.
//

import Foundation
import RagnarokFileFormats
import simd

final class MapSceneSound {
    let name: String

    let gridPosition: SIMD2<Float>

    /// How far the sound carries, in cells.
    let range: Float

    /// How long to wait between two plays.
    let playInterval: Duration

    /// When the sound may play again. It plays as soon as the player walks into range.
    var nextPlayTime: ContinuousClock.Instant?

    init(sound: RSW.Objects.Sound, gnd: GND) {
        name = sound.waveName

        gridPosition = [
            sound.position.x + Float(gnd.width),
            sound.position.z + Float(gnd.height),
        ]

        range = sound.range / 5

        // RSW before 2.0 carries no cycle, and repeat every 7 seconds.
        playInterval = .seconds(sound.cycle > 0 ? Double(sound.cycle) : 7)
    }

    func volume(forListenerAtPosition listenerPosition: SIMD2<Float>) -> Float? {
        let distance = simd_distance(gridPosition, listenerPosition).rounded(.down)
        guard distance <= range else {
            return nil
        }

        // The volume drops in a straight line from about 1 next to the sound
        // to 0 at 25 cells away, and never falls below 0.1.
        return max(1 - abs((distance - 1) * (1 - 0.01) / (25 - 1) + 0.01), 0.1)
    }
}
