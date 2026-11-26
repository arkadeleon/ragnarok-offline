//
//  RagEffectBatch400To499Tests.swift
//  RagnarokEffectsTests
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd
import Testing
@testable import RagnarokEffects

@MainActor
@Suite("RagEffect Batch 400...499 Procedural Effects")
struct RagEffectBatch400To499Tests {
    private final class RecordingWorldContext: EffectWorldContext {
        var cameraWorldPosition: SIMD3<Float> = .zero
        var cameraYawDegrees: Float = 0
        var cameraPitchDegrees: Float = 0
        var targets: [EffectTargetID : EffectTargetState] = [:]
        var playedSounds: [(name: String, position: SIMD3<Float>?)] = []
        var shakeCount: Int = 0
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

        func shakeCamera(amplitude: Float, duration: TimeInterval, frequency: Float) {
            shakeCount += 1
        }

        func applyTargetModifier(_ modifier: EffectTargetModifier, to targetID: EffectTargetID) {
            appliedModifiers.append((targetID, modifier))
        }

        func spawnChildEffect(_ request: EffectSpawnRequest) {}
    }

    private static let procedural400To499EffectIDs: [EffectID] = [
        .ef_bash3d4,
        .ef_napalmvalcan,
        .ef_portal5,
        .ef_magiccrasher2,
        .ef_bottom_spider,
        .ef_bottom_fogwall,
        .ef_baby,
        .ef_soulbreaker2,
        .ef_rainbow,
        .ef_peong,
        .ef_tanji2,
        .ef_pressedbody,
        .ef_spinedbody,
        .ef_kickedbody,
        .ef_airtexture,
        .ef_hitbody,
        .ef_doublegumgang,
        .ef_reflectbody,
        .ef_babybody,
        .ef_babybody2,
        .ef_giantbody,
        .ef_giantbody2,
        .ef_asurabody,
        .ef_4waybody,
        .ef_quakebody,
        .ef_asurabody_monster,
        .ef_hitline3,
        .ef_hitline4,
        .ef_hitline5,
        .ef_hitline6,
        .ef_electric,
        .ef_electric2,
        .ef_hitline7,
        .ef_stormkick,
        .ef_halfsphere,
        .ef_attackenergy,
        .ef_attackenergy2,
        .ef_chemical3,
        .ef_bluecasting,
        .ef_run,
        .ef_stoprun,
        .ef_stopeffect,
        .ef_jumpbody,
        .ef_landbody,
        .ef_foot3,
        .ef_foot4,
        .ef_tae_ready,
        .ef_grandcross2,
        .ef_soulstrike2,
        .ef_yufitel2,
        .ef_npc_stop,
        .ef_darkcasting,
        .ef_gumgangnpc,
        .ef_agiup,
        .ef_jumpkick,
        .ef_quakebody2,
        .ef_stormkick1,
        .ef_stormkick2,
        .ef_stormkick3,
        .ef_stormkick4,
        .ef_stormkick5,
        .ef_stormkick6,
        .ef_stormkick7,
        .ef_spinedbody2,
        .ef_beginasura1,
        .ef_beginasura2,
        .ef_beginasura3,
        .ef_beginasura4,
        .ef_beginasura5,
        .ef_beginasura6,
        .ef_beginasura7,
        .ef_aurablade2,
        .ef_devil1,
        .ef_devil2,
        .ef_devil3,
        .ef_devil4,
        .ef_devil5,
        .ef_devil6,
        .ef_devil7,
        .ef_devil8,
        .ef_devil9,
        .ef_devil10,
        .ef_doublegumgang2,
        .ef_doublegumgang3,
        .ef_blackdevil,
        .ef_flowercast,
        .ef_flowercast2,
        .ef_flowercast3,
        .ef_edp,
        .ef_shieldboomerang2,
        .ef_rg_coin2,
        .ef_guard2,
        .ef_slim,
        .ef_slim2,
        .ef_slim3,
    ]

    @Test("All 95 procedural effects in 400...499 are supported, spawn cleanly, and advance 65 ticks")
    func allBatch400To499EffectsSpawnAndStep() {
        #expect(Self.procedural400To499EffectIDs.count == 95)

        let manager = EffectManager()
        let world = RecordingWorldContext()
        let ownerID: EffectTargetID = 4001
        let sourceID: EffectTargetID = 4002
        world.targets[ownerID] = EffectTargetState(
            objectID: ownerID,
            worldPosition: [10, 0, 10],
            facingAngle: 90
        )
        world.targets[sourceID] = EffectTargetState(
            objectID: sourceID,
            worldPosition: [2, 0, 6],
            facingAngle: 0
        )

        for effectID in Self.procedural400To499EffectIDs {
            #expect(manager.supports(effectID), "Expected EffectManager to support \(effectID.rawValue)")

            manager.spawn(
                EffectSpawnRequest(
                    effectID: effectID,
                    worldPosition: [10, 0, 10],
                    sourceWorldPosition: [2, 0, 6],
                    ownerObjectID: ownerID,
                    targetObjectID: ownerID,
                    sourceObjectID: sourceID,
                    level: 5,
                    duration: 2.0
                )
            )
            #expect(manager.hasEffects)

            for _ in 0..<65 {
                manager.stepOneTick(world: world)
            }

            manager.removeAll()
        }
    }

    @Test("Spot checks primitives, audio, and target modifiers in 400...499")
    func spotCheckKeyBatch400To499Effects() {
        let manager = EffectManager()
        let world = RecordingWorldContext()
        let targetID: EffectTargetID = 201
        world.targets[targetID] = EffectTargetState(
            objectID: targetID,
            worldPosition: [6, 0, -4],
            facingAngle: 90
        )

        // EF_SOULBREAKER2 (409): 8 radial purple slashes + audio + magenta tint
        manager.spawn(EffectSpawnRequest(
            effectID: .ef_soulbreaker2,
            worldPosition: [6, 0, -4],
            targetObjectID: targetID,
            duration: 1.0
        ))
        manager.stepOneTick(world: world)
        let sb2 = manager.activeEffects.first as? RagEffect
        #expect(sb2?.primitives.count == 8)
        #expect(sb2?.primitives.allSatisfy { $0.id == EffectPrimitiveID(rawValue: 92) } == true)
        #expect(world.playedSounds.map(\.name) == [K2L("effect\\메테오 어썰트.wav")])
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .tint(color: SIMD4<Float>(1.0, 0.0, 1.0, 1.0), durationTicks: 2)
        })
        manager.removeAll()

        // EF_TANJI2 (412): pp_tanji2
        manager.spawn(EffectSpawnRequest(
            effectID: .ef_tanji2,
            worldPosition: [6, 0, -4],
            sourceWorldPosition: [0, 0, 0],
            duration: 1.0
        ))
        manager.stepOneTick(world: world)
        #expect((manager.activeEffects.first as? RagEffect)?.primitives.first?.id == .pp_tanji2)
        manager.removeAll()

        // EF_SPINEDBODY (414): cosine-eased 2D sprite plane roll + swing offset
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_spinedbody, worldPosition: [6, 0, -4], targetObjectID: targetID, duration: 1.0))
        manager.stepOneTick(world: world)
        manager.stepOneTick(world: world)
        #expect(world.appliedModifiers.contains {
            guard $0.targetID == targetID, case .spriteRoll(let degrees, durationTicks: 2) = $0.modifier else {
                return false
            }
            return degrees > 0
        })
        #expect(world.appliedModifiers.contains {
            guard $0.targetID == targetID, case .spriteOffset(let offset, durationTicks: 2) = $0.modifier else {
                return false
            }
            return offset.x != 0 || offset.y != 0
        })
        manager.removeAll()

        // EF_BABYBODY2 (421) & EF_GIANTBODY2 (423): scale modifiers
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_babybody2, worldPosition: [6, 0, -4], targetObjectID: targetID, duration: 1.0))
        manager.stepOneTick(world: world)
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .scale(SIMD3<Float>(0.5, 0.5, 0.5), durationTicks: 2)
        })
        manager.removeAll()

        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_giantbody2, worldPosition: [6, 0, -4], targetObjectID: targetID, duration: 1.0))
        manager.stepOneTick(world: world)
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .scale(SIMD3<Float>(1.5, 1.5, 1.5), durationTicks: 2)
        })
        manager.removeAll()

        // EF_4WAYBODY (425): four-way split copies starting at tick 30
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_4waybody, worldPosition: [6, 0, -4], targetObjectID: targetID, duration: 1.0))
        for _ in 0..<32 {
            manager.stepOneTick(world: world)
        }
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .fourWaySplit(spread: 4.0, alpha: 145.0 / 255.0, durationTicks: 2)
        })
        manager.removeAll()

        // EF_STORMKICK (435): 1 texturedMark (103) + 2 cloud11Burst (62) + rotation + tick 5 sound
        world.playedSounds.removeAll()
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_stormkick, worldPosition: [6, 0, -4], targetObjectID: targetID, duration: 1.0))
        for _ in 0..<6 {
            manager.stepOneTick(world: world)
        }
        let stormKick = manager.activeEffects.first as? RagEffect
        #expect(stormKick?.primitives.map(\.id) == [EffectPrimitiveID(rawValue: 103), .pp_wind, .pp_wind])
        #expect(world.playedSounds.map(\.name) == [K2L("effect\\T_회오리차기.wav")])
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .facingYaw(degrees: 30, durationTicks: 2)
        })
        manager.removeAll()

        // EF_ATTACKENERGY2 (438): audio + pp_attackenergy2 on ticks 0 and 4
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_attackenergy2, worldPosition: [0, 0, 0], duration: 1.0))
        for _ in 0..<5 {
            manager.stepOneTick(world: world)
        }
        let ae2 = manager.activeEffects.first as? RagEffect
        #expect(ae2?.primitives.count == 2)
        #expect(ae2?.primitives.allSatisfy { $0.id == .pp_attackenergy2 } == true)
        #expect(world.playedSounds.map(\.name) == [K2L("effect\\T_마법반사.wav")])
        manager.removeAll()

        // EF_EDP (493): enchantPoison2 + magenta/white alternating tint
        world.playedSounds.removeAll()
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_edp, worldPosition: [6, 0, -4], targetObjectID: targetID, duration: 1.0))
        manager.stepOneTick(world: world)
        #expect((manager.activeEffects.first as? RagEffect)?.primitives.first?.id == .pp_3dparticle)
        #expect(world.playedSounds.map(\.name) == ["effect\\assasin_enchantpoison.wav"])
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .tint(color: SIMD4<Float>(1.0, 0.0, 1.0, 1.0), durationTicks: 2)
        })
        manager.removeAll()

        // EF_SLIM (497): texturedRain (87) + texturedLevelRing (88)
        manager.spawn(EffectSpawnRequest(effectID: .ef_slim, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        let slim = manager.activeEffects.first as? RagEffect
        #expect(slim?.primitives.map(\.id) == [EffectPrimitiveID(rawValue: 87), EffectPrimitiveID(rawValue: 88)])
        manager.removeAll()
    }
}
