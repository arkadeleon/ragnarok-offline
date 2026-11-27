//
//  ChopChopClawMarksEffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation
import simd

/// Rapid ring-distributed claw mark STR bursts around a target (`EF_KR_CHOP_CHOP`).
@MainActor
public final class ChopChopClawMarksEffect: CharacterParticleBundle {
    private static let ringPoints: [SIMD2<Float>] = {
        let outer = makeRadialGrid(center: SIMD2<Int>(0, 0), radius: 3)
        let inner = Set(makeRadialGrid(center: SIMD2<Int>(0, 1), radius: 1))
        return outer
            .filter { !inner.contains($0) && $0.x != 0 && $0.y != 0 }
            .map { SIMD2<Float>(Float($0.x), Float($0.y)) }
    }()

    public var offsetX: Float = 0
    public var offsetY: Float = 0

    /// Interval in 60Hz ticks between claw-mark bursts (~30ms = 2 ticks).
    private let spawnIntervalTicks: Int = 2
    private var lastSpawnTick: Int = -2

    public required init(id: UUID = UUID(), request: EffectSpawnRequest) {
        super.init(id: id, request: request)
        if request.duration == nil {
            effectLifetime = 2
        } else {
            effectLifetime = max(1, Int((request.duration ?? 2.0).rounded()))
        }
    }

    public override func evaluateIsAlive() -> Bool {
        guard actorExists else {
            return false
        }
        return elapsedFrames <= effectLifetime * Int(EffectManager.tickRate)
    }

    public override func emitParticles(context: EffectTickContext) {
        if elapsedFrames >= lastSpawnTick + spawnIntervalTicks {
            spawnClawParticle()
            lastSpawnTick = elapsedFrames
        }
    }

    public override func updateParticlePosition(_ particle: STRParticle, world: any EffectWorldContext) {
        let yawRadians = world.cameraYawDegrees / 180.0 * EffectSpace.clientPi
        let right = SIMD3<Float>(cosf(yawRadians), 0, -sinf(yawRadians))
        let up = SIMD3<Float>(0, -1, 0)
        let screenOffsetX = offsetX + particle.offset.x
        let screenOffsetY = -offsetY + particle.offset.y
        particle.position = position + right * screenOffsetX + up * screenOffsetY
    }

    private func spawnClawParticle() {
        guard let point = Self.ringPoints.randomElement() else {
            return
        }

        let particle = STRParticle(position: position)
        particle.load("DRUID\\KR_CHOP_CHOP\\chop_chop\\chop_chop.str")
        particle.offset = SIMD3<Float>(point.x * 5.0, point.y * 5.0, 0)
        particle.angle = Float(Int.random(in: 0..<360))
        particles.append(particle)
    }

    private static func makeRadialGrid(center: SIMD2<Int>, radius: Int) -> [SIMD2<Int>] {
        guard radius >= 0 else {
            return []
        }
        var points: [SIMD2<Int>] = []
        let rSquared = radius * radius
        for dy in -radius...radius {
            for dx in -radius...radius {
                if dx * dx + dy * dy <= rSquared {
                    points.append(SIMD2<Int>(center.x + dx, center.y + dy))
                }
            }
        }
        return points
    }
}
