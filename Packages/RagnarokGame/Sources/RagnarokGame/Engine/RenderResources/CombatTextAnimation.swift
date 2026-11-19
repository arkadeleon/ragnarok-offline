//
//  CombatTextAnimation.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/23.
//

import Foundation
import simd

/// Where a combat text sits and how it looks at one moment.
struct CombatTextAnimation {
    let worldPosition: SIMD3<Float>
    let scale: Float
    let alpha: Float
}

extension CombatText {
    func animation(
        atTime time: TimeInterval,
        anchor: SIMD3<Float>,
        cameraAzimuth: Float
    ) -> CombatTextAnimation? {
        let elapsedTime = time - startTime
        let t = Float(elapsedTime / duration)
        guard t >= 0, t < 1 else {
            return nil
        }

        if kind == .combo, t > 0.15 {
            return nil
        }

        let scale: Float
        let worldPosition: SIMD3<Float>
        switch kind {
        case .hpRecovery, .spRecovery:
            scale = max((1 - t * 2) * 3, 0.8)
            worldPosition = [
                anchor.x,
                anchor.y + 2 + (t < 0.4 ? 0 : (t - 0.4) * 5),
                anchor.z,
            ]
        case .miss:
            scale = 0.5
            worldPosition = [
                anchor.x,
                anchor.y + 3.5 + 7 * t,
                anchor.z,
            ]
        case .damage:
            scale = 4 * (1 - t)
            let drift = drift(azimuth: cameraAzimuth) * t
            worldPosition = [
                anchor.x + drift.x,
                anchor.y + 2 + sin(-.pi / 2 + (.pi * (0.5 + 1.5 * t))) * 5,
                anchor.z + drift.z,
            ]
        case .combo, .finalCombo:
            scale = min(t, 0.05) * 70
            worldPosition = [
                anchor.x,
                anchor.y + 7 + t,
                anchor.z,
            ]
        }

        guard scale > 0 else {
            return nil
        }

        return CombatTextAnimation(worldPosition: worldPosition, scale: scale, alpha: 1 - t)
    }

    /// Damage numbers slide away from the camera's lower left.
    private func drift(azimuth: Float) -> SIMD3<Float> {
        let cosAngle = cos(azimuth)
        let sinAngle = sin(azimuth)
        let localDrift = SIMD2<Float>(4, -4)
        let worldDrift = SIMD2<Float>(
            localDrift.x * cosAngle - localDrift.y * sinAngle,
            localDrift.x * sinAngle + localDrift.y * cosAngle
        )
        return SIMD3<Float>(worldDrift.x, 0, worldDrift.y)
    }
}
