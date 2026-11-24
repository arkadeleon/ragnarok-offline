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

        // Tick 2 & 3: host retires at stateCnt == 3, detaching primitive, which still has 2 ticks left.
        manager.stepOneTick(world: world)
        manager.stepOneTick(world: world)
        let ragEffect = manager.activeEffects.first as? RagEffect
        #expect(ragEffect != nil)
        #expect(ragEffect?.isMasterAlive == false)
        #expect(ragEffect?.primitives.count == 1)
        #expect(ragEffect?.primitives.first?.master == nil)
        #expect(manager.hasEffects)

        // Tick 4 & 5: primitive completes its duration (5) and the effect retires completely.
        manager.stepOneTick(world: world)
        #expect(manager.hasEffects)
        manager.stepOneTick(world: world)
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
        #expect(ragEffect?.primitives.first?.id == EffectPrimitiveID(rawValue: 60))
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

        // Advance through full lifecycle (default lifetime 100 ticks + child primitives).
        for _ in 0..<250 {
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
}
