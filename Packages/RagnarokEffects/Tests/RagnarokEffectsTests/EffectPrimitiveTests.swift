//
//  EffectPrimitiveTests.swift
//  RagnarokEffectsTests
//
//  Created by Leon Li on 2026/11/24.
//

import Foundation
import RagnarokRendering
import simd
import Testing
@testable import RagnarokEffects

@Suite("EffectPrimitive & RagEffect Host")
@MainActor
struct EffectPrimitiveTests {
    private final class MockWorldContext: EffectWorldContext {
        var cameraWorldPosition: SIMD3<Float> = SIMD3<Float>(0, 10, 20)
        var cameraYawDegrees: Float = 0
        var cameraPitchDegrees: Float = 0
        var targets: [EffectTargetID : EffectTargetState] = [:]
        var playedSounds: [String] = []

        func terrainHeight(atEffectX x: Float, effectZ z: Float) -> Float {
            0
        }

        func targetState(for targetID: EffectTargetID) -> EffectTargetState? {
            targets[targetID]
        }

        func playSound(named name: String, atWorldPosition position: SIMD3<Float>?, delay: TimeInterval) {
            playedSounds.append(name)
        }

        func shakeCamera(amplitude: Float, duration: TimeInterval, frequency: Float) {
        }

        func applyTargetModifier(_ modifier: EffectTargetModifier, to targetID: EffectTargetID) {
        }

        func spawnChildEffect(_ request: EffectSpawnRequest) {
        }
    }

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

        let world = MockWorldContext()
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
        let world = MockWorldContext()
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

    @Test("EF_HEAL vertical slice drives pulsing columns, rising particles, sound, and clean retirement")
    func healVerticalSlice() {
        #expect(EffectManager.hasBuiltInDefinition(for: .ef_heal))
        #expect(EffectManager.builtInEffectIDs.contains(.ef_heal))

        let world = MockWorldContext()
        world.cameraYawDegrees = 45
        world.cameraPitchDegrees = 25
        let manager = EffectManager()

        let spawnID = manager.spawn(EffectSpawnRequest(effectID: .ef_heal, worldPosition: SIMD3<Float>(2, 0, -1)))
        #expect(spawnID != nil)

        // Tick 1 (stateCnt == 0): launches primitive 60 (pulsing columns) and plays heal sound.
        manager.stepOneTick(world: world)
        #expect(world.playedSounds == ["_heal_effect.wav"])
        let ragEffect = manager.activeEffects.first as? RagEffect
        #expect(ragEffect?.primitives.count == 1)
        #expect(ragEffect?.primitives.first?.id == 60)
        #expect(ragEffect?.primitives.first?.state.size == 9.0)
        #expect(ragEffect?.primitives.first?.state.texturePaths == ["effect\\alpha_down.tga"])

        // 2 active slots * 20 casting segments = 40 quads = 240 vertices with green additive palette.
        let columnPayloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(columnPayloads.count == 1)
        #expect(columnPayloads[0].vertices.count == 40 * 6)
        #expect(columnPayloads[0].renderState.srcBlend == .sourceAlpha)
        #expect(columnPayloads[0].renderState.dstBlend == .one)
        #expect(approxEqual(columnPayloads[0].vertices[0].color.x, 140.0 / 255.0, tolerance: 1e-3))
        #expect(approxEqual(columnPayloads[0].vertices[0].color.y, 210.0 / 255.0, tolerance: 1e-3))
        #expect(approxEqual(columnPayloads[0].vertices[0].color.z, 140.0 / 255.0, tolerance: 1e-3))

        // Advance to tick 7 (stateCnt == 6): spawns first pp_particle_up burst.
        for _ in 0..<6 {
            manager.stepOneTick(world: world)
        }
        #expect(ragEffect?.primitives.count == 2)
        let particlePrim = ragEffect?.primitives.last
        #expect(particlePrim?.id == .pp_particle_up)
        #expect(particlePrim?.state.texturePaths == ["effect\\pok1.tga"])

        // Advance one more tick so pp_particle_up reaches process == 2 and alphaB == 15 (> 0).
        manager.stepOneTick(world: world)
        let combinedPayloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        let totalVertices = combinedPayloads.reduce(0) { $0 + $1.vertices.count }
        // 40 column quads + 4 rising particle quads = 44 quads = 264 vertices.
        #expect(totalVertices == 44 * 6)

        // Advance through remaining host lifetime (8 + 92 = 100 ticks); child primitives retire with host.
        for _ in 0..<92 {
            manager.stepOneTick(world: world)
        }
        #expect(!manager.hasEffects)
    }

    @Test("EF_HEAL3 uses white pulsing columns and dual-texture flashing rising particles")
    func heal3VerticalSlice() {
        #expect(EffectManager.hasBuiltInDefinition(for: .ef_heal3))
        #expect(EffectManager.builtInEffectIDs.contains(.ef_heal3))

        let world = MockWorldContext()
        let manager = EffectManager()

        let spawnID = manager.spawn(EffectSpawnRequest(effectID: .ef_heal3, worldPosition: .zero))
        #expect(spawnID != nil)

        // Tick 1: primitive 60 with size == 5 (white palette) and alphaT == 30.
        manager.stepOneTick(world: world)
        let ragEffect = manager.activeEffects.first as? RagEffect
        let columnPrim = ragEffect?.primitives.first
        #expect(columnPrim?.state.size == 5.0)
        #expect(columnPrim?.state.slots[0].alphaT == 30)
        #expect(columnPrim?.state.slots[1].alphaT == 30)

        let payloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(payloads.count == 1)
        #expect(approxEqual(payloads[0].vertices[0].color.x, 1.0, tolerance: 1e-3))
        #expect(approxEqual(payloads[0].vertices[0].color.y, 1.0, tolerance: 1e-3))
        #expect(approxEqual(payloads[0].vertices[0].color.z, 1.0, tolerance: 1e-3))

        // Advance to tick 7 (stateCnt == 6): spawns pp_particle_up with 2 textures and flash enabled.
        for _ in 0..<6 {
            manager.stepOneTick(world: world)
        }
        let particlePrim = ragEffect?.primitives.last
        #expect(particlePrim?.id == .pp_particle_up)
        #expect(particlePrim?.state.texturePaths == ["effect\\pok1.tga", "effect\\pok3.tga"])
        #expect(particlePrim?.state.slots[0].flag1[1] == 1)

        // Slot 3 has flash = 36 - 3 * 7 = 15, so at process == 14 (13 ticks after spawn tick 7) flag1[0] flips to 1.
        for _ in 0..<13 {
            manager.stepOneTick(world: world)
        }
        #expect(particlePrim?.state.slots[3].process == 14)
        #expect(particlePrim?.state.slots[3].flag1[0] == 1)

        // Verify limit = 25 stops spawning new particle bursts after stateCnt > 25 (ticks 6, 12, 18, 24 => 4 bursts + 1 column = 5).
        for _ in 0..<20 {
            manager.stepOneTick(world: world)
        }
        #expect(ragEffect?.primitives.count == 5)
    }

    @Test("EF_ENTRY spawns dual counter-rotating 3D cylinders, renders 18 arc-band quads, and retires cleanly")
    func entryVerticalSlice() {
        #expect(EffectManager.hasBuiltInDefinition(for: .ef_entry))
        #expect(EffectManager.builtInEffectIDs.contains(.ef_entry))

        let world = MockWorldContext()
        let manager = EffectManager()

        let spawnID = manager.spawn(EffectSpawnRequest(effectID: .ef_entry, worldPosition: SIMD3<Float>(1, 0, 2)))
        #expect(spawnID != nil)

        // Tick 1: launches outer (arcAngle 36 => 10 quads) and inner (arcAngle 45 => 8 quads) pp_3dcylinder.
        manager.stepOneTick(world: world)
        let ragEffect = manager.activeEffects.first as? RagEffect
        #expect(ragEffect?.primitives.count == 2)
        let outer = ragEffect?.primitives[0]
        let inner = ragEffect?.primitives[1]
        #expect(outer?.id == .pp_3dcylinder)
        #expect(inner?.id == .pp_3dcylinder)
        #expect(outer?.state.texturePaths == ["effect\\ring_blue.tga"])
        #expect(inner?.state.texturePaths == ["effect\\ring_blue.tga"])
        #expect(outer?.state.arcAngle == 36.0)
        #expect(inner?.state.arcAngle == 45.0)
        // Prim3DCylinder adds longSpeed to longitude twice per tick (-20 and +20 on tick 1).
        #expect(approxEqual(outer?.state.longitude ?? 0, -20.0))
        #expect(approxEqual(inner?.state.longitude ?? 0, 20.0))
        #expect(approxEqual(outer?.state.outerSize ?? 0, 6.08))
        #expect(approxEqual(outer?.state.heightSize ?? 0, 6.4))

        let payloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(payloads.count == 1)
        #expect(payloads[0].vertices.count == 18 * 6)
        #expect(payloads[0].renderState.srcBlend == .sourceAlpha)
        #expect(payloads[0].renderState.dstBlend == .oneMinusSourceAlpha)
        #expect(payloads[0].renderState.depthTest == true)

        // Both cylinders have duration 55; after 56 total ticks (stateCnt > 55) they retire while host retires at default lifetime.
        for _ in 0..<55 {
            manager.stepOneTick(world: world)
        }
        #expect(ragEffect?.primitives.isEmpty == true)

        for _ in 0..<100 {
            manager.stepOneTick(world: world)
        }
        #expect(!manager.hasEffects)
    }

    @Test("EF_WATERBALL3 drives two 3D circle rings and one 3D sphere with distinct lifetimes and render flags")
    func waterBall3VerticalSlice() {
        #expect(EffectManager.hasBuiltInDefinition(for: .ef_waterball3))
        #expect(EffectManager.builtInEffectIDs.contains(.ef_waterball3))

        let world = MockWorldContext()
        let manager = EffectManager()

        let spawnID = manager.spawn(EffectSpawnRequest(effectID: .ef_waterball3, worldPosition: .zero))
        #expect(spawnID != nil)

        // Tick 1: plays waterball sound and launches ring1 (dur 30), sphere (dur 30), ring2 (dur 20).
        manager.stepOneTick(world: world)
        #expect(world.playedSounds == ["effect\\wizard_waterball_chulung.wav"])
        let ragEffect = manager.activeEffects.first as? RagEffect
        #expect(ragEffect?.primitives.count == 3)
        #expect(ragEffect?.primitives[0].id == .pp_3dcircle)
        #expect(ragEffect?.primitives[1].id == .pp_3dsphere)
        #expect(ragEffect?.primitives[2].id == .pp_3dcircle)

        // Two no-depth rings (10 quads each = 20 quads) + one depth-tested sphere (5 * 10 = 50 quads) = 70 quads.
        let payloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        let totalVertices = payloads.reduce(0) { $0 + $1.vertices.count }
        #expect(totalVertices == 70 * 6)
        let noDepthVertices = payloads.filter { !$0.renderState.depthTest }.reduce(0) { $0 + $1.vertices.count }
        let depthVertices = payloads.filter { $0.renderState.depthTest }.reduce(0) { $0 + $1.vertices.count }
        #expect(noDepthVertices == 20 * 6)
        #expect(depthVertices == 50 * 6)

        // At 20 total ticks (stateCnt == 20), secondRing (duration 20) is still alive; it retires at tick 21 (stateCnt > 20).
        for _ in 0..<19 {
            manager.stepOneTick(world: world)
        }
        #expect(ragEffect?.primitives.count == 3)

        manager.stepOneTick(world: world)
        #expect(ragEffect?.primitives.count == 2)
        let remainingPayloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        let remainingVertices = remainingPayloads.reduce(0) { $0 + $1.vertices.count }
        #expect(remainingVertices == 60 * 6)

        // At 30 total ticks (stateCnt == 30), ring1 and sphere remain alive; all 3 primitives retire at tick 31 (stateCnt > 30).
        for _ in 0..<9 {
            manager.stepOneTick(world: world)
        }
        #expect(ragEffect?.primitives.count == 2)

        manager.stepOneTick(world: world)
        #expect(ragEffect?.primitives.isEmpty == true)
    }

    @Test("PP_3DCYLINDERHALF advances longitude once per tick and shrinks outerSize at fadeOutCnt")
    func cylinderHalfMotion() {
        let request = EffectSpawnRequest(effectID: .ef_entry, worldPosition: .zero)
        let host = RagEffect(id: UUID(), request: request, duration: 50)
        let prim = host.launchPrimitive(.pp_3dcylinderhalf)
        prim.state.duration = 20
        prim.state.fadeOutCnt = 10
        prim.state.pattern = 1
        prim.state.longSpeed = 5.0
        prim.state.outerSize = 11.0
        prim.state.outerSpeed = 0
        prim.state.heightSize = 4.0
        prim.state.heightSpeed = 1.0
        prim.state.maxHeightSize = 4.5

        let context = EffectTickContext(
            world: MockWorldContext(),
            assets: nil,
            currentTick: 0,
            usesMinimalEffects: false,
            onSpawnChild: { _ in }
        )
        prim.tick(context: context)
        #expect(prim.isAlive)
        // Longitude advances once per tick (not twice like pp_3dcylinder), and heightSize clamps to maxHeightSize.
        #expect(approxEqual(prim.state.longitude, 5.0))
        #expect(approxEqual(prim.state.heightSize, 4.5))

        // Advance to stateCnt == fadeOutCnt (10): pattern & 1 sets outerSpeed = -(outerSize / (20 - 10 + 1)) = -1.0.
        prim.state.stateCnt = 10
        prim.prim3DCylinderHalf()
        #expect(approxEqual(prim.state.outerSpeed, -1.0))
        #expect(approxEqual(prim.state.outerSize, 11.0))

        // Next tick shrinks outerSize by 1.0.
        prim.prim3DCylinderHalf()
        #expect(approxEqual(prim.state.outerSize, 10.0))
    }

    @Test("EF_GUARD drives a 3-layer 5x3 sphere cage with dual textures and post-tick-26 spread")
    func guardVerticalSlice() {
        #expect(EffectManager.hasBuiltInDefinition(for: .ef_guard))
        #expect(EffectManager.builtInEffectIDs.contains(.ef_guard))

        let world = MockWorldContext()
        world.targets[1] = EffectTargetState(objectID: 1, worldPosition: .zero, facingAngle: 45)
        let manager = EffectManager()

        let spawnID = manager.spawn(EffectSpawnRequest(effectID: .ef_guard, worldPosition: .zero, targetObjectID: 1))
        #expect(spawnID != nil)

        // Tick 1: plays guard sound and spawns pp_guard with 2 textures.
        manager.stepOneTick(world: world)
        #expect(world.playedSounds == ["effect\\kyrie_guard.wav"])
        let ragEffect = manager.activeEffects.first as? RagEffect
        #expect(ragEffect?.primitives.count == 1)
        let guardPrim = ragEffect?.primitives[0]
        #expect(guardPrim?.id == .pp_guard)
        #expect(guardPrim?.state.texturePaths == ["effect\\guardK.tga", "effect\\guardK2.tga"])
        #expect(guardPrim?.state.slots[0].rotStart == 315)
        #expect(guardPrim?.state.slots[0].alphaB == 20)

        // 3 lat rows * 5 lon columns * 3 concentric layers = 45 quads = 270 vertices.
        let payloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        let totalVertices = payloads.reduce(0) { $0 + $1.vertices.count }
        #expect(totalVertices == 45 * 6)

        // Advance past tick 26 so outer layer spreads (height[0] += 0.1) and fades out.
        for _ in 0..<26 {
            manager.stepOneTick(world: world)
        }
        #expect(guardPrim?.state.slots[0].process == 27)
        #expect(approxEqual(guardPrim?.state.slots[0].height[0] ?? 0, 0.1))
        #expect(guardPrim?.state.slots[0].alphaB == 94)
    }

    @Test("EF_GRANDCROSS2 spawns corner casting rings (pp_gi_3) and cross pillars (pp_grandcross2)")
    func grandCross2VerticalSlice() {
        #expect(EffectManager.hasBuiltInDefinition(for: .ef_grandcross2))
        #expect(EffectManager.builtInEffectIDs.contains(.ef_grandcross2))

        let world = MockWorldContext()
        let manager = EffectManager()

        let spawnID = manager.spawn(EffectSpawnRequest(effectID: .ef_grandcross2, worldPosition: .zero))
        #expect(spawnID != nil)

        // Tick 1: plays sound, launches pp_gi_3 (4 slots) and pp_grandcross2 (2 slots).
        manager.stepOneTick(world: world)
        #expect(world.playedSounds == ["effect\\cru_grand cross.wav"])
        let ragEffect = manager.activeEffects.first as? RagEffect
        #expect(ragEffect?.primitives.count == 2)
        #expect(ragEffect?.primitives[0].id == .pp_gi_3)
        #expect(ragEffect?.primitives[1].id == .pp_grandcross2)

        // pp_gi_3: 4 slots * 8 segments (90 / 10 = 9 steps, order 1..8) = 32 quads.
        // pp_grandcross2: 2 slots * 6 faces (4 sides + 2 caps) = 12 quads.
        // Total = 44 quads = 264 vertices.
        let payloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        let totalVertices = payloads.reduce(0) { $0 + $1.vertices.count }
        #expect(totalVertices == 44 * 6)

        // Verify cross pillars expand width/length and fade out smoothly after tick 10.
        for _ in 0..<9 {
            manager.stepOneTick(world: world)
        }
        let crossPrim = ragEffect?.primitives[1]
        #expect(crossPrim?.state.slots[0].process == 10)
        #expect(crossPrim?.state.slots[0].alphaB == 80)
        #expect(approxEqual(crossPrim?.state.slots[0].height[0] ?? 0, 24.05, tolerance: 1e-3))
    }

    @Test("Group B casting variants, pp_halfsphere, and pp_hermode update state and emit expected geometry")
    func groupBCastingHalfSphereAndHermode() {
        let world = MockWorldContext()
        world.targets[1] = EffectTargetState(objectID: 1, worldPosition: .zero, facingAngle: 30)
        let request = EffectSpawnRequest(effectID: .ef_guard, worldPosition: .zero, targetObjectID: 1)
        let host = RagEffect(id: UUID(), request: request, duration: 80)
        let context = EffectTickContext(
            world: world,
            assets: nil,
            currentTick: 0,
            usesMinimalEffects: false,
            onSpawnChild: { _ in }
        )

        // pp_3dcasting_4 (inward shrinking ring) & pp_3dcasting_5 (outward expanding wave).
        let cast4 = host.launchPrimitive(.pp_3dcasting_4)
        cast4.state.slots[0].life = 1
        cast4.state.slots[0].fullDisplayAngle = 360
        cast4.state.slots[0].distance = 5.0
        cast4.tick(context: context)
        #expect(approxEqual(cast4.state.slots[0].distance, 4.95))
        #expect(cast4.state.slots[0].alphaB == 1)
        var castCollector = EffectPrimitiveBatchCollector(fog: Fog())
        cast4.collectBatches(into: &castCollector, world: world, assets: nil)
        #expect(castCollector.batches.reduce(0) { $0 + $1.vertices.count } == 20 * 6)

        let cast5 = host.launchPrimitive(.pp_3dcasting_5)
        cast5.state.slots[0].life = 1
        cast5.state.slots[0].fullDisplayAngle = 360
        cast5.state.slots[0].distance = 4.0
        cast5.tick(context: context)
        #expect(approxEqual(cast5.state.slots[0].distance, 4.1))
        #expect(approxEqual(cast5.state.slots[0].maxHeight, 2.2))
        #expect(cast5.state.slots[0].alphaB == 2)

        // pp_halfsphere: 10 lat rings (0..<180 step 18) * 10 lon segments = 100 quads = 600 vertices.
        let halfSphere = host.launchPrimitive(.pp_halfsphere)
        halfSphere.state.slots[0].life = 1
        halfSphere.state.slots[0].fullDisplayAngle = 360
        halfSphere.state.slots[0].distance = 10.0
        halfSphere.state.slots[0].maxHeight = 5.0
        halfSphere.tick(context: context)
        #expect(halfSphere.state.slots[0].rotStart == 210)
        #expect(halfSphere.state.slots[0].alphaB == 5)
        var halfCollector = EffectPrimitiveBatchCollector(fog: Fog())
        halfSphere.collectBatches(into: &halfCollector, world: world, assets: nil)
        #expect(halfCollector.batches.reduce(0) { $0 + $1.vertices.count } == 100 * 6)

        // pp_hermode: rotating 6-face cube = 6 quads = 36 vertices.
        let hermode = host.launchPrimitive(.pp_hermode)
        hermode.state.slots[0].life = 1
        hermode.state.slots[0].distance = 8.0
        hermode.state.slots[0].flag1[0] = 100
        hermode.tick(context: context)
        #expect(hermode.state.slots[0].alphaB == 2)
        #expect(hermode.state.slots[0].rotStart == 1)
        #expect(hermode.state.slots[0].riseAngle == 1)
        var hermodeCollector = EffectPrimitiveBatchCollector(fog: Fog())
        hermode.collectBatches(into: &hermodeCollector, world: world, assets: nil)
        #expect(hermodeCollector.batches.reduce(0) { $0 + $1.vertices.count } == 6 * 6)
    }

    @Test("PP_HEAL_LOW ticks pulsing columns and renders 10-segment low-polygon casting with camera offset")
    func healLowPolygonCasting() {
        let world = MockWorldContext()
        world.cameraYawDegrees = 90
        let request = EffectSpawnRequest(effectID: .ef_heal, worldPosition: .zero)
        let host = RagEffect(id: UUID(), request: request, duration: 80)
        let context = EffectTickContext(
            world: world,
            assets: nil,
            currentTick: 0,
            usesMinimalEffects: false,
            onSpawnChild: { _ in }
        )

        let healLow = host.launchPrimitive(.pp_heal_low)
        healLow.state.size = 10.0
        healLow.state.slots[0].life = 1
        healLow.state.slots[0].fullDisplayAngle = 360
        healLow.state.slots[0].maxHeight = 12.0
        healLow.state.slots[0].rotStart = 0
        healLow.state.slots[0].distance = 2.0
        healLow.state.slots[0].riseAngle = 90
        healLow.state.slots[0].alphaT = 50
        healLow.state.slots[0].vecBNow = SIMD3<Float>(4.0, 1234.5, 0.0)
        healLow.state.slots[0].flag1 = Array(repeating: 33, count: 21)

        healLow.tick(context: context)
        #expect(healLow.state.slots[2].alphaT == 270)
        #expect(healLow.state.slots[0].process == 1)
        #expect(healLow.state.slots[0].alphaB == 5)

        var collector = EffectPrimitiveBatchCollector(fog: Fog())
        healLow.collectBatches(into: &collector, world: world, assets: nil)
        #expect(collector.batches.count == 1)
        #expect(collector.batches[0].vertices.count == 10 * 6)
        // First quad starts at effect-space (2.0, 0, 0) shifted by vecBNow (4, 0) rotated 270 deg -> effect (2.0, 0, -4.0) -> world (0.4, 0, 0.8).
        #expect(approxEqual(collector.batches[0].vertices[0].position, SIMD3<Float>(0.4, 0.0, 0.8), tolerance: 1e-3))
    }

    @Test("PP_BOTTOM and PP_BOTTOMOUT drive whistle and rokisweil ground particles")
    func bottomAndBottomOutEffects() {
        let world = MockWorldContext()
        world.cameraYawDegrees = 90
        world.cameraPitchDegrees = 30
        let manager = EffectManager()

        // EF_BOTTOM_WHISTLE (PP_BOTTOM)
        #expect(EffectManager.hasBuiltInDefinition(for: .ef_bottom_whistle))
        let whistleID = manager.spawn(EffectSpawnRequest(effectID: .ef_bottom_whistle, worldPosition: SIMD3<Float>(1, 0, 2)))
        #expect(whistleID != nil)
        manager.stepOneTick(world: world)

        let whistleHost = manager.activeEffects.first as? RagEffect
        let bottomPrim = whistleHost?.primitives.first
        #expect(bottomPrim?.id == .pp_bottom)
        #expect(bottomPrim?.state.texturePaths == ["effect\\melody_b.bmp"])
        #expect(bottomPrim?.state.slots[0].process == 1)
        #expect(approxEqual(bottomPrim?.state.slots[0].height[8] ?? 0, 5.0))
        #expect(bottomPrim?.state.slots[0].alphaB == 200)

        let bottomPayloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(bottomPayloads.count == 1)
        #expect(bottomPayloads[0].vertices.count == 6)

        // Advance 5 more ticks so slot 0 reaches process == 6 (trailing copy block) and remains alive.
        for _ in 0..<5 {
            manager.stepOneTick(world: world)
        }
        #expect(bottomPrim?.state.slots[0].process == 6)
        #expect(approxEqual(bottomPrim?.state.slots[0].height[8] ?? 0, 30.0))

        // EF_BOTTOM_ROKISWEIL (PP_BOTTOMOUT)
        #expect(EffectManager.hasBuiltInDefinition(for: .ef_bottom_rokisweil))
        let rokisID = manager.spawn(EffectSpawnRequest(effectID: .ef_bottom_rokisweil, worldPosition: .zero))
        #expect(rokisID != nil)
        manager.stepOneTick(world: world)
        let rokisHost = manager.activeEffects.last as? RagEffect
        let bottomOutPrim = rokisHost?.primitives.first
        #expect(bottomOutPrim?.id == .pp_bottomout)
        #expect(bottomOutPrim?.state.texturePaths == ["effect\\safeline.bmp"])
        #expect(bottomOutPrim?.state.slots[0].life == 1)
        #expect(bottomOutPrim?.state.slots[1].life == 1)
    }

    @Test("PP_BOTTOM2 renders color planes across dissonance and assassincross")
    func bottom2ColorPlanes() {
        let world = MockWorldContext()
        let manager = EffectManager()

        let dissID = manager.spawn(EffectSpawnRequest(effectID: .ef_bottom_dissonance, worldPosition: .zero))
        #expect(dissID != nil)
        manager.stepOneTick(world: world)
        let dissHost = manager.activeEffects.first as? RagEffect
        let dissPrim = dissHost?.primitives.first
        #expect(dissPrim?.id == .pp_bottom2)
        #expect(dissPrim?.state.texturePaths == ["effect\\ring_blue.tga"])
        #expect(dissPrim?.state.slots[0].height[0] == 0)

        let dissPayloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(dissPayloads.count == 1)
        #expect(dissPayloads[0].vertices.count == 4 * 6)
        #expect(dissPayloads[0].renderState.dstBlend == .one)

        // EF_BOTTOM_ASSASSINCROSS uses kind == 1 -> custom alpha blend (pw == 1 -> d3dBlend 6 -> oneMinusSourceAlpha) & 4 deg/tick
        let crossID = manager.spawn(EffectSpawnRequest(effectID: .ef_bottom_assassincross, worldPosition: .zero))
        #expect(crossID != nil)
        let crossHost = manager.activeEffects.last as? RagEffect
        manager.stepOneTick(world: world)
        let crossPrim = crossHost?.primitives.first
        #expect(crossPrim?.state.slots[0].height[0] == 1.0)
        let initialAngle = crossPrim?.state.slots[0].fullDisplayAngle ?? 0
        manager.stepOneTick(world: world)
        let nextAngle = crossPrim?.state.slots[0].fullDisplayAngle ?? 0
        #expect((Int(nextAngle) - Int(initialAngle) + 360) % 360 == 4)
    }

    @Test("PP_RECT_UP and PP_RECT_UP2 emit rising pulse columns and fading perimeter boxes")
    func rectUpAndRectUp2() {
        let world = MockWorldContext()
        let manager = EffectManager()

        // EF_BOTTOM_FOGWALL -> PP_RECT_UP kind 2 (4 walls + 2 cross planes = 6 quads)
        let fogWallID = manager.spawn(EffectSpawnRequest(effectID: .ef_bottom_fogwall, worldPosition: .zero))
        #expect(fogWallID != nil)
        manager.stepOneTick(world: world)
        let fogHost = manager.activeEffects.first as? RagEffect
        let fogPrim = fogHost?.primitives.first
        #expect(fogPrim?.id == .pp_rect_up)
        #expect(fogPrim?.state.texturePaths == ["effect\\ring_white.tga"])
        #expect(fogPrim?.state.slots[0].height[2] ?? 0 > 0)

        let fogPayloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(fogPayloads.count == 1)
        #expect(fogPayloads[0].vertices.count == 6 * 6)

        // Minimal effect scales EF_BOTTOM_MAG maxHeight from 50 to 10
        let minManager = EffectManager(usesMinimalEffects: true)
        let magMinID = minManager.spawn(EffectSpawnRequest(effectID: .ef_bottom_mag, worldPosition: .zero))
        #expect(magMinID != nil)
        minManager.stepOneTick(world: world)
        let magHost = minManager.activeEffects.first as? RagEffect
        #expect(approxEqual(magHost?.primitives.first?.state.slots[0].maxHeight ?? 0, 10.0))

        // EF_BOTTOM_BASILICA -> two PP_RECT_UP2 primitives (slots 0..1: 8 walls; slots 2..3: 2 sliding ribbon quads)
        let basManager = EffectManager()
        let basID = basManager.spawn(EffectSpawnRequest(effectID: .ef_bottom_basilica, worldPosition: .zero))
        #expect(basID != nil)
        basManager.stepOneTick(world: world)
        let basHost = basManager.activeEffects.first as? RagEffect
        #expect(basHost?.primitives.count == 2)
        #expect(basHost?.primitives[0].id == .pp_rect_up2)
        #expect(basHost?.primitives[1].id == .pp_rect_up2)
        #expect(approxEqual(basHost?.primitives[0].state.slots[2].distance ?? 0, 0.5))

        let basPayloads = basManager.collectPrimitivePayloads(fog: Fog(), world: world)
        let basVertices = basPayloads.reduce(0) { $0 + $1.vertices.count }
        // 2 primitives * (8 walls + 4 ribbon quads: slot 2 wraps corner 1 => 2 quads, slot 3 wraps corner 3 => 2 quads) = 24 quads
        #expect(basVertices == 24 * 6)

        // Verify moving master triggers early FadeColumnHeight when height[4] >= 20
        let request = EffectSpawnRequest(effectID: .ef_bottom_basilica, worldPosition: .zero)
        let movingHost = RagEffect(id: UUID(), request: request, duration: 300)
        let colPrim = movingHost.launchPrimitive(.pp_rect_up2)
        colPrim.state.slots[0].life = 1
        colPrim.state.slots[0].process = 200
        colPrim.state.slots[0].alphaT = 2400
        colPrim.state.slots[0].maxHeight = 20
        colPrim.state.slots[0].height[4] = 20
        movingHost.position = SIMD3<Float>(10, 0, 0)
        let ctx = EffectTickContext(world: world, assets: nil, currentTick: 0, usesMinimalEffects: false, onSpawnChild: { _ in })
        colPrim.tick(context: ctx)
        #expect(colPrim.state.slots[0].alphaT == 201)
    }

    @Test("PP_MAGNUM2 emits radial shockwave waves with timed audio and retirement")
    func magnum2Effect() {
        let world = MockWorldContext()
        let manager = EffectManager()

        let spawnID = manager.spawn(EffectSpawnRequest(effectID: .ef_magnum2, worldPosition: .zero))
        #expect(spawnID != nil)
        let host = manager.activeEffects.first as? RagEffect

        // Advance through stateCnt 0..27 (28 ticks); stateCnt 20 plays permeter_attack, stateCnt 27 (27 % 3 == 0) spawns first PP_MAGNUM2.
        for _ in 0..<28 {
            manager.stepOneTick(world: world)
        }
        #expect(world.playedSounds == ["permeter_attack.wav"])
        #expect(host?.primitives.count == 1)
        let prim = host?.primitives.first
        #expect(prim?.id == .pp_magnum2)
        #expect(prim?.state.slots[0].alphaB == 10)
        #expect(prim?.state.slots[1].alphaB == 5)

        // Each active slot (2) emits 20 texPart quads => 40 quads.
        let payloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(payloads.reduce(0) { $0 + $1.vertices.count } == 40 * 6)

        // Advance 10 more ticks: stateCnt 30 plays EF_MagnumBreak.wav, spawns waves at 30/33/36, and first prim fades all slots out.
        for _ in 0..<10 {
            manager.stepOneTick(world: world)
        }
        #expect(world.playedSounds == ["permeter_attack.wav", "effect\\EF_MagnumBreak.wav"])
        #expect(prim?.state.slots[0].life == 0)
        #expect(prim?.state.slots[1].life == 0)
    }

    @Test("PP_HITLINE and PP_HITLINE3 trace bouncing and short spark triangular prisms")
    func hitLineAndHitLine3() {
        let world = MockWorldContext()

        // EF_HITLINE (PP_HITLINE) spawns 1 primitive on ticks 0..3
        let manager = EffectManager()
        let hitID = manager.spawn(EffectSpawnRequest(effectID: .ef_hitline, worldPosition: .zero))
        #expect(hitID != nil)
        manager.stepOneTick(world: world)
        let hitHost = manager.activeEffects.first as? RagEffect
        #expect(hitHost?.primitives.count == 1)
        let hitPrim = hitHost?.primitives.first
        #expect(hitPrim?.id == .pp_hitline)

        // Drive past negative staggered process for deterministic prism geometry check
        for slot in 0..<4 {
            hitPrim?.state.slots[slot].process = 0
        }
        let ctx = EffectTickContext(world: world, assets: nil, currentTick: 0, usesMinimalEffects: false, onSpawnChild: { _ in })
        hitPrim?.tick(context: ctx)
        #expect(approxEqual(hitPrim?.state.slots[0].height[0] ?? 0, 8.0))
        #expect(approxEqual(hitPrim?.state.slots[0].height[1] ?? 0, 8.0))

        var collector = EffectPrimitiveBatchCollector(fog: Fog())
        hitPrim?.collectBatches(into: &collector, world: world, assets: nil)
        // 4 slots * 20 segments * 3 prism faces = 240 quads max (depends on segment alpha > 0)
        #expect(collector.batches.reduce(0) { $0 + $1.vertices.count } > 0)

        // EF_HITLINE6 (PP_HITLINE3 kind 3 -> double concentric prism)
        let manager3 = EffectManager()
        let hl6ID = manager3.spawn(EffectSpawnRequest(effectID: .ef_hitline6, worldPosition: .zero))
        #expect(hl6ID != nil)
        manager3.stepOneTick(world: world)
        let hl6Host = manager3.activeEffects.first as? RagEffect
        let hl6Prim = hl6Host?.primitives.first
        #expect(hl6Prim?.id == .pp_hitline3)
        #expect(hl6Prim?.state.slots[0].vecTNow.y == 4.0)
        for slot in 0..<4 {
            hl6Prim?.state.slots[slot].process = 1
        }
        hl6Prim?.tick(context: ctx)
        var hl6Collector = EffectPrimitiveBatchCollector(fog: Fog())
        hl6Prim?.collectBatches(into: &hl6Collector, world: world, assets: nil)
        // 4 slots * 4 segments * 2 prisms (inner + outer blue) * 3 faces = 96 quads = 576 vertices
        #expect(hl6Collector.batches.reduce(0) { $0 + $1.vertices.count } == 96 * 6)
    }

    @Test("PP_SLASH1 and PP_LINELINK render slash fans and target-tracking tubes")
    func slash1AndLineLink() {
        let world = MockWorldContext()

        // EF_KAIZEL spawns two PP_SLASH1 primitives at stateCnt == 15
        let slashManager = EffectManager()
        let kaizelID = slashManager.spawn(EffectSpawnRequest(effectID: .ef_kaizel, worldPosition: .zero))
        #expect(kaizelID != nil)
        for _ in 0..<16 {
            slashManager.stepOneTick(world: world)
        }
        let kaizelHost = slashManager.activeEffects.first as? RagEffect
        #expect(kaizelHost?.primitives.count == 2)
        #expect(kaizelHost?.primitives[0].id == .pp_slash1)
        #expect(kaizelHost?.primitives[1].id == .pp_slash1)

        // Each primitive has 4 slots * 3 fan quads = 12 quads => 24 quads total
        let slashPayloads = slashManager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(slashPayloads.reduce(0) { $0 + $1.vertices.count } == 24 * 6)

        // EF_LINELINK2 tracks sourceObjectID -> owner/target world position and retires if target disappears
        world.targets[1] = EffectTargetState(objectID: 1, worldPosition: .zero, facingAngle: 0)
        world.targets[2] = EffectTargetState(objectID: 2, worldPosition: SIMD3<Float>(10, 0, 5), facingAngle: 0)
        let linkManager = EffectManager()
        let linkID = linkManager.spawn(
            EffectSpawnRequest(
                effectID: .ef_linelink2,
                worldPosition: .zero,
                targetObjectID: 1,
                sourceObjectID: 2
            )
        )
        #expect(linkID != nil)
        linkManager.stepOneTick(world: world)
        #expect(world.playedSounds == ["effect\\소울 체인지.wav"])

        let linkHost = linkManager.activeEffects.first as? RagEffect
        let linkPrim = linkHost?.primitives.first
        #expect(linkPrim?.id == .pp_linelink)
        #expect(linkPrim?.state.slots[0].life == 1)
        #expect(linkPrim?.state.slots[0].alphaB == 6)

        // 2 passes * 10 tube steps = 20 quads = 120 vertices
        let linkPayloads = linkManager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(linkPayloads.reduce(0) { $0 + $1.vertices.count } == 20 * 6)

        // Removing target actor retires the link cleanly on the next tick
        world.targets.removeValue(forKey: 2)
        linkManager.stepOneTick(world: world)
        #expect(linkPrim?.state.slots[0].life == 0)
        #expect(linkPrim?.state.slots[0].alphaB == 0)
    }

    @Test("Arc primitives (137/144/146/149/158/160/173) and EF_BEGINSPELL_N1")
    func arcsPrimitivesAndBeginSpellDemo() {
        let world = MockWorldContext()

        // EF_BEGINSPELL_N1 spawns two primitive 144 instances on tick 0 and plays sound on tick 1
        let manager = EffectManager()
        #expect(manager.spawn(EffectSpawnRequest(effectID: .ef_beginspell_n1, worldPosition: .zero)) != nil)
        manager.stepOneTick(world: world)
        #expect(world.playedSounds.isEmpty)
        let host = manager.activeEffects.first as? RagEffect
        #expect(host?.primitives.count == 2)
        #expect(host?.primitives.allSatisfy { $0.id == 144 && $0.state.totalTexture == 27 } == true)

        manager.stepOneTick(world: world)
        #expect(world.playedSounds == ["effect\\EF_BeginSpell.wav"])

        // 2 primitives * 4 slots * 20 segments = 160 quads
        let beginSpellPayloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(beginSpellPayloads.reduce(0) { $0 + $1.vertices.count } == 160 * 6)

        let dummyHost = RagEffect(id: UUID(), request: EffectSpawnRequest(effectID: .ef_none, worldPosition: .zero), duration: 200)
        let ctx = EffectTickContext(world: world, assets: nil, currentTick: 0, usesMinimalEffects: false) { _ in }
        let minCtx = EffectTickContext(world: world, assets: nil, currentTick: 0, usesMinimalEffects: true) { _ in }

        // 137: RenderArcWalls (4 inner + 4 outer = 8 quads)
        let p137 = dummyHost.launchPrimitive(137)
        p137.state.slots[0].life = 1
        p137.state.slots[0].fullDisplayAngle = 360
        p137.state.slots[0].distance = 5.0
        p137.state.slots[0].maxHeight = 20.0
        p137.state.slots[0].riseAngle = 90
        p137.state.slots[0].alphaB = 200
        p137.state.slots[0].process = 115
        p137.tick(context: ctx)
        var c137 = EffectPrimitiveBatchCollector(fog: Fog())
        p137.collectBatches(into: &c137, world: world, assets: nil)
        #expect(c137.batches.reduce(0) { $0 + $1.vertices.count } == 8 * 6)

        // 146: RenderTrailingArc (20 quads, respects usesMinimalEffects cap 125)
        let p146 = dummyHost.launchPrimitive(146)
        p146.state.slots[0].life = 1
        p146.state.slots[0].fullDisplayAngle = 360
        p146.state.slots[0].distance = 6.0
        p146.state.slots[0].maxHeight = 15.0
        p146.state.slots[0].riseAngle = 70
        p146.state.slots[0].alphaB = 115
        p146.tick(context: minCtx)
        #expect(p146.state.slots[0].alphaB == 125)
        var c146 = EffectPrimitiveBatchCollector(fog: Fog())
        p146.collectBatches(into: &c146, world: world, assets: nil)
        #expect(c146.batches.reduce(0) { $0 + $1.vertices.count } == 20 * 6)

        // 149: RenderGroundArcGlow (dual-pass 40 quads for alphaT != 10, single-pass 20 quads for alphaT == 10)
        let p149 = dummyHost.launchPrimitive(149)
        p149.state.slots[0].life = 1
        p149.state.slots[0].fullDisplayAngle = 360
        p149.state.slots[0].distance = 5.0
        p149.state.slots[0].maxHeight = 12.0
        p149.state.slots[0].riseAngle = 80
        p149.state.slots[0].alphaB = 50
        p149.state.slots[0].alphaT = 4
        p149.tick(context: ctx)
        var c149Dual = EffectPrimitiveBatchCollector(fog: Fog())
        p149.collectBatches(into: &c149Dual, world: world, assets: nil)
        #expect(c149Dual.batches.reduce(0) { $0 + $1.vertices.count } == 40 * 6)
        p149.state.slots[0].alphaT = 10
        var c149Single = EffectPrimitiveBatchCollector(fog: Fog())
        p149.collectBatches(into: &c149Single, world: world, assets: nil)
        #expect(c149Single.batches.reduce(0) { $0 + $1.vertices.count } == 20 * 6)

        // 158 & 173: RenderGroundArc / RenderGroundArc2 (20 quads each; 173 respects minimal cap 80)
        let p158 = dummyHost.launchPrimitive(158)
        p158.state.slots[0].life = 1
        p158.state.slots[0].fullDisplayAngle = 360
        p158.state.slots[0].distance = 3.0
        p158.state.slots[0].maxHeight = 18.0
        p158.state.slots[0].riseAngle = 70
        p158.state.slots[0].alphaB = 100
        p158.tick(context: ctx)
        var c158 = EffectPrimitiveBatchCollector(fog: Fog())
        p158.collectBatches(into: &c158, world: world, assets: nil)
        #expect(c158.batches.reduce(0) { $0 + $1.vertices.count } == 20 * 6)

        let p173 = dummyHost.launchPrimitive(173)
        p173.state.slots[0].life = 1
        p173.state.slots[0].fullDisplayAngle = 360
        p173.state.slots[0].distance = 4.0
        p173.state.slots[0].maxHeight = 18.0
        p173.state.slots[0].riseAngle = 70
        p173.state.slots[0].alphaB = 78
        p173.tick(context: minCtx)
        #expect(p173.state.slots[0].alphaB == 80)
        var c173 = EffectPrimitiveBatchCollector(fog: Fog())
        p173.collectBatches(into: &c173, world: world, assets: nil)
        #expect(c173.batches.reduce(0) { $0 + $1.vertices.count } == 20 * 6)

        // 160: RenderPolygonFrames (2 passes for flag1[2] == 0)
        let p160 = dummyHost.launchPrimitive(160)
        p160.state.slots[0].life = 1
        p160.state.slots[0].distance = 5.0
        p160.state.slots[0].alphaB = 40
        p160.state.slots[0].flag1[2] = 0
        p160.tick(context: ctx)
        var c160 = EffectPrimitiveBatchCollector(fog: Fog())
        p160.collectBatches(into: &c160, world: world, assets: nil)
        #expect(c160.batches.reduce(0) { $0 + $1.vertices.count } == 2 * 6)
    }

    @Test("Ground primitives (86/92/119/122/125/131/143/148) and EF_WATER_FADE")
    func groundPrimitivesAndWaterFadeDemo() {
        let world = MockWorldContext()
        world.targets[1] = EffectTargetState(objectID: 1, worldPosition: SIMD3<Float>(6, 0, 4), facingAngle: 0)

        // EF_WATER_FADE spawns primitive 148 and renders 2 cross-fading quads
        let manager = EffectManager()
        #expect(manager.spawn(EffectSpawnRequest(effectID: .ef_water_fade, worldPosition: .zero)) != nil)
        manager.stepOneTick(world: world)
        let waterHost = manager.activeEffects.first as? RagEffect
        #expect(waterHost?.primitives.count == 1)
        #expect(waterHost?.primitives[0].id == 148)
        let waterPayloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(waterPayloads.reduce(0) { $0 + $1.vertices.count } == 2 * 6)

        let dummyHost = RagEffect(id: UUID(), request: EffectSpawnRequest(effectID: .ef_none, worldPosition: .zero), duration: 200)
        let ctx = EffectTickContext(world: world, assets: nil, currentTick: 0, usesMinimalEffects: false) { _ in }

        // 86 & 92: RenderFloorSquare
        for primID: EffectPrimitiveID in [86, 92] {
            let prim = dummyHost.launchPrimitive(primID)
            prim.state.deltaPos = SIMD3<Float>(10, 0, 0)
            prim.state.slots[0].life = 1
            prim.state.slots[0].distance = 3.0
            prim.state.slots[0].alphaB = 100
            prim.state.slots[0].height[1] = 1.0
            prim.tick(context: ctx)
            var collector = EffectPrimitiveBatchCollector(fog: Fog())
            prim.collectBatches(into: &collector, world: world, assets: nil)
            #expect(collector.batches.reduce(0) { $0 + $1.vertices.count } == 6)
        }

        // 119: spinning slash + trail shift at process == 3
        let p119 = dummyHost.launchPrimitive(119)
        p119.state.deltaPos = SIMD3<Float>(10, 0, 0)
        for i in 0..<4 {
            p119.state.slots[i].life = 1
            p119.state.slots[i].distance = 3.0
        }
        p119.state.slots[0].alphaB = 50
        p119.state.slots[0].height[1] = 1.0
        for _ in 0..<3 {
            p119.tick(context: ctx)
        }
        #expect(p119.state.slots[1].alphaB > 0)
        var c119 = EffectPrimitiveBatchCollector(fog: Fog())
        p119.collectBatches(into: &c119, world: world, assets: nil)
        #expect(c119.batches.reduce(0) { $0 + $1.vertices.count } == 2 * 6)

        // 122 (PrimSTIN3) & 125 (PP_STIN4): homing via strong-typed slot.targetObjectID
        for primID: EffectPrimitiveID in [122, .pp_stin4] {
            let prim = dummyHost.launchPrimitive(primID)
            prim.state.slots[0].life = 1
            prim.state.slots[0].distance = 3.0
            prim.state.slots[0].alphaB = 40
            prim.state.slots[0].height[1] = 1.0
            prim.state.slots[0].targetObjectID = 1
            prim.tick(context: ctx)
            #expect(prim.state.slots[0].riseAngle == 30)
            var collector = EffectPrimitiveBatchCollector(fog: Fog())
            prim.collectBatches(into: &collector, world: world, assets: nil)
            #expect(collector.batches.reduce(0) { $0 + $1.vertices.count } == 6)
        }

        // 131: RenderRipple (10 concentric rings)
        let p131 = dummyHost.launchPrimitive(131)
        p131.state.slots[0].life = 1
        p131.state.slots[0].distance = 2.0
        p131.tick(context: ctx)
        var c131 = EffectPrimitiveBatchCollector(fog: Fog())
        p131.collectBatches(into: &c131, world: world, assets: nil)
        #expect(c131.batches.reduce(0) { $0 + $1.vertices.count } == 10 * 6)

        // 143: RenderGroundSquare
        let p143 = dummyHost.launchPrimitive(143)
        p143.state.totalTexture = 4
        p143.state.slots[0].life = 1
        p143.state.slots[0].distance = 5.0
        p143.state.slots[0].alphaB = 180
        p143.tick(context: ctx)
        #expect(p143.state.slots[0].rotStart == 6)
        var c143 = EffectPrimitiveBatchCollector(fog: Fog())
        p143.collectBatches(into: &c143, world: world, assets: nil)
        #expect(c143.batches.reduce(0) { $0 + $1.vertices.count } == 6)
    }

    @Test("Panel primitives (129/130/132/138/140/142/145/150/155/157/166/170) and EF_SELFSCROLL")
    func panelPrimitivesAndSelfScrollDemo() {
        let world = MockWorldContext()

        // EF_SELFSCROLL spawns 2 primitive 166 instances on tick 0 and 2 more on tick 1 (4 total)
        let manager = EffectManager()
        #expect(manager.spawn(EffectSpawnRequest(effectID: .ef_selfscroll, worldPosition: .zero)) != nil)
        manager.stepOneTick(world: world)
        manager.stepOneTick(world: world)
        let scrollHost = manager.activeEffects.first as? RagEffect
        #expect(scrollHost?.primitives.count == 4)
        #expect(scrollHost?.primitives.allSatisfy { $0.id == 166 } == true)
        // 4 primitives * 4 slots * 6 ribbon quads = 96 quads
        let scrollPayloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(scrollPayloads.reduce(0) { $0 + $1.vertices.count } == 96 * 6)

        let dummyHost = RagEffect(id: UUID(), request: EffectSpawnRequest(effectID: .ef_none, worldPosition: .zero), duration: 200)
        let ctx = EffectTickContext(world: world, assets: nil, currentTick: 0, usesMinimalEffects: false) { _ in }

        // 129: RenderBobbingRing (10 quads)
        let p129 = dummyHost.launchPrimitive(129)
        p129.state.slots[0].life = 1
        p129.state.slots[0].alphaB = 120
        p129.state.slots[0].height[0] = 2.0
        p129.tick(context: ctx)
        var c129 = EffectPrimitiveBatchCollector(fog: Fog())
        p129.collectBatches(into: &c129, world: world, assets: nil)
        #expect(c129.batches.reduce(0) { $0 + $1.vertices.count } == 10 * 6)

        // 130: RenderFacingQuads (4 quads)
        let p130 = dummyHost.launchPrimitive(130)
        p130.state.slots[0].life = 1
        p130.state.slots[0].distance = 2.0
        p130.tick(context: ctx)
        var c130 = EffectPrimitiveBatchCollector(fog: Fog())
        p130.collectBatches(into: &c130, world: world, assets: nil)
        #expect(c130.batches.reduce(0) { $0 + $1.vertices.count } == 4 * 6)

        // 132: RenderColorPanel (1 quad)
        let p132 = dummyHost.launchPrimitive(132)
        p132.state.slots[0].life = 1
        p132.state.slots[0].alphaB = 150
        p132.state.slots[0].maxHeight = 10.0
        p132.state.slots[0].height[5] = 3.0
        p132.tick(context: ctx)
        var c132 = EffectPrimitiveBatchCollector(fog: Fog())
        p132.collectBatches(into: &c132, world: world, assets: nil)
        #expect(c132.batches.reduce(0) { $0 + $1.vertices.count } == 6)

        // 138: RenderTwinFacingSquares (2 quads)
        let p138 = dummyHost.launchPrimitive(138)
        p138.state.slots[0].life = 1
        p138.state.slots[0].distance = 3.0
        p138.state.slots[0].alphaB = 100
        p138.tick(context: ctx)
        var c138 = EffectPrimitiveBatchCollector(fog: Fog())
        p138.collectBatches(into: &c138, world: world, assets: nil)
        #expect(c138.batches.reduce(0) { $0 + $1.vertices.count } == 2 * 6)

        // 140: RenderTeiFacingSlots (1 quad for kind 0)
        let p140 = dummyHost.launchPrimitive(140)
        p140.state.totalTexture = 4
        p140.state.slots[0].life = 1
        p140.state.slots[0].distance = 3.0
        p140.state.slots[0].alphaB = 150
        p140.tick(context: ctx)
        var c140 = EffectPrimitiveBatchCollector(fog: Fog())
        p140.collectBatches(into: &c140, world: world, assets: nil)
        #expect(c140.batches.reduce(0) { $0 + $1.vertices.count } == 6)

        // 142: RenderStandingPanels (4 panels)
        let p142 = dummyHost.launchPrimitive(142)
        p142.state.slots[0].life = 1
        p142.state.slots[0].distance = 10.0
        p142.state.slots[0].alphaB = 200
        p142.tick(context: ctx)
        var c142 = EffectPrimitiveBatchCollector(fog: Fog())
        p142.collectBatches(into: &c142, world: world, assets: nil)
        #expect(c142.batches.reduce(0) { $0 + $1.vertices.count } == 4 * 6)

        // 145: RenderPillarSquares (2 core + 4 vertical pillars = 6 quads)
        let p145 = dummyHost.launchPrimitive(145)
        p145.state.slots[0].life = 1
        p145.state.slots[0].distance = 3.0
        p145.state.slots[0].alphaB = 100
        for i in 0..<4 {
            p145.state.slots[i].maxHeight = 3.0
            p145.state.slots[i].riseAngle = 120
        }
        p145.tick(context: ctx)
        var c145 = EffectPrimitiveBatchCollector(fog: Fog())
        p145.collectBatches(into: &c145, world: world, assets: nil)
        #expect(c145.batches.reduce(0) { $0 + $1.vertices.count } == 6 * 6)

        // 150: RenderHoverSquares (4 hovering quads when y <= 0)
        let p150 = dummyHost.launchPrimitive(150)
        p150.state.slots[0].life = 1
        p150.state.slots[0].distance = 1.0
        p150.state.slots[0].riseAngle = 10
        p150.state.slots[0].maxHeight = 0.1
        p150.state.slots[0].vecBPre = SIMD3<Float>(0, -2, 0)
        p150.state.slots[0].vecBNow = SIMD3<Float>(0, -2, 0)
        p150.state.slots[0].vecTPre = SIMD3<Float>(0, -2, 0)
        p150.state.slots[0].vecTNow = SIMD3<Float>(0, -2, 0)
        p150.tick(context: ctx)
        var c150 = EffectPrimitiveBatchCollector(fog: Fog())
        p150.collectBatches(into: &c150, world: world, assets: nil)
        #expect(c150.batches.reduce(0) { $0 + $1.vertices.count } == 4 * 6)

        // 155 & 170: RenderTwinGlowSquares (default style emits 2 layers * 2 points = 4 quads)
        for primID: EffectPrimitiveID in [155, 170] {
            let prim = dummyHost.launchPrimitive(primID)
            prim.state.slots[0].life = 1
            prim.state.slots[0].distance = 2.0
            prim.state.slots[0].maxHeight = 0.2
            prim.tick(context: ctx)
            var collector = EffectPrimitiveBatchCollector(fog: Fog())
            prim.collectBatches(into: &collector, world: world, assets: nil)
            #expect(collector.batches.reduce(0) { $0 + $1.vertices.count } == 4 * 6)
        }

        // 157: RenderGlowSquare (inner + outer glow = 2 quads)
        let p157 = dummyHost.launchPrimitive(157)
        p157.state.slots[0].life = 1
        p157.state.slots[0].distance = 2.0
        p157.state.slots[0].height[0] = 5.0
        p157.state.slots[0].vecBNow = SIMD3<Float>(0, -5, 0)
        p157.state.slots[0].maxHeight = 0.5
        p157.tick(context: ctx)
        var c157 = EffectPrimitiveBatchCollector(fog: Fog())
        p157.collectBatches(into: &c157, world: world, assets: nil)
        #expect(c157.batches.reduce(0) { $0 + $1.vertices.count } == 2 * 6)
    }

    @Test("Sweep primitives (89/133-136/141/154/156/159/162-165) and demo effects")
    func sweepsPrimitivesAndDemoEffects() {
        let world = MockWorldContext()

        // EF_INFRAREDSCAN (794): plays sound and launches primitive 135
        let scanManager = EffectManager()
        #expect(scanManager.spawn(EffectSpawnRequest(effectID: .ef_infraredscan, worldPosition: .zero)) != nil)
        scanManager.stepOneTick(world: world)
        #expect(world.playedSounds == ["effect\\INFRAREDSCAN.wav"])
        let scanHost = scanManager.activeEffects.first as? RagEffect
        #expect(scanHost?.primitives.first?.id == 135)
        let scanPayloads = scanManager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(scanPayloads.reduce(0) { $0 + $1.vertices.count } > 0)

        // EF_PRIMECHARGE (882): launches 40 primitive 159 instances on tick 0 and plays sound on stateCnt == 10
        world.playedSounds.removeAll()
        let chargeManager = EffectManager()
        #expect(chargeManager.spawn(EffectSpawnRequest(effectID: .ef_primecharge, worldPosition: .zero)) != nil)
        for _ in 0..<11 {
            chargeManager.stepOneTick(world: world)
        }
        #expect(world.playedSounds == ["effect\\LG_EXEEDBREAK.wav"])
        let chargeHost = chargeManager.activeEffects.first as? RagEffect
        #expect(chargeHost?.primitives.count == 40)
        #expect(chargeHost?.primitives.first?.id == 159)
        let chargePayloads = chargeManager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(chargePayloads.reduce(0) { $0 + $1.vertices.count } > 0)

        // EF_DQ9_CHARGE4 (898): launches primitive 165 and emits curved fan trails
        let dq9Manager = EffectManager()
        #expect(dq9Manager.spawn(EffectSpawnRequest(effectID: .ef_dq9_charge4, worldPosition: .zero)) != nil)
        dq9Manager.stepOneTick(world: world)
        let dq9Host = dq9Manager.activeEffects.first as? RagEffect
        #expect(dq9Host?.primitives.first?.id == 165)
        let dq9Payloads = dq9Manager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(dq9Payloads.reduce(0) { $0 + $1.vertices.count } > 0)

        let dummyHost = RagEffect(id: UUID(), request: EffectSpawnRequest(effectID: .ef_none, worldPosition: .zero), duration: 200)
        let ctx = EffectTickContext(world: world, assets: nil, currentTick: 0, usesMinimalEffects: false) { _ in }

        // 89: RenderFanBeam (2 wedges)
        let p89 = dummyHost.launchPrimitive(89)
        p89.state.slots[0].life = 1
        p89.state.slots[0].distance = 10.0
        p89.state.slots[0].alphaB = 120
        p89.state.slots[0].fullDisplayAngle = 15
        p89.tick(context: ctx)
        var c89 = EffectPrimitiveBatchCollector(fog: Fog())
        p89.collectBatches(into: &c89, world: world, assets: nil)
        #expect(c89.batches.reduce(0) { $0 + $1.vertices.count } == 2 * 6)

        // 133: RenderSpiralBlades (14 blades for style 0)
        let p133 = dummyHost.launchPrimitive(133)
        p133.state.slots[0].life = 1
        p133.state.slots[0].distance = 5.0
        p133.state.slots[0].maxHeight = 15.0
        p133.state.slots[0].alphaB = 150
        p133.state.slots[0].alphaT = 0
        p133.tick(context: ctx)
        var c133 = EffectPrimitiveBatchCollector(fog: Fog())
        p133.collectBatches(into: &c133, world: world, assets: nil)
        #expect(c133.batches.reduce(0) { $0 + $1.vertices.count } == 14 * 6)

        // 134: RenderBladeTrail (5 trail quads)
        let p134 = dummyHost.launchPrimitive(134)
        p134.state.slots[0].life = 1
        p134.state.slots[0].distance = 4.0
        p134.state.slots[0].maxHeight = 10.0
        p134.state.slots[0].alphaB = 180
        p134.tick(context: ctx)
        var c134 = EffectPrimitiveBatchCollector(fog: Fog())
        p134.collectBatches(into: &c134, world: world, assets: nil)
        #expect(c134.batches.reduce(0) { $0 + $1.vertices.count } == 5 * 6)

        // 136: RenderSpinSquares (36 tiers * 2 passes = 72 quads)
        let p136 = dummyHost.launchPrimitive(136)
        p136.state.slots[0].life = 1
        p136.state.slots[0].distance = 5.0
        p136.state.slots[0].alphaB = 150
        p136.tick(context: ctx)
        var c136 = EffectPrimitiveBatchCollector(fog: Fog())
        p136.collectBatches(into: &c136, world: world, assets: nil)
        #expect(c136.batches.reduce(0) { $0 + $1.vertices.count } == 72 * 6)

        // 141: RenderTaperedQuad (1 quad)
        let p141 = dummyHost.launchPrimitive(141)
        p141.state.slots[0].life = 1
        p141.state.slots[0].distance = 5.0
        p141.state.slots[0].maxHeight = 10.0
        p141.state.slots[0].alphaB = 150
        p141.tick(context: ctx)
        var c141 = EffectPrimitiveBatchCollector(fog: Fog())
        p141.collectBatches(into: &c141, world: world, assets: nil)
        #expect(c141.batches.reduce(0) { $0 + $1.vertices.count } == 6)

        // 154: RenderBladeFins (2 fins * 2 layers = 4 quads)
        let p154 = dummyHost.launchPrimitive(154)
        p154.state.slots[0].life = 1
        p154.state.slots[0].distance = 5.0
        p154.state.slots[0].maxHeight = 10.0
        p154.state.slots[0].alphaB = 150
        p154.tick(context: ctx)
        var c154 = EffectPrimitiveBatchCollector(fog: Fog())
        p154.collectBatches(into: &c154, world: world, assets: nil)
        #expect(c154.batches.reduce(0) { $0 + $1.vertices.count } == 4 * 6)

        // 156: RenderJitterQuads (1 primary + 4 cardinal halo = 5 quads)
        let p156 = dummyHost.launchPrimitive(156)
        p156.state.slots[0].life = 1
        p156.state.slots[0].distance = 5.0
        p156.state.slots[0].alphaB = 150
        p156.tick(context: ctx)
        var c156 = EffectPrimitiveBatchCollector(fog: Fog())
        p156.collectBatches(into: &c156, world: world, assets: nil)
        #expect(c156.batches.reduce(0) { $0 + $1.vertices.count } == 5 * 6)

        // 159: RenderBladeQuads (inner + outer = 2 quads)
        let p159 = dummyHost.launchPrimitive(159)
        p159.state.slots[0].life = 1
        p159.state.slots[0].distance = 5.0
        p159.state.slots[0].maxHeight = 10.0
        p159.state.slots[0].alphaB = 150
        p159.tick(context: ctx)
        var c159 = EffectPrimitiveBatchCollector(fog: Fog())
        p159.collectBatches(into: &c159, world: world, assets: nil)
        #expect(c159.batches.reduce(0) { $0 + $1.vertices.count } == 2 * 6)

        // 162: RenderFanSlice (1 quad)
        let p162 = dummyHost.launchPrimitive(162)
        p162.state.slots[0].life = 1
        p162.state.slots[0].distance = 5.0
        p162.state.slots[0].maxHeight = 12.0
        p162.state.slots[0].alphaB = 150
        p162.tick(context: ctx)
        var c162 = EffectPrimitiveBatchCollector(fog: Fog())
        p162.collectBatches(into: &c162, world: world, assets: nil)
        #expect(c162.batches.reduce(0) { $0 + $1.vertices.count } == 6)

        // 163: RenderFanWedge (1 quad)
        let p163 = dummyHost.launchPrimitive(163)
        p163.state.slots[0].life = 1
        p163.state.slots[0].distance = 5.0
        p163.state.slots[0].maxHeight = 12.0
        p163.state.slots[0].alphaB = 150
        p163.tick(context: ctx)
        var c163 = EffectPrimitiveBatchCollector(fog: Fog())
        p163.collectBatches(into: &c163, world: world, assets: nil)
        #expect(c163.batches.reduce(0) { $0 + $1.vertices.count } == 6)

        // 164: RenderFanTrail (distance 1.0 -> 0.0 after 1 tick, step 0 skipped => 5 quads)
        let p164 = dummyHost.launchPrimitive(164)
        p164.state.slots[0].life = 1
        p164.state.slots[0].distance = 1.0
        p164.state.slots[0].maxHeight = 15.0
        p164.state.slots[0].alphaB = 150
        p164.tick(context: ctx)
        var c164 = EffectPrimitiveBatchCollector(fog: Fog())
        p164.collectBatches(into: &c164, world: world, assets: nil)
        #expect(c164.batches.reduce(0) { $0 + $1.vertices.count } == 5 * 6)
    }

    @Test("Screen2D, 2D primitives (0..4), pure-texture sprite primitives (15/16/22/52/53/71/78/127/151), and EF_BASH")
    func twoDAndPureTextureSpritesAndBashDemo() {
        let world = MockWorldContext()

        // EF_BASH (16): plays sound, spawns 1 PP_2DCIRCLE + 20 PP_2DFLASH in .screen2D mode
        let bashManager = EffectManager()
        #expect(bashManager.spawn(EffectSpawnRequest(effectID: .ef_bash, worldPosition: SIMD3<Float>(1, 0, 2))) != nil)
        bashManager.stepOneTick(world: world)
        #expect(world.playedSounds == ["effect\\EF_Bash.wav"])
        let bashHost = bashManager.activeEffects.first as? RagEffect
        #expect(bashHost?.primitives.count == 21)
        #expect(bashHost?.primitives.first?.id == .pp_2dcircle)
        let bashPayloads = bashManager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(bashPayloads.allSatisfy { $0.mode == .screen2D })
        // 10 ring quads (60 verts) + 20 flash triangles (60 verts) = 120 verts
        #expect(bashPayloads.reduce(0) { $0 + $1.vertices.count } == 120)

        // EF_BASH skips spawning under minimal effects
        let minBashManager = EffectManager(usesMinimalEffects: true)
        #expect(minBashManager.spawn(EffectSpawnRequest(effectID: .ef_bash, worldPosition: .zero)) != nil)
        minBashManager.stepOneTick(world: world)
        let minBashHost = minBashManager.activeEffects.first as? RagEffect
        #expect(minBashHost?.primitives.isEmpty == true)

        let dummyHost = RagEffect(id: UUID(), request: EffectSpawnRequest(effectID: .ef_none, worldPosition: .zero), duration: 200)
        var spawnedChildren: [EffectSpawnRequest] = []
        let ctx = EffectTickContext(world: world, assets: nil, currentTick: 0, usesMinimalEffects: false) { request in
            spawnedChildren.append(request)
        }

        // 0: PP_2DTEXTURE (world-anchored + absolute screen + strong-typed cooldownSkillID)
        let p0 = dummyHost.launchPrimitive(.pp_2dtexture)
        p0.state.widthSize = 20
        p0.state.heightSize = 20
        p0.state.cooldownSkillID = 42
        p0.currentMotion = 2
        p0.tick(context: ctx)
        #expect(p0.state.slots[0].process == 999)
        var c0 = EffectPrimitiveBatchCollector(fog: Fog())
        p0.collectBatches(into: &c0, world: world, assets: nil)
        #expect(p0.currentMotion == 0)
        #expect(c0.batches.first?.mode == .screen2D)
        #expect(c0.batches.reduce(0) { $0 + $1.vertices.count } == 6)

        p0.state.pattern |= 4
        var c0Abs = EffectPrimitiveBatchCollector(fog: Fog())
        p0.collectBatches(into: &c0Abs, world: world, assets: nil)
        #expect(c0Abs.batches.first?.mode == .screen2DAbsolute)

        // 1: PP_2DTEXTUREORBIT
        let p1 = dummyHost.launchPrimitive(.pp_2dtextureorbit)
        p1.state.widthSize = 12
        p1.state.heightSize = 12
        p1.state.radius = 25
        p1.state.longSpeed = 10
        p1.tick(context: ctx)
        var c1 = EffectPrimitiveBatchCollector(fog: Fog())
        p1.collectBatches(into: &c1, world: world, assets: nil)
        #expect(c1.batches.reduce(0) { $0 + $1.vertices.count } == 6)

        // 2: PP_2DQUAD (notched diamond = 2 triangles = 6 verts)
        let p2 = dummyHost.launchPrimitive(.pp_2dquad)
        p2.state.widthSize = 16
        p2.state.heightSize = 24
        p2.tick(context: ctx)
        var c2 = EffectPrimitiveBatchCollector(fog: Fog())
        p2.collectBatches(into: &c2, world: world, assets: nil)
        #expect(c2.batches.reduce(0) { $0 + $1.vertices.count } == 6)

        // 15: PP_3DTEXTURE (1 world3D quad = 6 verts)
        let p15 = dummyHost.launchPrimitive(.pp_3dtexture)
        p15.state.widthSize = 5
        p15.state.heightSize = 5
        p15.tick(context: ctx)
        var c15 = EffectPrimitiveBatchCollector(fog: Fog())
        p15.collectBatches(into: &c15, world: world, assets: nil)
        #expect(c15.batches.first?.mode == .world3D)
        #expect(c15.batches.reduce(0) { $0 + $1.vertices.count } == 6)

        // 16: PP_3DCROSSTEXTURE (2 crossed world3D quads = 12 verts)
        let p16 = dummyHost.launchPrimitive(.pp_3dcrosstexture)
        p16.state.widthSize = 5
        p16.state.heightSize = 5
        p16.tick(context: ctx)
        var c16 = EffectPrimitiveBatchCollector(fog: Fog())
        p16.collectBatches(into: &c16, world: world, assets: nil)
        #expect(c16.batches.reduce(0) { $0 + $1.vertices.count } == 12)

        // 22: PP_3DTEXTURE_NOMASTER (1 world-anchored screen2D quad = 6 verts)
        let p22 = dummyHost.launchPrimitive(.pp_3dtexture_nomaster)
        p22.state.widthSize = 18
        p22.state.heightSize = 18
        p22.tick(context: ctx)
        var c22 = EffectPrimitiveBatchCollector(fog: Fog())
        p22.collectBatches(into: &c22, world: world, assets: nil)
        #expect(c22.batches.first?.mode == .screen2D)
        #expect(c22.batches.reduce(0) { $0 + $1.vertices.count } == 6)

        // 52: PP_POKJUK (2 trailing firework squares = 12 verts)
        let p52 = dummyHost.launchPrimitive(.pp_pokjuk)
        p52.state.slots[0].life = 1
        p52.state.slots[0].alphaB = 200
        p52.state.slots[0].maxHeight = 4
        p52.tick(context: ctx)
        var c52 = EffectPrimitiveBatchCollector(fog: Fog())
        p52.collectBatches(into: &c52, world: world, assets: nil)
        #expect(c52.batches.reduce(0) { $0 + $1.vertices.count } == 2 * 6)

        // 53: PP_THROWITEM (parabolic throw via renderFieldPanel = 1 quad)
        let p53 = dummyHost.launchPrimitive(.pp_throwitem)
        p53.state.slots[0].life = 1
        p53.state.slots[0].alphaB = 220
        p53.state.slots[0].distance = 3
        p53.state.slots[0].flag1[1] = 20
        p53.state.slots[0].height[1] = 1.0
        p53.tick(context: ctx)
        var c53 = EffectPrimitiveBatchCollector(fog: Fog())
        p53.collectBatches(into: &c53, world: world, assets: nil)
        #expect(c53.batches.reduce(0) { $0 + $1.vertices.count } == 6)

        // 71: PP_BLIND (8 dark tunnel quads = 48 verts)
        let p71 = dummyHost.launchPrimitive(.pp_blind)
        p71.state.slots[0].life = 1
        p71.state.slots[0].distance = 10
        p71.tick(context: ctx)
        var c71 = EffectPrimitiveBatchCollector(fog: Fog())
        p71.collectBatches(into: &c71, world: world, assets: nil)
        #expect(c71.batches.reduce(0) { $0 + $1.vertices.count } == 8 * 6)

        // 78: PP_COLORPAPER (1 tumbling confetti quad = 6 verts)
        let p78 = dummyHost.launchPrimitive(.pp_colorpaper)
        p78.state.slots[0].life = 1
        p78.state.slots[0].maxHeight = 2
        p78.state.slots[0].distance = 0.5
        p78.state.slots[0].vecBNow = SIMD3<Float>(0, -40, 0)
        p78.tick(context: ctx)
        var c78 = EffectPrimitiveBatchCollector(fog: Fog())
        p78.collectBatches(into: &c78, world: world, assets: nil)
        #expect(c78.batches.reduce(0) { $0 + $1.vertices.count } == 6)

        // 127: PP_BUBBLE_DROP (falling bubble via renderFieldPanel = 1 quad)
        let p127 = dummyHost.launchPrimitive(.pp_bubble_drop)
        p127.state.slots[0].life = 1
        p127.state.slots[0].distance = 2.5
        p127.state.slots[0].flag1[4] = 30
        p127.state.slots[0].height[1] = 0.5
        p127.tick(context: ctx)
        var c127 = EffectPrimitiveBatchCollector(fog: Fog())
        p127.collectBatches(into: &c127, world: world, assets: nil)
        #expect(c127.batches.reduce(0) { $0 + $1.vertices.count } == 6)

        // 151: PrimSpiralFade spawns EF_SOULLIGHT2 child via strong-typed targetObjectID during tick
        let p151 = dummyHost.launchPrimitive(151)
        p151.state.slots[0].life = 1
        p151.state.slots[0].distance = 2.0
        p151.state.slots[0].targetObjectID = 110_000_005
        p151.tick(context: ctx)
        #expect(spawnedChildren.count == 1)
        #expect(spawnedChildren[0].effectID == .ef_soullight2)
        #expect(spawnedChildren[0].targetObjectID == 110_000_005)
        var c151 = EffectPrimitiveBatchCollector(fog: Fog())
        p151.collectBatches(into: &c151, world: world, assets: nil)
        #expect(c151.batches.isEmpty)
    }
}
