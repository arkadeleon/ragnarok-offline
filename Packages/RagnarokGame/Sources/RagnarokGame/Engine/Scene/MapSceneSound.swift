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

    /// Where the sound sits, in world units. Only x and y count toward what the
    /// listener hears.
    let position: SIMD3<Float>

    /// How far the sound carries, in cells.
    let range: Float

    /// How long to wait between two plays.
    let playInterval: Duration

    /// When the sound may play again. It plays as soon as the player walks into range.
    var nextPlayTime: ContinuousClock.Instant?

    init(sound: RSW.Objects.Sound, gnd: GND) {
        name = sound.waveName

        position = [
            sound.position.x + Float(gnd.width),
            sound.position.z + Float(gnd.height),
            -sound.position.y,
        ]

        range = sound.range / 5

        // RSW before 2.0 carries no cycle, and repeat every 7 seconds.
        playInterval = .seconds(sound.cycle > 0 ? Double(sound.cycle) : 7)
    }
}
