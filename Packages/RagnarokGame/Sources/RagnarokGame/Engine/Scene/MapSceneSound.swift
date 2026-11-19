//
//  MapSceneSound.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/2.
//

import Foundation
import RagnarokFileFormats

final class MapSceneSound {
    let name: String

    /// Where the sound sits, in world units. Only x and z count toward what the listener hears.
    let position: SIMD3<Float>

    /// How far the sound carries, in cells.
    let range: Float

    /// How long to wait between two plays.
    let playInterval: TimeInterval

    /// When the sound may play again. It plays as soon as the player walks into range.
    var nextPlayTime: TimeInterval?

    init(sound: RSW.Objects.Sound, gnd: GND) {
        name = sound.waveName

        position = [
            sound.position.x + Float(gnd.width),
            -sound.position.y,
            -(sound.position.z + Float(gnd.height)),
        ]

        range = sound.range / 5

        // RSW before 2.0 carries no cycle, and repeat every 7 seconds.
        playInterval = sound.cycle > 0 ? TimeInterval(sound.cycle) : 7
    }
}
