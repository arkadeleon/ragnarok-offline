//
//  TestWorldContext.swift
//  RagnarokEffectsTests
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation
import simd
@testable import RagnarokEffects

@MainActor
final class RecordingWorldContext: EffectWorldContext {
    var cameraWorldPosition: SIMD3<Float>
    var cameraYawDegrees: Float = 0
    var cameraPitchDegrees: Float = 0
    var terrainYInEffectSpace: Float = 0
    var terrainHeightProvider: ((Float, Float) -> Float)?
    var targets: [EffectTargetID : EffectTargetState] = [:]
    var playedSounds: [(name: String, position: SIMD3<Float>?)] = []
    var shakeCount: Int = 0
    var appliedModifiers: [(targetID: EffectTargetID, modifier: EffectTargetModifier)] = []
    var spawnedChildren: [EffectSpawnRequest] = []

    var playedSoundNames: [String] {
        playedSounds.map(\.name)
    }

    init(cameraWorldPosition: SIMD3<Float> = .zero) {
        self.cameraWorldPosition = cameraWorldPosition
    }

    func terrainHeight(atEffectX x: Float, effectZ z: Float) -> Float {
        terrainHeightProvider?(x, z) ?? terrainYInEffectSpace
    }

    func targetState(for targetID: EffectTargetID) -> EffectTargetState? {
        targets[targetID]
    }

    func playSound(named name: String, atWorldPosition position: SIMD3<Float>?, delay: TimeInterval) {
        playedSounds.append((name, position))
    }

    func shakeCamera(amplitude: Float, duration: TimeInterval, frequency: Float) {
        shakeCount += 1
    }

    func applyTargetModifier(_ modifier: EffectTargetModifier, to targetID: EffectTargetID) {
        appliedModifiers.append((targetID, modifier))
    }

    func spawnChildEffect(_ request: EffectSpawnRequest) {
        spawnedChildren.append(request)
    }
}
