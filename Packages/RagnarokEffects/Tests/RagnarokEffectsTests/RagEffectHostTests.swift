//
//  RagEffectHostTests.swift
//  RagnarokEffectsTests
//
//  Created by Leon Li on 2026/11/26.
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
@Suite("RagEffect Host, Hybrid STR, and Target Modifiers")
struct RagEffectHostTests {
    private final class RecordingWorldContext: EffectWorldContext {
        var cameraWorldPosition: SIMD3<Float> = .zero
        var cameraYawDegrees: Float = 0
        var cameraPitchDegrees: Float = 0
        var targets: [EffectTargetID : EffectTargetState] = [:]
        var playedSounds: [(name: String, position: SIMD3<Float>?)] = []
        var appliedModifiers: [(targetID: EffectTargetID, modifier: EffectTargetModifier)] = []

        func terrainHeight(atEffectX x: Float, effectZ z: Float) -> Float {
            0
        }

        func targetState(for targetID: EffectTargetID) -> EffectTargetState? {
            targets[targetID]
        }

        func playSound(named name: String, atWorldPosition position: SIMD3<Float>?, delay: TimeInterval) {
            playedSounds.append((name, position))
        }

        func shakeCamera(amplitude: Float, duration: TimeInterval, frequency: Float) {}

        func applyTargetModifier(_ modifier: EffectTargetModifier, to targetID: EffectTargetID) {
            appliedModifiers.append((targetID, modifier))
        }

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
            for value: Float in [0, 0, 1, 0, 1, 1, 0, 1] {
                appendFloat(value)
            }
            for value: Float in [-10, 10, 10, -10, -10, -10, 10, 10] {
                appendFloat(value)
            }
            appendFloat(0)
            appendInt32(0)
            appendFloat(0)
            appendFloat(0)
            for _ in 0..<4 {
                appendFloat(255)
            }
            appendInt32(5)
            appendInt32(6)
            appendInt32(0)
        }

        return data
    }

    private static func makeAssetStore(
        strPaths: [String],
        maxKeyframeIndex: Int32 = 2,
        usesMinimalEffects: Bool = false
    ) async -> EffectAssetStore? {
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
            await store.preloadSTRAsset(atPath: path, usesMinimalEffects: usesMinimalEffects)
        }
        return store
    }

    @Test("RagEffect initializes extended host fields and syncs initial target facing angle once")
    func hostFieldDefaultsAndInitialFacingSync() {
        let targetID: EffectTargetID = 77
        let world = RecordingWorldContext()
        world.targets[targetID] = EffectTargetState(
            objectID: targetID,
            worldPosition: [2, 0, -4],
            facingAngle: 135
        )

        let request = EffectSpawnRequest(
            effectID: .ef_bash,
            worldPosition: .zero,
            ownerObjectID: targetID,
            targetObjectID: targetID
        )
        let effect = RagEffect(id: UUID(), request: request, duration: 5) { _, _ in true }

        #expect(effect.longitude == 0)
        #expect(effect.latitude == 0)
        #expect(effect.defZ == 0)
        #expect(effect.isDirection == 0)
        #expect(effect.tag == 0)
        #expect(effect.visibilityFlags == 0)
        #expect(effect.forceRender == false)
        #expect(effect.strPath == nil)

        let context = EffectTickContext(world: world, assets: nil, currentTick: 1, usesMinimalEffects: false, onSpawnChild: { _ in })
        effect.tick(context: context)
        #expect(effect.longitude == 135)

        // Subsequent target rotation does not overwrite initial longitude.
        world.targets[targetID]?.facingAngle = 270
        effect.tick(context: context)
        #expect(effect.longitude == 135)
    }

    @Test("RagEffect supports hybrid STR playback alongside primitives and cleans up on completion")
    func hybridSTRAndPrimitiveCollection() async {
        guard let assets = await Self.makeAssetStore(strPaths: ["hybrid.str"], maxKeyframeIndex: 2) else {
            return
        }

        let world = RecordingWorldContext()
        let manager = EffectManager(assetStore: assets)
        let testID = EffectID(rawValue: 99_531)

        manager.registerRagEffect(for: testID) { id, request in
            let effect = RagEffect(id: id, request: request, duration: 10) { effect, context in
                if effect.stateCnt == 0 {
                    effect.configureSTR(path: "hybrid.str")
                    let prim = effect.launchPrimitive(.pp_particle_up)
                    prim.state.duration = 5
                    prim.state.slots[0].life = 1
                }
                return effect.processEZ2STR(
                    offset: SIMD3<Float>(12, -40, 5),
                    atEffectPosition: SIMD3<Float>(10, -5, -15),
                    context: context
                )
            }
            return effect
        }

        manager.spawn(EffectSpawnRequest(effectID: testID, worldPosition: .zero))

        // Tick 1: frame 0 of STR is active and primitive 59 is active.
        manager.stepOneTick(world: world)
        let ragEffect = manager.activeEffects.compactMap { $0 as? RagEffect }.first
        #expect(ragEffect?.defZ == 1)
        #expect(ragEffect?.primitives.count == 1)

        let strPayloads = manager.collectSTRPayloads(fog: Fog(), world: world)
        #expect(strPayloads.count == 1)
        #expect(strPayloads[0].transform.offset == SIMD2<Float>(12, -40))
        #expect(strPayloads[0].worldPosition == EffectSpace.toWorldPosition(SIMD3<Float>(10, -5, -15)))

        let primPayloads = manager.collectPrimitivePayloads(fog: Fog(), world: world)
        #expect(!primPayloads.isEmpty || ragEffect?.primitives.isEmpty == false)

        // Tick 2: frame 1, Tick 3: frame 2 (final keyframe), Tick 4: STR finishes and retires master & child primitive.
        manager.stepOneTick(world: world)
        manager.stepOneTick(world: world)
        manager.stepOneTick(world: world)

        #expect(ragEffect?.isMasterAlive == false)
        #expect(ragEffect?.primitives.isEmpty == true)
        #expect(manager.collectSTRPayloads(fog: Fog(), world: world).isEmpty)
        #expect(!manager.hasEffects)
    }

    @Test("RagEffect configureSTRFromDefinition resolves minimal STR paths and default defZ")
    func definitionResolutionAndDefZ() async {
        guard let assets = await Self.makeAssetStore(
            strPaths: ["cure_min.str"],
            maxKeyframeIndex: 1,
            usesMinimalEffects: true
        ) else {
            return
        }

        let world = RecordingWorldContext()
        let request = EffectSpawnRequest(effectID: .ef_cure, worldPosition: [2, 0, 3])
        let effect = RagEffect(id: UUID(), request: request, duration: 10) { effect, context in
            effect.processEZ2STRRaised(context: context)
        }
        let context = EffectTickContext(
            world: world,
            assets: assets,
            currentTick: 1,
            usesMinimalEffects: true,
            onSpawnChild: { _ in }
        )

        effect.tick(context: context)
        #expect(effect.strPath == "cure_min.str")
        #expect(effect.defZ == 0)
        #expect(effect.makeSTRRenderPayloads(fog: Fog(), modelMatrix: matrix_identity_float4x4, world: world).count == 1)

        effect.stop()
        #expect(effect.makeSTRRenderPayloads(fog: Fog(), modelMatrix: matrix_identity_float4x4, world: world).isEmpty)
    }

    @Test("Target modifier helpers emit expected tints, afterimages, cloaking, and coloredFlash primitive")
    func targetModifierHelpers() {
        let targetID: EffectTargetID = 101
        let world = RecordingWorldContext()
        world.targets[targetID] = EffectTargetState(objectID: targetID, worldPosition: [1, 0, 2])
        let context = EffectTickContext(world: world, assets: nil, currentTick: 1, usesMinimalEffects: false, onSpawnChild: { _ in })

        let request = EffectSpawnRequest(effectID: .ef_bash, worldPosition: .zero, targetObjectID: targetID)
        let effect = RagEffect(id: UUID(), request: request, duration: 30)

        // 1. spawnBlurAfterimage (normal RGB, duration == 30 spawns .blur afterimage + tint)
        effect.spawnBlurAfterimage(tintRGB: SIMD3<Float>(100, 150, 255), context: context)
        #expect(world.appliedModifiers.count == 2)
        if case .tint(let color, let ticks) = world.appliedModifiers[0].modifier {
            #expect(abs(color.x - 100.0 / 255.0) < 0.001)
            #expect(abs(color.y - 150.0 / 255.0) < 0.001)
            #expect(abs(color.z - 1.0) < 0.001)
            #expect(ticks == 2)
        } else {
            Issue.record("Expected tint modifier")
        }
        if case .afterimage(let style, let tint, let ticks) = world.appliedModifiers[1].modifier {
            #expect(style == .blur)
            #expect(tint != nil)
            #expect(ticks == 15)
        } else {
            Issue.record("Expected blur afterimage modifier")
        }

        // Sentinel -2 applies tint only without afterimage
        world.appliedModifiers.removeAll()
        effect.spawnBlurAfterimage(tintRGB: SIMD3<Float>(-2, 0, 0), context: context)
        #expect(world.appliedModifiers.count == 1)
        if case .tint(let color, _) = world.appliedModifiers[0].modifier {
            #expect(abs(color.x - 250.0 / 255.0) < 0.001)
            #expect(abs(color.y - 250.0 / 255.0) < 0.001)
            #expect(abs(color.z - 200.0 / 255.0) < 0.001)
        } else {
            Issue.record("Expected sentinel -2 tint modifier")
        }

        // 2. spawnHallucinationOnce emits afterimage at stateCnt == 0 only, and wraps 9998 -> 0
        world.appliedModifiers.removeAll()
        effect.stateCnt = 9998
        effect.spawnHallucinationOnce(tintRGB: SIMD3<Float>(255, 100, 100), context: context)
        #expect(effect.stateCnt == 0)
        #expect(world.appliedModifiers.contains {
            if case .afterimage(.hallucination, _, _) = $0.modifier {
                return true
            }
            return false
        })

        world.appliedModifiers.removeAll()
        effect.stateCnt = 1
        effect.spawnHallucinationOnce(tintRGB: SIMD3<Float>(255, 100, 100), context: context)
        #expect(world.appliedModifiers.count == 1) // tint only

        // 3. spawnPaleBlur & spawnLightBlur
        world.appliedModifiers.removeAll()
        effect.stateCnt = 20
        effect.spawnPaleBlur(context: context)
        #expect(world.appliedModifiers.contains {
            if case .afterimage(.paleBlur, _, 20) = $0.modifier {
                return true
            }
            return false
        })

        world.appliedModifiers.removeAll()
        effect.stateCnt = 10
        effect.spawnLightBlur(context: context)
        #expect(world.appliedModifiers.contains {
            if case .afterimage(.lightBlur, _, 20) = $0.modifier {
                return true
            }
            return false
        })

        // 4. assassinCloaking & assassinCloakingClear
        world.appliedModifiers.removeAll()
        world.playedSounds.removeAll()
        effect.stateCnt = 0
        effect.assassinCloaking(context: context)
        #expect(world.playedSounds.map(\.name) == ["effect\\assasin_cloaking.wav"])
        #expect(world.appliedModifiers.contains {
            if case .cloaking(let alpha) = $0.modifier {
                return abs(alpha - 50.0 / 255.0) < 0.001
            }
            return false
        })

        world.appliedModifiers.removeAll()
        effect.assassinCloakingClear(context: context)
        #expect(world.appliedModifiers.contains {
            if case .tint(let color, 2) = $0.modifier {
                return color == SIMD4<Float>(0, 0, 0, 1)
            }
            return false
        })

        // 5. coloredFlash wraps 99_999_998 and launches primitive 172 with packed argb
        effect.stateCnt = 99_999_998
        let initialY = effect.position.y
        effect.coloredFlash(flag: 2, red: 0x12, green: 0x34, blue: 0x56, context: context)
        #expect(effect.stateCnt == 0)
        #expect(effect.duration == 99_999_999)
        #expect(effect.position.y == initialY - 9.0)
        let flashPrim = effect.primitives.last
        #expect(flashPrim?.id.rawValue == 172)
        #expect((flashPrim?.state.renderFlag ?? 0) & EffectPrimitiveState.RenderFlag.noDepth != 0)
        #expect(flashPrim?.state.argb == 0x0056_3412)
        #expect(flashPrim?.state.slots[0].flag1[10] == 2)
    }
}
