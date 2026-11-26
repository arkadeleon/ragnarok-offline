//
//  RagEffectBatch251To399Tests.swift
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
@Suite("RagEffect Batch 251...399 Procedural Effects")
struct RagEffectBatch251To399Tests {
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

    private static let procedural251To399EffectIDs: [EffectID] = [
        // 251...299
        .ef_reflectshield,
        .ef_absorbspirits,
        .ef_steelbody,
        .ef_mappillar3,
        .ef_mappillar4,
        .ef_gumgang2,
        .ef_teihit1,
        .ef_gumgang3,
        .ef_teihit2,
        .ef_tanji,
        .ef_teihit1x,
        .ef_chimto,
        .ef_rg_coin,
        .ef_backstap,
        .ef_teihit3,
        .ef_bottom_dissonance,
        .ef_bottom_lullaby,
        .ef_bottom_richmankim,
        .ef_bottom_eternalchaos,
        .ef_bottom_drumbattlefield,
        .ef_bottom_ringnibelungen,
        .ef_bottom_rokisweil,
        .ef_bottom_intoabyss,
        .ef_bottom_siegfried,
        .ef_bottom_whistle,
        .ef_bottom_assassincross,
        .ef_bottom_poembragi,
        .ef_bottom_appleidun,
        .ef_bottom_uglydance,
        .ef_bottom_humming,
        .ef_bottom_dontforgetme,
        .ef_bottom_fortunekiss,
        .ef_bottom_serviceforyou,
        .ef_talk_frostjoke,
        .ef_talk_scream,
        .ef_pokjuk,
        .ef_throwitem,
        .ef_throwitem2,
        // 300...399
        .ef_chemicalprotection,
        .ef_pokjuk_sound,
        .ef_demonstration,
        .ef_chemical2,
        .ef_teleportation2,
        .ef_forestlight,
        .ef_throwitem3,
        .ef_firstaid,
        .ef_sprinklesand,
        .ef_heal,
        .ef_heal2,
        .ef_exit2,
        .ef_glasswall2,
        .ef_readyportal2,
        .ef_portal2,
        .ef_bottom_mag,
        .ef_bottom_sanc,
        .ef_heal3,
        .ef_warpzone2,
        .ef_forestlight2,
        .ef_forestlight3,
        .ef_forestlight4,
        .ef_heal4,
        .ef_foot,
        .ef_foot2,
        .ef_beginasura,
        .ef_tripleattack,
        .ef_hitline,
        .ef_hptime,
        .ef_sptime,
        .ef_maple,
        .ef_blind,
        .ef_poison,
        .ef_guard,
        .ef_joblvup50,
        .ef_angel2,
        .ef_magnum2,
        .ef_callzone,
        .ef_portal3,
        .ef_couplecasting,
        .ef_heartcasting,
        .ef_entry2,
        .ef_saintwing,
        .ef_spherewind,
        .ef_colorpaper,
        .ef_lightsphere,
        .ef_waterfall,
        .ef_waterfall_90,
        .ef_waterfall_small,
        .ef_waterfall_small_90,
        .ef_waterfall_t2,
        .ef_waterfall_t2_90,
        .ef_waterfall_small_t2,
        .ef_waterfall_small_t2_90,
        .ef_ghost,
        .ef_bat,
        .ef_bat2,
        .ef_soulbreaker,
        .ef_level99_4,
        .ef_vallentine,
        .ef_vallentine2,
        .ef_pressure,
        .ef_bash3d,
        .ef_aurablade,
        .ef_redbody,
        .ef_bottom_gospel,
        .ef_dragonsmoke,
        .ef_bottom_basilica,
        .ef_assumptio,
        .ef_hitline2,
        .ef_bash3d2,
        .ef_energydrain2,
        .ef_transbluebody,
        .ef_magiccrasher,
        .ef_lightsphere2,
        .ef_lightblade,
        .ef_energydrain3,
        .ef_linelink2,
        .ef_linklight,
        .ef_truesight,
        .ef_falconassault,
        .ef_tripleattack2,
        .ef_portal4,
        .ef_tripleattack3,
        .ef_spherewind2,
        .ef_linelink3,
        .ef_pinkbody,
        .ef_level99_5,
        .ef_level99_6,
        .ef_bash3d3,
    ]

    @Test("All 128 procedural effects in 251...399 are supported, spawn cleanly, and advance 65 ticks")
    func allBatch251To399EffectsSpawnAndStep() {
        #expect(Self.procedural251To399EffectIDs.count == 128)

        let manager = EffectManager()
        let world = RecordingWorldContext()
        let ownerID: EffectTargetID = 3001
        let sourceID: EffectTargetID = 3002
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

        for effectID in Self.procedural251To399EffectIDs {
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

    @Test("Spot checks primitives, audio, camera shake, hybrid STR, and target modifiers in 251...399")
    func spotCheckKeyBatch251To399Effects() {
        let manager = EffectManager()
        let world = RecordingWorldContext()
        let targetID: EffectTargetID = 101
        let sourceID: EffectTargetID = 102
        world.targets[targetID] = EffectTargetState(
            objectID: targetID,
            worldPosition: [6, 0, -4],
            facingAngle: 90
        )
        world.targets[sourceID] = EffectTargetState(
            objectID: sourceID,
            worldPosition: [0, 0, 0],
            facingAngle: 0
        )

        // EF_TANJI (265): audio + pp_shieldboomerang
        manager.spawn(EffectSpawnRequest(
            effectID: .ef_tanji,
            worldPosition: [6, 0, -4],
            sourceWorldPosition: [0, 0, 0],
            duration: 1.0
        ))
        manager.stepOneTick(world: world)
        #expect((manager.activeEffects.first as? RagEffect)?.primitives.first?.id == .pp_shieldboomerang)
        #expect(world.playedSounds.map(\.name) == [K2L("effect\\mon_탄지신통.wav")])
        manager.removeAll()

        // EF_THROWITEM (298): pp_throwitem
        manager.spawn(EffectSpawnRequest(
            effectID: .ef_throwitem,
            worldPosition: [6, 0, -4],
            sourceWorldPosition: [0, 0, 0],
            duration: 1.0
        ))
        manager.stepOneTick(world: world)
        #expect((manager.activeEffects.first as? RagEffect)?.primitives.first?.id == .pp_throwitem)
        manager.removeAll()

        // EF_CHEMICAL2 (303): 2 slash fans at tick 40, camera shake + sound at tick 44, flash modifier
        world.playedSounds.removeAll()
        world.shakeCount = 0
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(
            effectID: .ef_chemical2,
            worldPosition: [6, 0, -4],
            targetObjectID: targetID,
            duration: 2.0
        ))
        for _ in 0..<46 {
            manager.stepOneTick(world: world)
        }
        let chem2 = manager.activeEffects.first as? RagEffect
        #expect(chem2?.primitives.count == 2)
        #expect(chem2?.primitives.allSatisfy { $0.id == .pp_chemical2 } == true)
        #expect(world.shakeCount == 1)
        #expect(world.playedSounds.map(\.name) == [K2L("effect\\연주붕격.wav")])
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID
                && $0.modifier == .flash(color: SIMD4<Float>(1.0, 1.0, 150.0 / 255.0, 1.0), durationTicks: 2)
        })
        manager.removeAll()

        // EF_GLASSWALL2 (315): hybrid SafetyWall.str + primitive 60 + sound
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_glasswall2, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        #expect((manager.activeEffects.first as? RagEffect)?.primitives.first?.id == EffectPrimitiveID(rawValue: 60))
        #expect(world.playedSounds.map(\.name) == ["effect\\EF_GlassWall.wav"])
        manager.removeAll()

        // EF_HEARTCASTING (343): 20 heart-curve ringRedPulse primitives + begin-spell audio
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_heartcasting, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        let heart = manager.activeEffects.first as? RagEffect
        #expect(heart?.primitives.count == 20)
        #expect(heart?.primitives.allSatisfy { $0.id == EffectPrimitiveID(rawValue: 110) } == true)
        #expect(world.playedSounds.map(\.name) == ["effect\\EF_BeginSpell.wav"])
        manager.removeAll()

        // EF_WATERFALL (349): 1 waterfall (79) + 40 frostScatter (80)
        manager.spawn(EffectSpawnRequest(effectID: .ef_waterfall, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        let waterfall = manager.activeEffects.first as? RagEffect
        #expect(waterfall?.primitives.count == 41)
        #expect(waterfall?.primitives.first?.id == EffectPrimitiveID(rawValue: 79))
        manager.removeAll()

        // EF_PRESSURE (365): texturedRain (87) + texturedLevelRing (88) + audio on tick 3
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_pressure, worldPosition: [0, 0, 0], duration: 1.0))
        for _ in 0..<5 {
            manager.stepOneTick(world: world)
        }
        let pressure = manager.activeEffects.first as? RagEffect
        #expect(pressure?.primitives.map(\.id) == [EffectPrimitiveID(rawValue: 87), EffectPrimitiveID(rawValue: 88)])
        #expect(world.playedSounds.map(\.name) == [K2L("effect\\프레셔.wav")])
        manager.removeAll()

        // EF_REDBODY (368), EF_ASSUMPTIO (375), EF_PINKBODY (396): target modifiers
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_redbody, worldPosition: [6, 0, -4], targetObjectID: targetID, duration: 1.0))
        manager.stepOneTick(world: world)
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID
                && $0.modifier == .tint(color: SIMD4<Float>(1.0, 100.0 / 255.0, 100.0 / 255.0, 1.0), durationTicks: 2)
        })
        manager.removeAll()

        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_assumptio, worldPosition: [6, 0, -4], targetObjectID: targetID, duration: 1.0))
        manager.stepOneTick(world: world)
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID
                && $0.modifier == .flash(color: SIMD4<Float>(1.0, 1.0, 1.0, 1.0), durationTicks: 2)
        })
        manager.removeAll()

        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_pinkbody, worldPosition: [6, 0, -4], targetObjectID: targetID, duration: 1.0))
        manager.stepOneTick(world: world)
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID
                && $0.modifier == .flash(color: SIMD4<Float>(1.0, 89.0 / 255.0, 182.0 / 255.0, 1.0), durationTicks: 2)
        })
        manager.removeAll()

        // EF_FALCONASSAULT (387): shake + spin rotation + white tint at tick 30
        world.shakeCount = 0
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_falconassault, worldPosition: [6, 0, -4], targetObjectID: targetID, duration: 2.0))
        for _ in 0..<32 {
            manager.stepOneTick(world: world)
        }
        #expect(world.shakeCount == 1)
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .rotation(SIMD3<Float>(0, 30, 0), durationTicks: 2)
        })
        manager.removeAll()

        // EF_LINELINK3 (395): strong-typed target link with maxHeight 0.7
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(
            effectID: .ef_linelink3,
            worldPosition: [6, 0, -4],
            sourceWorldPosition: [0, 0, 0],
            ownerObjectID: targetID,
            targetObjectID: targetID,
            sourceObjectID: sourceID,
            duration: 1.0
        ))
        manager.stepOneTick(world: world)
        let link3 = manager.activeEffects.first as? RagEffect
        #expect(link3?.primitives.first?.id == .pp_linelink)
        #expect(link3?.primitives.first?.state.slots[0].targetObjectID == sourceID)
        #expect(link3?.primitives.first?.state.slots[0].maxHeight == 0.7)
        #expect(world.playedSounds.map(\.name) == [K2L("effect\\소울 체인지.wav")])
        manager.removeAll()
    }
}
