//
//  ParticleEffectTests.swift
//  RagnarokEffectsTests
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation
import RagnarokRendering
import simd
import Testing
@testable import RagnarokEffects

@MainActor
private final class EventTestParticleEffect: ParticleEffect {
    var openCount: Int = 0
    var closeCount: Int = 0
    var processCount: Int = 0

    override func open(context: EffectTickContext) {
        openCount += 1
        events = [
            ParticleEffectEvent(kind: .sound, frame: 0, argument: -5.0, text: "effect\\test_sound.wav"),
            ParticleEffectEvent(kind: .quake, frame: 2),
        ]
    }

    override func onProcess(context: EffectTickContext) {
        processCount += 1
    }

    override func close() {
        closeCount += 1
    }
}

@MainActor
struct ParticleEffectTests {
    @Test func particleEffectLifecycleAndEventTimeline() {
        let world = RecordingWorldContext()
        world.targets[42] = EffectTargetState(
            objectID: 42,
            worldPosition: SIMD3<Float>(2, 0, -3),
            headHeight: 2.0
        )

        let request = EffectSpawnRequest(
            effectID: .ef_emitter,
            worldPosition: .zero,
            ownerObjectID: 42,
            duration: 0.05
        )
        let effect = EventTestParticleEffect(request: request)
        let context = EffectTickContext(
            world: world,
            assets: nil,
            currentTick: 1,
            usesMinimalEffects: false,
            onSpawnChild: { _ in }
        )

        effect.tick(context: context)
        #expect(effect.openCount == 1)
        #expect(effect.processCount == 1)
        #expect(effect.frame == 1)
        #expect(effect.position == EffectSpace.toEffectPosition(SIMD3<Float>(2, 0, -3)))
        #expect(world.playedSoundNames == ["effect\\test_sound.wav"])
        #expect(world.shakeCount == 0)

        effect.tick(context: context)
        effect.tick(context: context)
        #expect(effect.openCount == 1)
        #expect(effect.processCount == 3)
        #expect(world.shakeCount == 1)
        #expect(effect.isFinished)

        world.targets.removeValue(forKey: 42)
        effect.tick(context: context)
        #expect(!effect.actorExists)
        #expect(!effect.isAlive)

        effect.stop()
        #expect(effect.closeCount == 1)
        effect.stop()
        #expect(effect.closeCount == 1)
    }

    @Test func particleQuadRenderBillboardAndWorldSpace() {
        let world = RecordingWorldContext()
        world.cameraYawDegrees = 45

        let particle = Particle(position: SIMD3<Float>(10, -5, 20))
        particle.setColor(255, 128, 64)
        particle.alpha = 200
        particle.transform = ParticleMath.makeScaleMatrix(4, 4, 1)

        var collector = EffectPrimitiveBatchCollector(fog: Fog(), modelMatrix: matrix_identity_float4x4)
        particle.render(into: &collector, world: world, assets: nil, usesTransformDirectly: false)
        particle.render(into: &collector, world: world, assets: nil, usesTransformDirectly: true)

        #expect(collector.batches.count == 1)
        #expect(collector.batches[0].vertices.count == 12)
        for vertex in collector.batches[0].vertices {
            #expect(vertex.position.x.isFinite)
            #expect(vertex.position.y.isFinite)
            #expect(vertex.position.z.isFinite)
        }
    }

    @Test func particleMathRandomHelpersStayWithinBounds() {
        for _ in 0..<50 {
            let value = ParticleMath.randomRange(-2.5, 3.5)
            #expect(value >= -2.5 && value <= 3.5)

            let point = ParticleMath.randomDiscPoint(center: SIMD3<Float>(10, -4, 20), radius: 5.0)
            let dx = point.x - 10
            let dz = point.z - 20
            #expect(hypotf(dx, dz) <= 5.001)
            #expect(point.y == -4)
        }
    }

    @Test func emitterAndAnimatedEmitterEmitAndRetire() {
        let world = RecordingWorldContext()
        let manager = EffectManager()

        let emitterRequest = EffectSpawnRequest(
            effectID: .ef_emitter,
            worldPosition: SIMD3<Float>(0, 0, 0)
        )
        let emitterID = manager.spawn(emitterRequest)
        #expect(emitterID != nil)

        for _ in 0..<30 {
            manager.stepOneTick(world: world)
        }

        let payloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(!payloads.isEmpty)
        #expect(payloads.allSatisfy { !$0.vertices.isEmpty })

        if let emitter = manager.activeEffects.first as? EmitterEffect {
            let hasActiveParticle = emitter.particles.contains(where: \.active)
            #expect(hasActiveParticle)
            emitter.duration = 1
            for particle in emitter.particles {
                particle.active = false
            }
            #expect(!emitter.isAlive)
        } else {
            Issue.record("Expected EmitterEffect instance for .ef_emitter")
        }

        let animatedManager = EffectManager()
        let animatedID = animatedManager.spawn(
            EffectSpawnRequest(effectID: .ef_animated_emitter, worldPosition: .zero)
        )
        #expect(animatedID != nil)
        for _ in 0..<90 {
            animatedManager.stepOneTick(world: world)
        }
        let animatedPayloads = animatedManager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(!animatedPayloads.isEmpty)
    }

    @Test func rangeEffectsEmitFiniteGeometry() {
        let world = RecordingWorldContext()
        world.terrainYInEffectSpace = -2.0
        let manager = EffectManager()

        _ = manager.spawn(
            EffectSpawnRequest(
                effectID: .ef_ko_makibishi,
                worldPosition: .zero,
                parameters: [1]
            )
        )
        _ = manager.spawn(
            EffectSpawnRequest(
                effectID: .ef_kg_kagehumi,
                worldPosition: SIMD3<Float>(2, 0, 2)
            )
        )

        manager.stepOneTick(world: world)
        let payloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        let totalVertices = payloads.reduce(0) { $0 + $1.vertices.count }
        // 3x3 = 9 cells (54 vertices) + 1 square range quad (6 vertices) = 60 vertices.
        #expect(totalVertices == 60)
    }

    @Test func registryAllBuiltInParticleEffectsSmokeTest() {
        let supportedIDs = ParticleEffectRegistry.supportedEffectIDs
        #expect(supportedIDs.count == 46)

        for effectID in supportedIDs {
            #expect(EffectManager.hasBuiltInDefinition(for: effectID))

            let world = RecordingWorldContext()
            world.targets[1] = EffectTargetState(
                objectID: 1,
                worldPosition: .zero,
                headHeight: 2.0
            )
            let manager = EffectManager()
            let request = EffectSpawnRequest(
                effectID: effectID,
                worldPosition: .zero,
                ownerObjectID: 1,
                targetObjectID: 1
            )
            let spawnedID = manager.spawn(request)
            #expect(spawnedID != nil, "Failed to spawn \(effectID)")

            for _ in 0..<65 {
                manager.stepOneTick(world: world)
            }

            let primitivePayloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
            for payload in primitivePayloads {
                for vertex in payload.vertices {
                    #expect(vertex.position.x.isFinite)
                    #expect(vertex.position.y.isFinite)
                    #expect(vertex.position.z.isFinite)
                }
            }
            _ = manager.collectSTRPayloads(fog: Fog(), world: world)
        }
    }
}
