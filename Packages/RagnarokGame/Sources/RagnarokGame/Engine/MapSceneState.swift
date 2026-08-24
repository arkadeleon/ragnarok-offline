//
//  MapSceneState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/31.
//

import Observation
import RagnarokSprite

@MainActor
@Observable
final class MapSceneState {
    var playerPosition: SIMD2<Int>
    var playerDirection: SpriteDirection
    var isPlayerDead = false

    init(playerPosition: SIMD2<Int>, playerDirection: SpriteDirection) {
        self.playerPosition = playerPosition
        self.playerDirection = playerDirection
    }
}
