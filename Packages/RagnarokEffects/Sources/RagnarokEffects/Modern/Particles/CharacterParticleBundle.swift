//
//  CharacterParticleBundle.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation
import RagnarokRendering
import simd

/// Base effect managing a dynamic bundle of `STRParticle` instances attached to an actor.
@MainActor
open class CharacterParticleBundle: ParticleEffect {
    public var elapsedFrames: Int = 0
    public var particles: [STRParticle] = []

    open func onInit(context: EffectTickContext) {
    }

    open func emitParticles(context: EffectTickContext) {
    }

    open func updateParticlePosition(_ particle: STRParticle, world: any EffectWorldContext) {
        particle.position = position + particle.offset
    }

    open func processParticle(_ particle: STRParticle, context: EffectTickContext) {
        particle.process(assets: context.assets, usesMinimalEffects: context.usesMinimalEffects)
    }

    open override func open(context: EffectTickContext) {
        elapsedFrames = 0
        onInit(context: context)
    }

    open override func close() {
        particles.removeAll()
    }

    open override func onProcess(context: EffectTickContext) {
        emitParticles(context: context)
        particles.removeAll { $0.life < 0 }

        for particle in particles {
            updateParticlePosition(particle, world: context.world)
            processParticle(particle, context: context)
        }
        elapsedFrames += 1
    }

    open override func collectSTRPayloads(
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext,
        assets: EffectAssetStore?
    ) -> [STREffectRenderer.RenderPayload] {
        particles.compactMap {
            $0.makeRenderPayload(fog: fog, modelMatrix: modelMatrix, world: world)
        }
    }
}
