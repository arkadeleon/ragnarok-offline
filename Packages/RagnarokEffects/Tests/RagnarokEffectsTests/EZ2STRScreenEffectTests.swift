//
//  EZ2STRScreenEffectTests.swift
//  RagnarokEffectsTests
//
//  Created by Leon Li on 2026/11/23.
//

import Foundation
import Metal
import RagnarokCore
import RagnarokFileFormats
import RagnarokRendering
import RagnarokResources
import simd
import Testing
@testable import RagnarokEffects

@MainActor
@Suite("EZ2STRScreenEffect & EZ2STRScreenEffectDefinition")
struct EZ2STRScreenEffectTests {
    private final class MockWorldContext: EffectWorldContext {
        var cameraWorldPosition: SIMD3<Float> = .zero
        var cameraYawDegrees: Float = 0
        var terrainYInEffectSpace: Float = 0
        var targets: [EffectTargetID : EffectTargetState] = [:]
        var playedSounds: [(name: String, position: SIMD3<Float>?)] = []
        var shakeCount: Int = 0

        func terrainHeight(atEffectX x: Float, effectZ z: Float) -> Float {
            terrainYInEffectSpace
        }

        func targetState(for targetID: EffectTargetID) -> EffectTargetState? {
            targets[targetID]
        }

        func playSound(named name: String, atWorldPosition position: SIMD3<Float>?, delay: TimeInterval) {
            playedSounds.append((name, position))
        }

        func shakeCamera(amplitude: Float, duration: TimeInterval, frequency: Float) {
            shakeCount += 1
        }

        func applyTargetModifier(_ modifier: EffectTargetModifier, to targetID: EffectTargetID) {}
        func spawnChildEffect(_ request: EffectSpawnRequest) {}
    }

    private static func makeSyntheticSTRData(maxKeyframeIndex: Int32 = 2) -> Data {
        var data = Data()

        func appendInt32(_ value: Int32) {
            var v = value.littleEndian
            withUnsafeBytes(of: &v) { data.append(contentsOf: $0) }
        }

        func appendFloat(_ value: Float) {
            var bits = value.bitPattern.littleEndian
            withUnsafeBytes(of: &bits) { data.append(contentsOf: $0) }
        }

        func appendFixedString(_ string: String, length: Int) {
            let raw = Data(string.utf8.prefix(length))
            data.append(raw)
            if raw.count < length {
                data.append(Data(repeating: 0, count: length - raw.count))
            }
        }

        data.append(contentsOf: "STRM".utf8)
        data.append(contentsOf: [1, 48, 0, 0])
        appendInt32(60)
        appendInt32(maxKeyframeIndex)
        appendInt32(1)
        data.append(Data(repeating: 0, count: 16))

        appendInt32(1)
        appendFixedString("tex0.bmp", length: 128)
        appendInt32(2)

        for frameIndex in [Int32(0), maxKeyframeIndex] {
            appendInt32(frameIndex)
            appendInt32(0)
            appendFloat(320)
            appendFloat(240)
            for value: Float in [0, 0, 1, 0, 1, 1, 0, 1] { appendFloat(value) }
            for value: Float in [-10, 10, 10, -10, -10, -10, 10, 10] { appendFloat(value) }
            appendFloat(0)
            appendInt32(0)
            appendFloat(0)
            appendFloat(0)
            for _ in 0..<4 { appendFloat(255) }
            appendInt32(5)
            appendInt32(6)
            appendInt32(0)
        }

        return data
    }

    private static func makeAssetStore(strPaths: [String], maxKeyframeIndex: Int32 = 2) async -> EffectAssetStore? {
        guard let device = MTLCreateSystemDefaultDevice() else {
            return nil
        }

        let strData = makeSyntheticSTRData(maxKeyframeIndex: maxKeyframeIndex)
        let bmpData = Data([
            0x42, 0x4D, 0x3A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x00,
            0x28, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00,
            0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0xFF, 0xFF, 0xFF, 0x00,
        ])

        let normalizedTargets = Set(strPaths.map { $0.lowercased() })

        struct StaticSTRProvider: ResourceProvider {
            let strData: Data
            let bmpData: Data
            let normalizedTargets: Set<String>

            func contentsOfResource(at path: ResourcePath) async throws -> Data {
                let joined = path.components.joined(separator: "\\").lowercased()
                if joined.hasSuffix("tex0.bmp") {
                    return bmpData
                }
                for target in normalizedTargets where joined.hasSuffix(target) {
                    return strData
                }
                throw ResourceError.resourceNotFound(path)
            }
        }

        let resourceManager = ResourceManager(
            resourceProvider: StaticSTRProvider(
                strData: strData,
                bmpData: bmpData,
                normalizedTargets: normalizedTargets
            )
        )
        let store = EffectAssetStore(device: device, resourceManager: resourceManager)
        for path in strPaths {
            await store.preloadSTRAsset(atPath: path)
        }
        return store
    }

    @Test("Full definitions cover all 1047 entries, K2L encoding, and minimal path resolution")
    func definitionsCoverageAndPathResolution() {
        #expect(EZ2STRScreenEffectDefinition.definitions.count == 1047)
        #expect(EZ2STRScreenEffectDefinition.definitionsByEffectID.count == 1047)

        let rawIDs = EZ2STRScreenEffectDefinition.definitions.map(\.effectID.rawValue)
        #expect(rawIDs == rawIDs.sorted())
        #expect(Set(rawIDs).count == 1047)

        let potion = EZ2STRScreenEffectDefinition.definition(for: .ef_potion1)
        #expect(potion?.strPath == K2L("빨간포션.str"))
        #expect(potion?.sounds == [EZ2STRScreenEffectDefinition.TimedSound(tick: 0, names: ["_heal_effect.wav"])])

        let potion5 = EZ2STRScreenEffectDefinition.definition(for: .ef_potion5)
        #expect(potion5?.strPath == K2L("파란포션.str"))
        #expect(potion5?.sounds == [EZ2STRScreenEffectDefinition.TimedSound(tick: 0, names: [K2L("effect\\흡기.wav")])])

        let kaihou = EZ2STRScreenEffectDefinition.definition(for: .ef_kaihou1)
        #expect(kaihou?.strPath == K2L("술식해방.str"))

        let counterSlash = EZ2STRScreenEffectDefinition.definition(for: .ef_new_counter_slash)
        #expect(
            counterSlash?.resolveSTRPath(usesMinimalEffects: false)
                == "new_counter_slash\\new_counter_slash\\new_counter_slash.str"
        )
        #expect(
            counterSlash?.resolveSTRPath(usesMinimalEffects: true)
                == "mineffect\\new_counter_slash\\new_counter_slash\\new_counter_slash.str"
        )

        let rayOfGenesis = EZ2STRScreenEffectDefinition.definition(for: .ef_new_rayofgenesis)
        #expect(
            rayOfGenesis?.resolveSTRPath(usesMinimalEffects: true)
                == "mineffect\\new_rayofgenesis\\new_rayofgenesis\\new_rayofgenesis.str"
        )
        #expect(rayOfGenesis?.isAttachedToHead == true)
        #expect(rayOfGenesis?.sounds.count == 3)

        let meteor = EZ2STRScreenEffectDefinition.definition(for: .ef_new_meteorstorm)
        #expect(
            meteor?.resolveSTRPath(usesMinimalEffects: true, resourceExists: { path in
                path == "new_meteostorm\\new_meteostorm\\min_new_meteostorm.str"
            }) == "new_meteostorm\\new_meteostorm\\min_new_meteostorm.str"
        )
    }

    @Test("Spot checks special overrides across modes, head offsets, scales, aim modes, sounds, and overlays")
    func definitionsSpecialOverridesSpotChecks() {
        let pneuma = EZ2STRScreenEffectDefinition.definition(for: .ef_pneuma)
        #expect(pneuma?.isRetained == true)
        #expect(pneuma?.resolveSTRPath(randomValue: { _ in 2 }) == "Pneuma2.str")

        let meteorVisual = EZ2STRScreenEffectDefinition.definition(for: .ef_meteor_storm_visual)
        #expect(meteorVisual?.resolveSTRPath(randomValue: { _ in 3 }) == "MeteorStorm\\meteor3.str")
        #expect(meteorVisual?.cameraShakeTicks == [40])

        let test05 = EZ2STRScreenEffectDefinition.definition(for: .ef_test_effect_05)
        #expect(test05?.strPath == "test_effect\\05\\05.str")
        #expect(test05?.isLooping == true)

        let dMachine = EZ2STRScreenEffectDefinition.definition(for: .ef_new_d_machine)
        #expect(dMachine?.ignoresRidingHeight == true)
        #expect(dMachine?.isAttachedToHead == true)
        #expect(dMachine?.isLooping == true)
        #expect(dMachine?.isRetained == true)

        let chattering = EZ2STRScreenEffectDefinition.definition(for: .ef_su_chattering)
        #expect(chattering?.isAttachedToHead == true)
        #expect(chattering?.headOffsetYDelta == 8)

        let tremor = EZ2STRScreenEffectDefinition.definition(for: .ef_stratum_tremor)
        #expect(tremor?.renderMode == .ground)
        #expect(tremor?.levelScales == [1: 0.7, 2: 1.25, 3: 1.25, 4: 1.25, 5: 1.25])

        let gate2 = EZ2STRScreenEffectDefinition.definition(for: .ef_npc_gate_green_2)
        #expect(gate2?.defaultScale == 0.6)
        let gate3 = EZ2STRScreenEffectDefinition.definition(for: .ef_npc_gate_green_3)
        #expect(gate3?.defaultScale == 0.35)

        let increasingActivity = EZ2STRScreenEffectDefinition.definition(for: .ef_increasing_activity)
        #expect(increasingActivity?.defaultRepeatCount == 2)

        let abyssSquare = EZ2STRScreenEffectDefinition.definition(for: .ef_abyss_square)
        #expect(
            abyssSquare?.periodicSound == EZ2STRScreenEffectDefinition.PeriodicSound(
                startTick: 30,
                intervalTicks: 64,
                name: "effect\\ABC_ABYSS_SQUARE.wav"
            )
        )

        #expect(EZ2STRScreenEffectDefinition.definition(for: .ef_shadow_stab)?.aimMode == .towardSource)
        #expect(EZ2STRScreenEffectDefinition.definition(for: .ef_chain_reaction_shot)?.aimMode == .fromSource)
        #expect(EZ2STRScreenEffectDefinition.definition(for: .ef_wooden_warrior_attack)?.aimMode == .fromSourceInverted)

        let lovVisual = EZ2STRScreenEffectDefinition.definition(for: .ef_lord_of_vermillion_visual)
        #expect(lovVisual?.cameraShakeTicks == [50, 100, 150, 200, 250])
        #expect(lovVisual?.sounds.count == 11)

        let stormslash5 = EZ2STRScreenEffectDefinition.definition(for: .ef_stormslash_5)
        #expect(stormslash5?.sounds.count == 5)
        #expect(stormslash5?.sounds.map(\.tick) == [0, 15, 30, 45, 60])

        let quagmire = EZ2STRScreenEffectDefinition.definition(for: .ef_quagmire_visual)
        #expect(quagmire?.sounds.first?.chanceDenominator == 12)

        let diamondBottom = EZ2STRScreenEffectDefinition.definition(for: .ef_diamond_storm_bottom)
        #expect(diamondBottom?.renderMode == .ground)
        #expect(diamondBottom?.defaultLifeTimeFrames == 60)

        #expect(EZ2STRScreenEffectDefinition.definition(for: .ef_ui_enchant_success)?.renderMode == .screen)
        #expect(EZ2STRScreenEffectDefinition.definition(for: .ef_ui_enchant_success)?.overlayColorStep == 0x0200_0000)
        #expect(EZ2STRScreenEffectDefinition.definition(for: .ef_rune_active_finish)?.overlayColorStep == 0x1000_0000)
    }

    @Test("Supports billboard, ground, and screen render modes plus overlayColor stepping and clamp")
    func renderModesAndOverlayColor() async {
        let billboardDef = EZ2STRScreenEffectDefinition.definition(for: .ef_new_meteorstorm)!
        let groundDef = EZ2STRScreenEffectDefinition.definition(for: .ef_new_meteorstorm_bottom)!
        let screenDef = EZ2STRScreenEffectDefinition.definition(for: .ef_ui_enchant_success)!

        let store = await Self.makeAssetStore(
            strPaths: [billboardDef.strPath, groundDef.strPath, screenDef.strPath]
        )

        let world = MockWorldContext()
        world.terrainYInEffectSpace = EffectSpace.toEffectHeight(2.5)

        let billboard = EZ2STRScreenEffect(
            request: EffectSpawnRequest(effectID: .ef_new_meteorstorm, worldPosition: .zero),
            definition: billboardDef
        )
        let ground = EZ2STRScreenEffect(
            request: EffectSpawnRequest(effectID: .ef_new_meteorstorm_bottom, worldPosition: .zero),
            definition: groundDef
        )
        let screen = EZ2STRScreenEffect(
            request: EffectSpawnRequest(effectID: .ef_ui_enchant_success, worldPosition: .zero),
            definition: screenDef
        )

        #expect(billboard.renderMode == .billboard)
        #expect(ground.renderMode == .ground)
        #expect(screen.renderMode == .screen)

        let context = EffectTickContext(
            world: world,
            assets: store,
            currentTick: 1,
            usesMinimalEffects: false,
            onSpawnChild: { _ in }
        )

        billboard.tick(context: context)
        ground.tick(context: context)

        if store != nil {
            let billboardPayloads = billboard.makeSTRRenderPayloads(fog: Fog(), modelMatrix: matrix_identity_float4x4, world: world)
            let groundPayloads = ground.makeSTRRenderPayloads(fog: Fog(), modelMatrix: matrix_identity_float4x4, world: world)
            #expect(billboardPayloads.first?.mode == .billboard)
            #expect(billboardPayloads.first?.terrainHeight == nil)
            #expect(groundPayloads.first?.mode == .ground)
            #expect(abs((groundPayloads.first?.terrainHeight?(0, 0) ?? 0) - 2.5) < 0.001)
        }

        // 0x0200_0000 per tick reaches 0xAA00_0000 at tick 85 and clamps thereafter
        screen.holdsFinalFrame = true
        for _ in 0..<90 {
            screen.tick(context: context)
        }
        #expect(screen.overlayColor == 0xAA00_0000)
        #expect(abs(screen.overlayAlpha - (170.0 / 255.0)) < 0.001)
    }

    @Test("Head-attached effect applies headHeight, offset deltas, fadePulse scale, and retires when owner disappears")
    func headOffsetAndOwnerLifecycle() {
        let def = EZ2STRScreenEffectDefinition.definition(for: .ef_strangelights)!
        let world = MockWorldContext()
        let ownerID: EffectTargetID = 7
        world.targets[ownerID] = EffectTargetState(
            objectID: ownerID,
            worldPosition: [1, 0, -2],
            headHeight: 2.0
        )

        let effect = EZ2STRScreenEffect(
            request: EffectSpawnRequest(effectID: .ef_strangelights, worldPosition: .zero, ownerObjectID: ownerID),
            definition: def
        )
        #expect(effect.isLooping)

        let context = EffectTickContext(
            world: world,
            assets: nil,
            currentTick: 1,
            usesMinimalEffects: false,
            onSpawnChild: { _ in }
        )

        effect.tick(context: context)
        // baseHeight = 2.0 * 5.0 = 10.0; effectOffsetY = 10.0 + 5.0 - 7.0 = 8.0
        // worldPosition.y += toWorldHeight(-8.0) = 1.6
        #expect(abs(effect.worldPosition.x - 1.0) < 0.001)
        #expect(abs(effect.worldPosition.y - 1.6) < 0.001)
        #expect(abs(effect.worldPosition.z - (-2.0)) < 0.001)
        #expect(abs(effect.transform.offset.x - 5.0) < 0.001)

        effect.fadePulse = true
        effect.fadePulseScale = 0.5
        effect.tick(context: context)
        #expect(abs(effect.worldPosition.y - 0.8) < 0.001)
        #expect(abs(effect.transform.offset.x - 2.5) < 0.001)

        // Removing owner target stops retained/head-attached effect
        world.targets.removeValue(forKey: ownerID)
        effect.tick(context: context)
        #expect(!effect.isAlive)
    }

    @Test("followCamera adapts transform.angle to cameraYawDegrees changes and wraps into [0, 360)")
    func followCameraYawAdaptation() {
        let def = EZ2STRScreenEffectDefinition(
            effectID: .ef_new_meteorstorm,
            strPath: "new_meteostorm\\new_meteostorm\\new_meteostorm.str",
            followCamera: true
        )
        let world = MockWorldContext()
        world.cameraYawDegrees = 30

        let effect = EZ2STRScreenEffect(
            request: EffectSpawnRequest(effectID: .ef_new_meteorstorm, worldPosition: .zero),
            definition: def
        )
        effect.setAngle(10)

        let context = EffectTickContext(
            world: world,
            assets: nil,
            currentTick: 1,
            usesMinimalEffects: false,
            onSpawnChild: { _ in }
        )

        // First tick anchors lastCameraYaw = 30
        effect.tick(context: context)
        #expect(effect.transform.angle == 10)

        // Yaw increases from 30 to 50 -> angle = 30 - 50 + 10 = -10 -> wraps to 350
        world.cameraYawDegrees = 50
        effect.tick(context: context)
        #expect(abs(effect.transform.angle - 350) < 0.001)

        // Yaw decreases from 50 to 20 -> angle = 50 - 20 + 350 = 380 -> wraps to 20
        world.cameraYawDegrees = 20
        effect.tick(context: context)
        #expect(abs(effect.transform.angle - 20) < 0.001)
    }

    @Test("Supports delay, repeat, lifetime, timed/periodic sounds, camera shakes, and level scales")
    func delayRepeatLifetimeEventsAndLevelScales() async {
        let def = EZ2STRScreenEffectDefinition(
            effectID: .ef_new_meteorstorm,
            strPath: "new_meteostorm\\new_meteostorm\\new_meteostorm.str",
            defaultScale: 1.0,
            levelScales: [1: 0.7, 3: 1.25],
            sounds: [EZ2STRScreenEffectDefinition.TimedSound(tick: 1, names: ["effect\\timed.wav"])],
            periodicSound: EZ2STRScreenEffectDefinition.PeriodicSound(startTick: 2, intervalTicks: 3, name: "effect\\pulse.wav"),
            cameraShakeTicks: [4]
        )

        let store = await Self.makeAssetStore(strPaths: [def.strPath], maxKeyframeIndex: 1)
        let world = MockWorldContext()
        let context = EffectTickContext(
            world: world,
            assets: store,
            currentTick: 1,
            usesMinimalEffects: false,
            onSpawnChild: { _ in }
        )

        let effect = EZ2STRScreenEffect(
            request: EffectSpawnRequest(effectID: .ef_new_meteorstorm, worldPosition: .zero, level: 3),
            definition: def
        )
        #expect(effect.transform.scale == 1.25)

        effect.setDelayMilliseconds(32)
        effect.setRepeat(2)
        effect.setLifeTime(frames: 5)

        for _ in 0..<8 {
            effect.tick(context: context)
        }

        #expect(world.playedSounds.map(\.name) == ["effect\\timed.wav", "effect\\pulse.wav", "effect\\pulse.wav"])
        #expect(world.shakeCount == 1)

        if store != nil {
            #expect(!effect.isAlive)
            #expect(effect.isFinished)
        }
    }

    @Test("EffectManager prioritizes particle EZ2STRScreenEffect over RagSTREffect")
    func managerParticlePriority() {
        let manager = EffectManager()
        let world = MockWorldContext()

        #expect(EffectManager.supports(.ef_new_meteorstorm))
        #expect(manager.supports(.ef_new_meteorstorm))
        #expect(manager.supports(.ef_potion1))

        let spawnedID = manager.spawn(EffectSpawnRequest(effectID: .ef_potion1, worldPosition: .zero))
        #expect(spawnedID != nil)
        #expect(manager.activeEffects.first is EZ2STRScreenEffect)

        manager.stepOneTick(world: world)
        #expect(world.playedSounds.map(\.name) == ["_heal_effect.wav"])
    }
}
