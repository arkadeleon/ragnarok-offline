//
//  MetalSceneState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/31.
//

import Observation

@MainActor
@Observable
final class MetalSceneState {
    var isPlayerDead = false
    let overlay = MetalOverlayState()
}
