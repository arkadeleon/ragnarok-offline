//
//  EffectPrimitiveTests.swift
//  RagnarokEffectsTests
//
//  Created by Leon Li on 2026/11/24.
//

import Foundation
import Metal
import RagnarokCore
import RagnarokRendering
import RagnarokResources
import simd
import Testing
@testable import RagnarokEffects

@Suite("EffectPrimitive & RagEffect Host")
@MainActor
struct EffectPrimitiveTests {
    private func approxEqual(_ a: Float, _ b: Float, tolerance: Float = 1e-4) -> Bool {
        abs(a - b) <= tolerance
    }

    private func approxEqual(_ a: SIMD3<Float>, _ b: SIMD3<Float>, tolerance: Float = 1e-4) -> Bool {
        approxEqual(a.x, b.x, tolerance: tolerance)
            && approxEqual(a.y, b.y, tolerance: tolerance)
            && approxEqual(a.z, b.z, tolerance: tolerance)
    }

    private func approxEqual(_ a: SIMD2<Float>, _ b: SIMD2<Float>, tolerance: Float = 1e-4) -> Bool {
        approxEqual(a.x, b.x, tolerance: tolerance)
            && approxEqual(a.y, b.y, tolerance: tolerance)
    }

    private func approxEqual(_ a: SIMD4<Float>, _ b: SIMD4<Float>, tolerance: Float = 1e-4) -> Bool {
        approxEqual(a.x, b.x, tolerance: tolerance)
            && approxEqual(a.y, b.y, tolerance: tolerance)
            && approxEqual(a.z, b.z, tolerance: tolerance)
            && approxEqual(a.w, b.w, tolerance: tolerance)
    }

    @Test("EffectPrimitiveID covers named constants and arbitrary raw IDs")
    func primitiveIDsAndDefaults() {
        #expect(EffectPrimitiveID.pp_2dtexture.rawValue == 0)
        #expect(EffectPrimitiveID.pp_particle_up.rawValue == 59)
        #expect(EffectPrimitiveID.pp_effecttexture_ani.rawValue == 128)
        let pulsingColumns = EffectPrimitiveID(rawValue: 60)
        #expect(EffectPrimitiveID.pp_particle_up < pulsingColumns)
        #expect(pulsingColumns < EffectPrimitiveID.pp_guard)

        let state = EffectPrimitiveState()
        #expect(state.slots.count == 4)
        #expect(state.records.count == 50)
        #expect(state.segPos.count == 4)
        #expect(state.arcAngle == 36.0)
        #expect(state.size == 1.0)
        #expect(state.alpha == 254.0)
        #expect(state.maxAlpha == 254.0)
        #expect(state.duration == 100)
        #expect(state.animSpeed == 4)
        #expect(state.repeatAnim)
    }

    @Test("Initialization, master detach, slot ticking, and sprite animation advance")
    func lifecycleAndAnimationHelpers() {
        let request = EffectSpawnRequest(effectID: .ef_heal, worldPosition: SIMD3<Float>(2, 1, -3))
        let host = RagEffect(id: UUID(), request: request, duration: 50)
        let prim = host.launchPrimitive(.pp_particle_up, deltaPos: SIMD3<Float>(1, -2, 3))

        #expect(prim.master === host)
        #expect(prim.state.count == 59)
        #expect(approxEqual(prim.position, EffectSpace.toEffectPosition(SIMD3<Float>(2, 1, -3))))
        #expect(approxEqual(prim.state.deltaPos, SIMD3<Float>(1, -2, 3)))

        host.position = SIMD3<Float>(10, -5, 20)
        prim.state.slots[0].life = 1
        prim.state.slots[1].life = 0
        prim.followMasterAndTickSlots()
        #expect(approxEqual(prim.position, SIMD3<Float>(10, -5, 20)))
        #expect(prim.state.slots[0].process == 1)
        #expect(prim.state.slots[1].process == 0)

        prim.spriteFrameCount = 2
        prim.state.animSpeed = 2
        prim.state.repeatAnim = false
        prim.state.stateCnt = 1
        #expect(prim.animMotion())
        #expect(prim.currentMotion == 0)
        prim.state.stateCnt = 2
        #expect(prim.animMotion())
        #expect(prim.currentMotion == 1)
        prim.state.stateCnt = 4
        #expect(!prim.animMotion())

        prim.detachMaster()
        #expect(prim.master == nil)
    }

    @Test("InitSegment and ShiftSegment shift history with alpha and scale decay")
    func segmentTrailShifting() {
        let prim = EffectPrimitive(id: .pp_3dparticle)
        prim.position = SIMD3<Float>(1, 2, 3)
        prim.state.numSegment = 4
        prim.state.alpha = 200
        prim.state.size = 8
        prim.state.red = 100
        prim.state.green = 150
        prim.state.blue = 200
        prim.initSegment()

        #expect(approxEqual(prim.state.records[3].position, SIMD3<Float>(1, 2, 3)))
        #expect(prim.state.records[0].color == 0xC86496C8)

        prim.position = SIMD3<Float>(5, 6, 7)
        prim.shiftSegment()

        #expect(approxEqual(prim.state.records[0].position, SIMD3<Float>(5, 6, 7)))
        #expect(approxEqual(prim.state.records[1].position, SIMD3<Float>(1, 2, 3)))
        #expect(approxEqual(prim.state.records[1].alpha, 150))
        #expect(approxEqual(prim.state.records[1].scale, 7))
        #expect(approxEqual(prim.state.records[2].alpha, 100))
        #expect(approxEqual(prim.state.records[2].scale, 6))
    }

    @Test("ProcessAlpha handles ping-pong, fadeOutCnt, and early master retirement")
    func processAlphaBehavior() {
        let request = EffectSpawnRequest(effectID: .ef_heal, worldPosition: .zero)
        let host = RagEffect(id: UUID(), request: request, duration: 100)
        let prim = host.launchPrimitive(.pp_3dtexture)
        prim.state.duration = 40
        prim.state.pattern = 0x80
        prim.state.alpha = 250
        prim.state.maxAlpha = 250
        prim.state.minAlpha = 10
        prim.state.alphaSpeed = 10

        // At maxAlpha with positive alphaSpeed and 0x80 flag -> reverses direction.
        prim.processAlpha()
        #expect(approxEqual(prim.state.alphaSpeed, -10))
        #expect(approxEqual(prim.state.alpha, 240))

        // Trigger fadeOutCnt at tick 30 (10 ticks remaining).
        prim.state.stateCnt = 30
        prim.state.fadeOutCnt = 30
        prim.state.alpha = 100
        prim.state.alphaDelta = 1.0
        prim.processAlpha()
        #expect((prim.state.pattern & 0x80) == 0)
        #expect(approxEqual(prim.state.alphaSpeed, -10))
        #expect(approxEqual(prim.state.alpha, 90))

        // Master ending sooner than primitive triggers isDisappear fadeout.
        let host2 = RagEffect(id: UUID(), request: request, duration: 20)
        host2.stateCnt = 10 // 10 ticks remaining
        let prim2 = host2.launchPrimitive(.pp_3dtexture)
        prim2.state.duration = 50
        prim2.state.stateCnt = 10 // 40 ticks remaining > 10 + 1
        prim2.state.alpha = 100
        prim2.state.alphaSpeed = 0
        prim2.processAlpha()
        #expect(prim2.state.isDisappear)
        #expect(approxEqual(prim2.state.alphaSpeed, -10))
        #expect(approxEqual(prim2.state.alpha, 90))
    }

    @Test("Angle lookup, FaceCamera, and Tei_TowardScreen transform corners accurately")
    func orientationHelpers() {
        #expect(EffectPrimitive.angle(dx: 1, dy: 0) == 0)
        // Because EffectSpace.clientPi = 3.141592 < pi, cosTable[90] is slightly positive (~3.3e-7),
        // so normalX == 0 first matches cosTable[91] just like the official client lookup.
        #expect(EffectPrimitive.angle(dx: 0, dy: 1) == 91)
        #expect(EffectPrimitive.angle(dx: -1, dy: 0) == 180)
        #expect(EffectPrimitive.angle(dx: 0, dy: -1) == 269)

        let world = RecordingWorldContext(cameraWorldPosition: SIMD3<Float>(0, 10, 20))
        world.cameraYawDegrees = 45
        world.cameraPitchDegrees = 30
        let prim = EffectPrimitive(id: .pp_particle_up)
        prim.faceCamera(world: world)
        #expect(prim.state.slots[0].alphaT == 315)
        #expect(prim.state.slots[1].alphaT == 60)

        var v1 = SIMD3<Float>(0, 0, 10)
        var v2 = SIMD3<Float>(0, 10, 0)
        var v3 = SIMD3<Float>(10, 0, 0)
        var v4 = SIMD3<Float>(-10, 0, 0)
        EffectPrimitive.towardScreen(&v1, &v2, &v3, &v4, rot0: 0, rot1: 90)
        // RotatePairX(+90): z' = -y, y' = z
        #expect(approxEqual(v1, SIMD3<Float>(0, 10, 0), tolerance: 1e-3))
        #expect(approxEqual(v2, SIMD3<Float>(0, 0, -10), tolerance: 1e-3))
        #expect(approxEqual(v3, SIMD3<Float>(10, 0, 0), tolerance: 1e-3))
        #expect(approxEqual(v4, SIMD3<Float>(-10, 0, 0), tolerance: 1e-3))
    }

    @Test("RenderTeiRect overloads submit expected quads, UVs, colors, and blend states")
    func renderTeiRectOverloads() {
        let request = EffectSpawnRequest(effectID: .ef_heal, worldPosition: SIMD3<Float>(1, 0, 0))
        let host = RagEffect(id: UUID(), request: request, duration: 50)
        let prim = host.launchPrimitive(.pp_3dcasting)

        var collector = EffectPrimitiveBatchCollector(fog: Fog())
        let p0 = SIMD3<Float>(0, 0, 0)
        let p1 = SIMD3<Float>(5, 0, 0)
        let p2 = SIMD3<Float>(5, -5, 0)
        let p3 = SIMD3<Float>(0, -5, 0)

        // Overload 1: additive (pw = 0), local coordinates added to prim.position = (5, 0, 0).
        prim.renderTeiRect(
            into: &collector,
            assets: nil,
            alpha: 128,
            v1: p0,
            v2: p1,
            v3: p2,
            v4: p3,
            blendSelector: 0,
            textureIndex: 0,
            isWorldPosition: false,
            red: 200,
            green: 100,
            blue: 50,
            extra: 2
        )

        #expect(collector.batches.count == 1)
        #expect(collector.batches[0].vertices.count == 6)
        #expect(collector.batches[0].renderState.srcBlend == .sourceAlpha)
        #expect(collector.batches[0].renderState.dstBlend == .one)
        #expect(collector.batches[0].renderState.depthBias > 0)
        // p0 + (5, 0, 0) -> world (1, 0, 0)
        #expect(approxEqual(collector.batches[0].vertices[0].position, SIMD3<Float>(1, 0, 0)))
        #expect(approxEqual(collector.batches[0].vertices[0].textureCoordinate, SIMD2<Float>(0, 1)))
        #expect(approxEqual(collector.batches[0].vertices[2].textureCoordinate, SIMD2<Float>(1, 0)))
        #expect(approxEqual(
            collector.batches[0].vertices[0].color,
            SIMD4<Float>(200.0 / 255.0, 100.0 / 255.0, 50.0 / 255.0, 128.0 / 255.0),
            tolerance: 1e-3
        ))

        // Overload 2: palette size = 100 -> dstBlend = 6, textureV = 0.9, horizontal slice texPart = 1.
        prim.state.size = 100
        host.colorChannels = [10, -1, -1, -1]
        prim.renderTeiRect(
            into: &collector,
            assets: nil,
            texPart: 1,
            alphaB: 255,
            alphaT: 255,
            v1: p0,
            v2: p1,
            v3: p2,
            v4: p3,
            textureIndex: 0
        )

        #expect(collector.batches.count == 2)
        #expect(collector.batches[1].renderState.dstBlend == .oneMinusSourceAlpha)
        #expect(approxEqual(collector.batches[1].vertices[0].textureCoordinate, SIMD2<Float>(1.0 / 21.0, 0.9)))
        #expect(approxEqual(collector.batches[1].vertices[1].textureCoordinate, SIMD2<Float>(2.0 / 21.0, 0.9)))
        // Red channel overridden to 10 by host.colorChannels[0].
        #expect(approxEqual(collector.batches[1].vertices[0].color.x, 10.0 / 255.0, tolerance: 1e-3))

        // Overload 3: custom RGB + vertical slice texPart = 0.
        host.colorChannels = [-1, -1, -1, -1]
        prim.renderTeiRect(
            into: &collector,
            assets: nil,
            texPart: 0,
            alphaB: 200,
            alphaT: 200,
            v1: p0,
            v2: p1,
            v3: p2,
            v4: p3,
            blendSelector: 1,
            red: 255,
            green: 0,
            blue: 128
        )

        #expect(collector.batches.count == 2) // Same alpha render state merges with batch 1
        let startIndex = 6
        #expect(approxEqual(collector.batches[1].vertices[startIndex].textureCoordinate, SIMD2<Float>(1, 0)))
        #expect(approxEqual(collector.batches[1].vertices[startIndex + 1].textureCoordinate, SIMD2<Float>(1, 1.0 / 21.0)))
        #expect(approxEqual(collector.batches[1].vertices[startIndex + 2].textureCoordinate, SIMD2<Float>(0, 1.0 / 21.0)))
    }

    @Test("RagEffect host coordinates 60Hz ticking, primitive batch collection, and lifecycle retirement in EffectManager")
    func ragEffectHostInEffectManager() {
        let world = RecordingWorldContext(cameraWorldPosition: SIMD3<Float>(0, 10, 20))
        let manager = EffectManager()

        manager.registerRagEffect(for: .ef_heal) { id, request in
            RagEffect(id: id, request: request, duration: 3) { effect, _ in
                if effect.stateCnt == 0 {
                    let prim = effect.launchPrimitive(.pp_particle_up)
                    prim.state.duration = 5
                    prim.customRender = { primitive, collector, _, assets in
                        primitive.renderTeiRect(
                            into: &collector,
                            assets: assets,
                            alpha: 255,
                            v1: SIMD3<Float>(0, 0, 0),
                            v2: SIMD3<Float>(5, 0, 0),
                            v3: SIMD3<Float>(5, -5, 0),
                            v4: SIMD3<Float>(0, -5, 0),
                            blendSelector: 0,
                            textureIndex: 0,
                            isWorldPosition: false,
                            red: 255,
                            green: 255,
                            blue: 255
                        )
                    }
                }
                return true
            }
        }

        let spawnID = manager.spawn(EffectSpawnRequest(effectID: .ef_heal, worldPosition: .zero))
        #expect(spawnID != nil)
        #expect(manager.hasEffects)

        // Tick 1: host launches primitive (prim.stateCnt becomes 1).
        manager.stepOneTick(world: world)
        let payloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(payloads.count == 1)
        #expect(payloads[0].vertices.count == 6)

        // Tick 2: host and primitive remain active.
        manager.stepOneTick(world: world)
        let ragEffect = manager.activeEffects.first as? RagEffect
        #expect(ragEffect != nil)
        #expect(ragEffect?.isMasterAlive == true)
        #expect(ragEffect?.primitives.count == 1)
        #expect(ragEffect?.primitives.first?.master === ragEffect)
        #expect(manager.hasEffects)

        // Tick 3: host retires at stateCnt == 3, detaching primitive, which retires on the same tick.
        manager.stepOneTick(world: world)
        #expect(ragEffect?.isMasterAlive == false)
        #expect(ragEffect?.primitives.isEmpty == true)
        #expect(!manager.hasEffects)
    }

    @Test("Screen2D projection mode, absolute screen mode, and strong-typed cooldownSkillID")
    func screen2DAndCooldownSkillID() {
        let world = RecordingWorldContext(cameraWorldPosition: SIMD3<Float>(0, 10, 20))
        let host = RagEffect(id: UUID(), request: EffectSpawnRequest(effectID: .ef_none, worldPosition: .zero), duration: 200)
        let ctx = EffectTickContext(world: world, assets: nil, currentTick: 0, usesMinimalEffects: false, onSpawnChild: { _ in })

        let p0 = host.launchPrimitive(.pp_2dtexture)
        p0.state.widthSize = 20
        p0.state.heightSize = 20
        p0.state.cooldownSkillID = 40_000 // Exceeds Int16.max without truncation
        p0.currentMotion = 2
        p0.tick(context: ctx)
        #expect(p0.state.slots[0].process == 999)
        #expect(p0.state.cooldownSkillID == 40_000)

        var anchoredCollector = EffectPrimitiveBatchCollector(fog: Fog())
        p0.currentMotion = 2
        p0.collectBatches(into: &anchoredCollector, world: world, assets: nil)
        #expect(p0.currentMotion == 2)
        #expect(anchoredCollector.batches.first?.mode == .screen2D)
        #expect(anchoredCollector.batches.reduce(0) { $0 + $1.vertices.count } == 6)

        p0.state.pattern |= 4
        var absoluteCollector = EffectPrimitiveBatchCollector(fog: Fog())
        p0.collectBatches(into: &absoluteCollector, world: world, assets: nil)
        #expect(absoluteCollector.batches.first?.mode == .screen2DAbsolute)
    }

    @Test("EffectSpriteAsset unified batching and multi-segment ACT/SPR trails")
    func spriteAssetUnifiedBatchingAndSegmentTrails() async throws {
        let particle1Spr = K2L("이팩트\\particle1.spr")
        let particle1Act = K2L("이팩트\\particle1.act")
        let particle7Spr = K2L("이팩트\\particle7.spr")
        let particle7Act = K2L("이팩트\\particle7.act")

        let assets: EffectAssetStore?
        let p1CellCount: Int
        let p7CellCount: Int
        if let device = MTLCreateSystemDefaultDevice() {
            let store = EffectAssetStore(device: device, resourceManager: .testing)
            let p1Asset = try #require(await store.preloadSpriteAsset(spritePath: particle1Spr, actionPath: particle1Act))
            let p7Asset = try #require(await store.preloadSpriteAsset(spritePath: particle7Spr, actionPath: particle7Act))
            p1CellCount = try #require(p1Asset.frame(actionIndex: 0, frameIndex: 0)?.cells.filter { $0.spriteIndex >= 0 }.count)
            p7CellCount = try #require(p7Asset.frame(actionIndex: 0, frameIndex: 0)?.cells.filter { $0.spriteIndex >= 0 }.count)
            #expect(p1CellCount > 0)
            #expect(p7CellCount > 0)
            assets = store
        } else {
            assets = nil
            p1CellCount = 0
            p7CellCount = 0
        }

        let world = RecordingWorldContext(cameraWorldPosition: SIMD3<Float>(0, 10, 20))

        // EF_STEAL (18): unified billboard3D sprite batching across 10 bouncing particles
        let stealManager = EffectManager(assetStore: assets)
        #expect(stealManager.spawn(EffectSpawnRequest(effectID: .ef_steal, worldPosition: .zero)) != nil)
        stealManager.stepOneTick(world: world)
        #expect(world.playedSoundNames == ["effect\\EF_Steal.wav"])
        let stealHost = stealManager.activeEffects.first as? RagEffect
        #expect(stealHost?.primitives.count == 10)
        #expect(stealHost?.primitives.allSatisfy { $0.id == .pp_3dparticlegravity } == true)
        if assets != nil {
            let stealPayloads = stealManager.collectPrimitivePayloads(fog: Fog(), world: world)
            #expect(stealPayloads.allSatisfy { $0.mode == .billboard3D })
            #expect(stealPayloads.reduce(0) { $0 + $1.vertices.count } == 10 * p7CellCount * 6)
        }

        // EF_SOULSTRIKE (15): 12-segment PP_3DPARTICLESPLINE trail
        world.playedSounds.removeAll()
        let soulManager = EffectManager(assetStore: assets)
        #expect(soulManager.spawn(
            EffectSpawnRequest(
                effectID: .ef_soulstrike,
                worldPosition: .zero,
                sourceWorldPosition: SIMD3<Float>(-5, 0, -5)
            )
        ) != nil)
        for _ in 0..<7 {
            soulManager.stepOneTick(world: world)
        }
        #expect(world.playedSoundNames == ["effect\\EF_SoulStrike.wav"])
        let soulHost = soulManager.activeEffects.first as? RagEffect
        #expect(soulHost?.primitives.count == 1)
        let missile = soulHost?.primitives.first
        #expect(missile?.id == .pp_3dparticlespline)
        #expect(missile?.state.numSegment == 12)
        if assets != nil {
            let soulPayloads = soulManager.collectPrimitivePayloads(fog: Fog(), world: world)
            #expect(soulPayloads.reduce(0) { $0 + $1.vertices.count } == 12 * p1CellCount * 6)
        }
    }

    @Test("Structured child spawn preserves targetObjectID/extraParams and keeps collectBatches read-only")
    func specialPrimitivesChildSpawnAndExtraParams() {
        let world = RecordingWorldContext(cameraWorldPosition: SIMD3<Float>(0, 10, 20))
        world.targets[110_000_042] = EffectTargetState(objectID: 110_000_042, worldPosition: [1, 0, 1])

        var spawned: [EffectSpawnRequest] = []
        let ctx = EffectTickContext(
            world: world,
            assets: nil,
            currentTick: 1,
            usesMinimalEffects: false,
            onSpawnChild: { spawned.append($0) }
        )

        let host = RagEffect(
            id: UUID(),
            request: EffectSpawnRequest(
                effectID: .ef_firstaid,
                worldPosition: .zero,
                ownerObjectID: 110_000_042,
                targetObjectID: 110_000_042,
                parameters: [12, 34, 56, 78],
                extraParams: SIMD3<Float>(8, 1, 0)
            )
        )
        #expect(host.deltaPos2 == SIMD3<Float>(8, 1, 0))
        #expect(host.param == [12, 34, 56, 78])

        // PP_SMA (120) spawns EF_SMA2 with structured extraParams on tick 8 and emits zero geometry
        let sma = host.launchPrimitive(.pp_sma)
        sma.state.deltaPos = SIMD3<Float>(20, 0, 0)
        sma.state.slots[0].life = 1
        sma.state.slots[0].flag1[0] = 0
        sma.state.slots[0].height[1] = 1.0
        sma.state.slots[0].targetObjectID = 110_000_042
        for _ in 0..<8 {
            sma.tick(context: ctx)
        }
        #expect(spawned.count == 1)
        #expect(spawned.first?.effectID == .ef_sma2)
        #expect(spawned.first?.targetObjectID == 110_000_042)
        #expect(spawned.first?.extraParams == SIMD3<Float>(8, 1, 0))
        var smaCollector = EffectPrimitiveBatchCollector(fog: Fog())
        sma.collectBatches(into: &smaCollector, world: world, assets: nil)
        #expect(smaCollector.batches.isEmpty)

        // PP_TANJI2 (97) spawns EF_AIRTEXTURE every 4 ticks
        spawned.removeAll()
        let tanji = host.launchPrimitive(.pp_tanji2)
        tanji.state.deltaPos = SIMD3<Float>(20, 0, 0)
        tanji.state.slots[0].life = 1
        tanji.state.slots[0].distance = 3.0
        tanji.state.slots[0].height[1] = 1.5
        tanji.state.slots[0].alphaB = 200
        tanji.state.slots[0].flag1[2] = 0
        for _ in 0..<4 {
            tanji.tick(context: ctx)
        }
        #expect(spawned.count == 1)
        #expect(spawned.first?.effectID == .ef_airtexture)

        // PP_SOULLINK (109) spawns EF_SOULLIGHT during tick (not collectBatches) using strong targetObjectID
        spawned.removeAll()
        let soulLink = host.launchPrimitive(.pp_soullink)
        soulLink.state.slots[0].life = 1
        soulLink.state.slots[0].distance = 3.0
        soulLink.state.slots[0].targetObjectID = 110_000_042
        soulLink.tick(context: ctx)
        #expect(spawned.count == 1)
        #expect(spawned.first?.effectID == .ef_soullight)
        #expect(spawned.first?.targetObjectID == 110_000_042)
        let spawnedBeforeRender = spawned.count
        var soulCollector = EffectPrimitiveBatchCollector(fog: Fog())
        soulLink.collectBatches(into: &soulCollector, world: world, assets: nil)
        #expect(spawned.count == spawnedBeforeRender)
        #expect(soulCollector.batches.reduce(0) { $0 + $1.vertices.count } == 6)
    }

    @Test("All 172 valid primitive IDs instantiate, tick, and collect finite geometry")
    func all172ValidPrimitiveIDsInstantiateTickAndCollect() {
        let world = RecordingWorldContext(cameraWorldPosition: SIMD3<Float>(0, 10, 20))
        world.targets[1] = EffectTargetState(objectID: 1, worldPosition: .zero, headHeight: 2.0, facingAngle: 0)
        let ctx = EffectTickContext(
            world: world,
            assets: nil,
            currentTick: 1,
            usesMinimalEffects: false,
            onSpawnChild: { _ in }
        )

        let skippedIDs: Set<Int> = [17, 83]
        var testedCount = 0

        for rawID in 0...173 where !skippedIDs.contains(rawID) {
            let host = RagEffect(
                id: UUID(),
                request: EffectSpawnRequest(effectID: .ef_firstaid, worldPosition: .zero, ownerObjectID: 1, targetObjectID: 1)
            )
            let prim = host.launchPrimitive(EffectPrimitiveID(rawValue: rawID))
            prim.state.duration = 120
            prim.state.totalTexture = 1
            prim.state.alpha = 200
            prim.state.size = 4.0
            prim.state.widthSize = 4.0
            prim.state.heightSize = 4.0
            prim.state.radius = 5.0
            prim.state.innerSize = 2.0
            prim.state.outerSize = 5.0
            prim.state.arcAngle = 45.0
            prim.state.slots[0].life = 1
            prim.state.slots[0].distance = 5.0
            prim.state.slots[0].maxHeight = 10.0
            prim.state.slots[0].alphaB = 120
            prim.state.slots[0].fullDisplayAngle = 360
            prim.state.slots[0].riseAngle = 90
            prim.state.slots[0].height[0] = 2.0
            prim.state.slots[0].height[1] = 2.0
            prim.state.slots[0].height[2] = 2.0
            prim.state.slots[0].vecBPre = SIMD3<Float>(0, -10, 0)
            prim.state.slots[0].vecBNow = SIMD3<Float>(0, -10, 0)
            prim.state.slots[0].vecTPre = SIMD3<Float>(0, -10, 0)
            prim.state.slots[0].vecTNow = SIMD3<Float>(1, 5, 1)
            prim.initSegment()

            prim.tick(context: ctx)
            var collector = EffectPrimitiveBatchCollector(fog: Fog())
            prim.collectBatches(into: &collector, world: world, assets: nil)
            for batch in collector.batches {
                for vertex in batch.vertices {
                    #expect(vertex.position.x.isFinite && vertex.position.y.isFinite && vertex.position.z.isFinite)
                    #expect(vertex.color.x.isFinite && vertex.color.y.isFinite && vertex.color.z.isFinite && vertex.color.w.isFinite)
                }
            }
            testedCount += 1
        }

        #expect(testedCount == 172)
    }
}
