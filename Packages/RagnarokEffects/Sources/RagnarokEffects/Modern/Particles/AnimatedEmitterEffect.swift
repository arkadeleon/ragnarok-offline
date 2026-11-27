//
//  AnimatedEmitterEffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation
import simd

/// Emitter subclass cycling between shockwave and plasma texture sequences per particle.
@MainActor
public final class AnimatedEmitterEffect: EmitterEffect {
    private var frameSequences: [[String]] = []

    public required init(id: UUID = UUID(), request: EffectSpawnRequest) {
        super.init(id: id, request: request)
        acceleration = .zero
        velocityMin = SIMD3<Float>(-3, -1, -3)
        velocityMax = SIMD3<Float>(3, 1, 3)
        spread = .zero
        scaleMin = 10.0
        scaleMax = 20.0
        lifeMin = 3.0
        lifeMax = 4.0
        rateMin = 1.0
        rateMax = 3.0
        count = 4
    }

    public override func open(context: EffectTickContext) {
        frameSequences = [
            [
                "EFFECT\\shockwave_a.bmp",
                "EFFECT\\shockwave_b.bmp",
                "EFFECT\\shockwave_c.bmp",
                "EFFECT\\shockwave_d.bmp",
                "EFFECT\\shockwave_e.bmp",
            ],
            [
                "EFFECT\\plazma_a.bmp",
                "EFFECT\\plazma_b.bmp",
                "EFFECT\\plazma_c.bmp",
                "EFFECT\\plazma_a.bmp",
                "EFFECT\\plazma_b.bmp",
            ],
        ]
        super.open(context: context)
    }

    public override func initParticle(_ particle: Particle) {
        particle.animationParameter = Float(Int.random(in: 0..<2))
        super.initParticle(particle)
    }

    public override func updateParticle(_ particle: Particle, world: any EffectWorldContext) {
        let kind = Int(particle.animationParameter)
        if frameSequences.indices.contains(kind) {
            let sequence = frameSequences[kind]
            if !sequence.isEmpty {
                let frameIndex = (particle.elapsedFrames / 8) % sequence.count
                particle.setTexture(sequence[frameIndex])
            }
        }
        super.updateParticle(particle, world: world)
    }
}
