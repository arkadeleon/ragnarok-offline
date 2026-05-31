//
//  MetalSceneState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/31.
//

#if !os(visionOS)

import Observation

@MainActor
@Observable
final class MetalSceneState {
    var isPlayerDead = false
    let overlay = MapOverlayState()
}

#endif
