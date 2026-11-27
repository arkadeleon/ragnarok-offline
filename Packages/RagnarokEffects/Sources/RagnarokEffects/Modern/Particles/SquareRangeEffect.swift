//
//  SquareRangeEffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation
import RagnarokRendering
import simd

/// Flat ground-aligned square range indicator (`EF_KG_KAGEHUMI`).
@MainActor
public final class SquareRangeEffect: ParticleEffect {
    public var size: Float = 1.0
    public var needsResize: Bool = false
    public private(set) var particles: [Particle] = []

    public override func open(context: EffectTickContext) {
        if effectID == .ef_kg_kagehumi {
            size = 7.0
        }

        let particle = Particle(position: position)
        particle.active = true
        particle.alpha = 255
        particle.setColor(255, 255, 255)
        particle.setTexture("effect\\SquareRange.tga")
        particle.scale = size * 2.5

        if effectID == .ef_kg_kagehumi {
            effectLifetime = 300
            particle.setColor(92, 92, 92)
            particle.destinationBlend = EffectBlendFactor.oneMinusSourceAlpha.rawValue
        }

        particles.append(particle)
    }

    public override func close() {
        particles.removeAll()
    }

    public override func evaluateIsAlive() -> Bool {
        if effectID == .ef_kg_kagehumi {
            return !isFinished
        }
        return true
    }

    public override func onProcess(context: EffectTickContext) {
        for particle in particles {
            particle.position = position
            if needsResize {
                particle.scale = size * 2.5
                needsResize = false
            }

            let rotation = EffectSpace.rotationX(radians: EffectSpace.clientPi * 0.5)
            let scale = ParticleMath.makeScaleMatrix(particle.scale, particle.scale, 1.0)
            particle.transform = rotation * scale
            particle.elapsedFrames += 1
        }
    }

    public override func collectParticles(
        into collector: inout EffectPrimitiveBatchCollector,
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext,
        assets: EffectAssetStore?
    ) {
        for particle in particles {
            particle.render(
                into: &collector,
                world: world,
                assets: assets,
                usesTransformDirectly: false,
                depthTest: true
            )
        }
    }
}
