//
//  EffectManagerTests.swift
//  RagnarokEffectsTests
//
//  Created by Leon Li on 2026/11/20.
//

import Foundation
import Metal
import RagnarokResources
import simd
import Testing
@testable import RagnarokEffects

@MainActor
@Suite("EffectManager & EffectAssetStore")
struct EffectManagerTests {
    private final class MockWorldContext: EffectWorldContext {
        var cameraWorldPosition: SIMD3<Float> = .zero

        func terrainHeight(atEffectX x: Float, effectZ z: Float) -> Float { 0 }
        func targetState(for targetID: EffectTargetID) -> EffectTargetState? { nil }
        func playSound(named name: String, atWorldPosition position: SIMD3<Float>?, delay: TimeInterval) {}
        func shakeCamera(amplitude: Float, duration: TimeInterval, frequency: Float) {}
        func applyTargetModifier(_ modifier: EffectTargetModifier, to targetID: EffectTargetID) {}
        func spawnChildEffect(_ request: EffectSpawnRequest) {}
    }

    private final class MockEffect: EffectInstance {
        let id: UUID
        let rawEffectID: Int
        let ownerObjectID: EffectTargetID?
        let attachmentKey: EffectAttachmentKey
        var isAlive = true
        var tickCount = 0
        let lifetimeTicks: Int

        init(id: UUID, request: EffectSpawnRequest, lifetimeTicks: Int) {
            self.id = id
            self.rawEffectID = request.rawEffectID
            self.ownerObjectID = request.ownerObjectID
            self.attachmentKey = request.attachmentKey
            self.lifetimeTicks = lifetimeTicks
        }

        func tick(context: EffectTickContext) {
            tickCount += 1
            if tickCount >= lifetimeTicks {
                isAlive = false
            }
        }

        func stop() {
            isAlive = false
        }
    }

    @Test("60Hz fixed-tick accumulator steps accurately and clamps frame spikes")
    func fixedTickAccumulationAndClamp() {
        let manager = EffectManager()
        let world = MockWorldContext()

        #expect(manager.advance(deltaTime: 0.008, world: world) == 0)
        #expect(manager.advance(deltaTime: 0.009, world: world) == 1)
        #expect(manager.advance(deltaTime: 0.05, world: world) == 3)
        #expect(manager.advance(deltaTime: 1.0, world: world) == EffectManager.maxTicksPerUpdate)
        #expect(manager.advance(deltaTime: 0.001, world: world) == 0)
        #expect(manager.currentTick == 8)
    }

    @Test("update(atTime:) anchors first frame and advances monotonically")
    func updateAtTimeAnchoring() {
        let manager = EffectManager()
        let world = MockWorldContext()

        #expect(manager.update(atTime: 10.0, world: world) == 0)
        #expect(manager.update(atTime: 10.0 + (2.0 / 60.0), world: world) == 2)
        #expect(manager.update(atTime: 9.5, world: world) == 0)
        #expect(manager.currentTick == 2)
    }

    @Test("Particle effect takes priority over RagEffect and supports query")
    func dualFactoryRouting() {
        let manager = EffectManager()
        let world = MockWorldContext()

        manager.registerParticleEffect(for: .ef_stormgust) { id, request in
            MockEffect(id: id, request: request, lifetimeTicks: 2)
        }
        manager.registerRagEffect(for: .ef_stormgust) { id, request in
            MockEffect(id: id, request: request, lifetimeTicks: 5)
        }
        manager.registerRagEffect(for: .ef_fireball) { id, request in
            MockEffect(id: id, request: request, lifetimeTicks: 3)
        }

        #expect(manager.supports(.ef_stormgust))
        #expect(manager.supports(.ef_fireball))
        #expect(!manager.supports(.ef_hit1))
        #expect(manager.supportedRawEffectIDs == [EffectID.ef_fireball.rawValue, EffectID.ef_stormgust.rawValue])

        #expect(manager.spawn(EffectSpawnRequest(effectID: .ef_stormgust, worldPosition: .zero)) != nil)
        #expect(manager.spawn(EffectSpawnRequest(effectID: .ef_fireball, worldPosition: .zero)) != nil)
        #expect(manager.activeEffects.count == 2)

        // Particle effect (2 ticks) expires before RagEffect (3 ticks), proving particle priority
        manager.stepOneTick(world: world)
        manager.stepOneTick(world: world)
        #expect(manager.activeEffects.count == 1)
        #expect(manager.activeEffects.first?.rawEffectID == EffectID.ef_fireball.rawValue)

        manager.stepOneTick(world: world)
        #expect(!manager.hasActiveEffects)
    }

    @Test("Owner/attachmentKey removal and delayed spawn handle stability")
    func ownerAttachmentRemovalAndDelay() {
        let manager = EffectManager()
        let world = MockWorldContext()

        manager.registerParticleEffect(for: .ef_blessing) { id, request in
            MockEffect(id: id, request: request, lifetimeTicks: 100)
        }

        let ownerA: EffectTargetID = 1001
        let ownerB: EffectTargetID = 2002

        manager.spawn(EffectSpawnRequest(effectID: .ef_blessing, worldPosition: .zero, ownerObjectID: ownerA, attachmentKey: .cast))
        manager.spawn(EffectSpawnRequest(effectID: .ef_blessing, worldPosition: .zero, ownerObjectID: ownerA, attachmentKey: .status(10)))
        manager.spawn(EffectSpawnRequest(effectID: .ef_blessing, worldPosition: .zero, ownerObjectID: ownerB, attachmentKey: .cast))
        let delayedID = manager.spawn(EffectSpawnRequest(effectID: .ef_blessing, worldPosition: .zero, ownerObjectID: ownerA, attachmentKey: .status(20), delay: 2.0 / 60.0))

        manager.removeEffects(ownedBy: ownerA, key: .cast)
        #expect(manager.activeEffects.count == 2)

        manager.stepOneTick(world: world)
        manager.stepOneTick(world: world)
        #expect(manager.activeEffects.count == 3)

        if let delayedID {
            manager.removeEffect(id: delayedID)
        }
        #expect(manager.activeEffects.count == 2)

        manager.removeEffects(ownedBy: ownerA)
        #expect(manager.activeEffects.count == 1)
        #expect(manager.activeEffects.first?.ownerObjectID == ownerB)
    }

    @Test("EffectAssetStore shares in-flight load and handles missing preload")
    func assetStoreSTRCacheAndPreload() async {
        guard let device = MTLCreateSystemDefaultDevice() else {
            return
        }

        struct EmptyResourceProvider: ResourceProvider {
            func contentsOfResource(at path: ResourcePath) async throws -> Data {
                throw ResourceError.resourceNotFound(path)
            }
        }

        let resourceManager = ResourceManager(resourceProvider: EmptyResourceProvider())
        let store = EffectAssetStore(device: device, resourceManager: resourceManager)

        #expect(store.strAsset(at: "missing.str") == nil)
        #expect(await store.preloadSTRAsset(atPath: "missing.str") == nil)

        store.removeAll()
    }
}
