//
//  EmitterEffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation
import RagnarokRendering
import simd

/// Configurable quad particle emitter supporting pooled particle emission, velocity/acceleration, fade, and billboard/3D orientation.
@MainActor
open class EmitterEffect: ParticleEffect {
    public var velocityMin: SIMD3<Float> = SIMD3<Float>(-2, 2, -2)
    public var velocityMax: SIMD3<Float> = SIMD3<Float>(2, -1, 2)
    public var acceleration: SIMD3<Float> = SIMD3<Float>(0.7, -2, 1)
    public var spread: SIMD3<Float> = SIMD3<Float>(-1, 2, -1)

    public var timeScale: Float = 1.0 / 60.0
    public var scaleMin: Float = 3.0
    public var scaleMax: Float = 8.0
    public var lifeMin: Float = 5.0
    public var lifeMax: Float = 10.0
    public var rateMin: Float = 20.0
    public var rateMax: Float = 100.0

    public var width: Float = 1.0
    public var height: Float = 1.0
    public var red: UInt8 = 255
    public var green: UInt8 = 255
    public var blue: UInt8 = 255
    public var alpha: UInt8 = 255

    public var texturePath: String = "effect\\smoke2.bmp"
    public var sourceBlend: Int32 = EffectBlendFactor.sourceAlpha.rawValue
    public var destinationBlend: Int32 = EffectBlendFactor.one.rawValue
    public var count: Int = 40
    public var particleSpeed: Float = 1.0
    public var depthTest: Bool = true
    public var usesWorldOrientation: Bool = false
    public var fixedAlpha: Bool = false
    public var duration: Int = -1

    public private(set) var emitCarry: Float = 0
    public private(set) var particles: [Particle] = []

    open override func evaluateIsAlive() -> Bool {
        if duration > 0 && frame >= duration {
            return particles.contains(where: \.active)
        }
        return actorExists
    }

    open override func open(context: EffectTickContext) {
        particles = (0..<max(0, count)).map { _ in
            let particle = Particle(position: position)
            particle.active = false
            return particle
        }
    }

    open override func close() {
        particles.removeAll()
    }

    open func initParticle(_ particle: Particle) {
        particle.active = true
        particle.elapsedFrames = 0
        particle.position = SIMD3<Float>(
            position.x + ParticleMath.randomRange(-spread.x, spread.x),
            position.y + ParticleMath.randomRange(-spread.y, spread.y) - 10.0,
            position.z + ParticleMath.randomRange(-spread.z, spread.z)
        )
        particle.velocity = SIMD3<Float>(
            ParticleMath.randomRange(velocityMin.x, velocityMax.x),
            ParticleMath.randomRange(velocityMin.y, velocityMax.y),
            ParticleMath.randomRange(velocityMin.z, velocityMax.z)
        )
        particle.acceleration = acceleration
        particle.scale = ParticleMath.randomRange(scaleMin, scaleMax)
        particle.width = width
        particle.height = height
        particle.life = ParticleMath.randomRange(lifeMin, lifeMax)
        particle.setColor(red, green, blue)
        particle.alpha = fixedAlpha ? alpha : 0
        particle.sourceBlend = sourceBlend
        particle.destinationBlend = destinationBlend
        particle.setTexture(texturePath)
    }

    open func updateParticle(_ particle: Particle, world: any EffectWorldContext) {
        let totalLifeFrames = max(1, Int((particle.life * 60.0).rounded()))
        if !fixedAlpha {
            let maxAlpha = Float(alpha)
            if particle.elapsedFrames < 60 {
                let ratio = Float(particle.elapsedFrames) / 60.0
                particle.alpha = UInt8(clamping: Int(maxAlpha * ratio))
            } else if totalLifeFrames - particle.elapsedFrames < 60 {
                let remaining = max(0, totalLifeFrames - particle.elapsedFrames)
                let ratio = Float(remaining) / 60.0
                particle.alpha = UInt8(clamping: Int(maxAlpha * ratio))
            } else {
                particle.alpha = alpha
            }
        }

        let dt = timeScale * particleSpeed
        particle.velocity += particle.acceleration * dt
        particle.position += particle.velocity * dt

        let scaleMatrix = ParticleMath.makeScaleMatrix(
            particle.scale * particle.width,
            particle.scale * particle.height,
            1.0
        )

        if usesWorldOrientation {
            let rotX = EffectSpace.rotationX(radians: particle.angleX)
            let rotY = EffectSpace.rotationY(radians: particle.angleY)
            let rotZ = EffectSpace.rotationZ(radians: particle.angleZ)
            let translate = ParticleMath.makeTranslationMatrix(particle.position)
            particle.transform = translate * rotZ * rotY * rotX * scaleMatrix
        } else {
            let pitchRadians = world.cameraPitchDegrees / 180.0 * EffectSpace.clientPi
            let rotX = EffectSpace.rotationX(radians: pitchRadians)
            particle.transform = rotX * scaleMatrix
        }
    }

    open override func onProcess(context: EffectTickContext) {
        let canEmit = !emissionStopped && (duration <= 0 || frame < duration)
        if canEmit {
            let sampledRate = Float(Int(ParticleMath.randomRange(rateMin, rateMax)))
            emitCarry += sampledRate * timeScale
            let emitCount = Int(emitCarry)
            if emitCount > 0 {
                emitCarry -= Float(emitCount)
                var remaining = emitCount
                for particle in particles where !particle.active && remaining > 0 {
                    initParticle(particle)
                    remaining -= 1
                }
            }
        }

        for particle in particles where particle.active {
            updateParticle(particle, world: context.world)
            particle.elapsedFrames += 1
            if Float(particle.elapsedFrames) >= particle.life * 60.0 {
                particle.active = false
            }
        }
    }

    open override func collectParticles(
        into collector: inout EffectPrimitiveBatchCollector,
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext,
        assets: EffectAssetStore?
    ) {
        for particle in particles where particle.active {
            particle.render(
                into: &collector,
                world: world,
                assets: assets,
                usesTransformDirectly: usesWorldOrientation,
                depthTest: depthTest
            )
        }
    }
}
