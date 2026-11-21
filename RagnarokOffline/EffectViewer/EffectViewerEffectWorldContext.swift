//
//  EffectViewerEffectWorldContext.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/11/21.
//

import Foundation
import RagnarokEffects
import simd

/// Virtual flat-ground world context for `EffectViewer` with a target anchor at `[0, 0, 0]`
/// and a caster/source anchor at `[-5, 0, -5]`.
@MainActor
final class EffectViewerEffectWorldContext: EffectWorldContext {
    static let targetObjectID: EffectTargetID = 1
    static let sourceObjectID: EffectTargetID = 2

    var cameraWorldPosition: SIMD3<Float> = SIMD3<Float>(0, 10, 20)

    private let targets: [EffectTargetID : EffectTargetState] = [
        targetObjectID: EffectTargetState(
            objectID: targetObjectID,
            worldPosition: .zero,
            headHeight: 2.0
        ),
        sourceObjectID: EffectTargetState(
            objectID: sourceObjectID,
            worldPosition: SIMD3<Float>(-5, 0, -5),
            headHeight: 2.0
        ),
    ]

    func terrainHeight(atEffectX x: Float, effectZ z: Float) -> Float {
        0
    }

    func targetState(for targetID: EffectTargetID) -> EffectTargetState? {
        targets[targetID]
    }

    func playSound(named name: String, atWorldPosition position: SIMD3<Float>?, delay: TimeInterval) {
    }

    func shakeCamera(amplitude: Float, duration: TimeInterval, frequency: Float) {
    }

    func applyTargetModifier(_ modifier: EffectTargetModifier, to targetID: EffectTargetID) {
    }

    func spawnChildEffect(_ request: EffectSpawnRequest) {
    }
}
