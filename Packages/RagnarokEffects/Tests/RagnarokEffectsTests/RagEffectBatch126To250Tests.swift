//
//  RagEffectBatch126To250Tests.swift
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
@Suite("RagEffect Batch 126...250 Procedural Effects")
struct RagEffectBatch126To250Tests {
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

    private static let batch2NewEffectIDs: [EffectID] = [
        .ef_overthrust,
        .ef_twohandquicken,
        .ef_grimtoothatk,
        .ef_bottom2,
        .ef_firepillaron,
        .ef_revive,
        .ef_heavensdrive,
        .ef_toprank,
        .ef_party,
        .ef_rain,
        .ef_snow,
        .ef_sakura,
        .ef_status_state,
        .ef_banjjakii,
        .ef_makeblur,
        .ef_cartrevolution,
        .ef_venomdust2,
        .ef_changedark,
        .ef_changefire,
        .ef_changecold,
        .ef_changewind,
        .ef_changeflame,
        .ef_changeearth,
        .ef_chaingeholy,
        .ef_changepoison,
        .ef_hitdark,
        .ef_sui_explosion,
        .ef_darkattack,
        .ef_telekhit,
        .ef_level99,
        .ef_level99_2,
        .ef_level99_3,
        .ef_gumgang,
        .ef_darkbreath,
        .ef_summonslave,
        .ef_blooddrain,
        .ef_energydrain,
        .ef_potion_con,
        .ef_potion_,
        .ef_potion_berserk,
        .ef_potionpillar,
        .ef_defender,
        .ef_ganbantein,
        .ef_volcano,
        .ef_grandcross,
        .ef_intimidate,
        .ef_chookgi,
        .ef_cloud,
        .ef_cloud2,
        .ef_mappillar,
        .ef_linelink,
        .ef_cloud3,
        .ef_deluge,
        .ef_violentgale,
        .ef_landprotector,
        .ef_bottom_vo,
        .ef_bottom_de,
        .ef_bottom_vi,
        .ef_bottom_la,
        .ef_magicrod,
        .ef_mappillar2,
        .ef_providence,
        .ef_shieldboomerang,
        .ef_spearquicken,
    ]

    @Test("All 64 new Batch 2 effects in 126...250 are supported, spawn cleanly, and advance 65 ticks")
    func allBatch2EffectsSpawnAndStep() {
        #expect(Self.batch2NewEffectIDs.count == 64)

        let manager = EffectManager()
        let world = RecordingWorldContext()
        let ownerID: EffectTargetID = 2001
        let sourceID: EffectTargetID = 2002
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

        for effectID in Self.batch2NewEffectIDs {
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

    @Test("Spot checks primitives, audio, camera shake, modifiers, and hybrid STR in 126...250")
    func spotCheckKeyBatch2Effects() {
        let manager = EffectManager()
        let world = RecordingWorldContext()
        let targetID: EffectTargetID = 88
        world.targets[targetID] = EffectTargetState(
            objectID: targetID,
            worldPosition: [5, 0, -5],
            facingAngle: 90
        )

        // EF_OVERTHRUST (128): two sounds + 2D ring
        manager.spawn(EffectSpawnRequest(effectID: .ef_overthrust, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        let overthrust = manager.activeEffects.first as? RagEffect
        #expect(overthrust?.primitives.count == 1)
        #expect(overthrust?.primitives.first?.id == .pp_2dcircle)
        #expect(world.playedSounds.map(\.name) == [
            "effect\\black_overthrust.wav",
            "effect\\EF_StoneCurse.wav",
        ])
        manager.removeAll()

        // EF_TWOHANDQUICKEN (130) & EF_SPEARQUICKEN (250): hybrid STR + audio
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_twohandquicken, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        #expect(world.playedSounds.map(\.name) == ["effect\\knight_twohandquicken.wav"])
        manager.removeAll()

        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_spearquicken, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        #expect(world.playedSounds.map(\.name) == ["effect\\knight_twohandquicken.wav"])
        manager.removeAll()

        // EF_CARTREVOLUTION (170): blasts at ticks 7 and 20
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_cartrevolution, worldPosition: [0, 0, 0], duration: 2.0))
        for _ in 0..<22 {
            manager.stepOneTick(world: world)
        }
        #expect(world.playedSounds.map(\.name) == [
            "effect\\EF_MagnumBreak.wav",
            "effect\\EF_MagnumBreak.wav",
        ])
        let cartRev = manager.activeEffects.first as? RagEffect
        #expect(cartRev?.primitives.count == 4)
        manager.removeAll()

        // EF_CHANGEDARK (172): 4-slot pp_3dcasting
        manager.spawn(EffectSpawnRequest(effectID: .ef_changedark, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        let changeDark = manager.activeEffects.first as? RagEffect
        #expect(changeDark?.primitives.first?.id == .pp_3dcasting)
        manager.removeAll()

        // EF_HITDARK (180): 1 cylinder + 4 particles
        manager.spawn(EffectSpawnRequest(effectID: .ef_hitdark, worldPosition: [0, 0, 0]))
        manager.stepOneTick(world: world)
        let hitDark = manager.activeEffects.first as? RagEffect
        #expect(hitDark?.primitives.count == 5)
        manager.removeAll()

        // EF_SUI_EXPLOSION (183): hit2(1) on tick 0 + 3 camera shakes on ticks 3/7/9
        world.playedSounds.removeAll()
        world.shakeCount = 0
        manager.spawn(EffectSpawnRequest(effectID: .ef_sui_explosion, worldPosition: [0, 0, 0], duration: 1.0))
        for _ in 0..<10 {
            manager.stepOneTick(world: world)
        }
        #expect(world.playedSounds.map(\.name) == ["effect\\EF_hit2.wav"])
        #expect(world.shakeCount == 3)
        manager.removeAll()

        // EF_LEVEL99 (200), EF_LEVEL99_2 (201), EF_LEVEL99_3 (202), EF_GUMGANG (203)
        manager.spawn(EffectSpawnRequest(effectID: .ef_level99, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        #expect((manager.activeEffects.first as? RagEffect)?.primitives.first?.id == .pp_3dcasting)
        manager.removeAll()

        manager.spawn(EffectSpawnRequest(effectID: .ef_level99_2, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        #expect((manager.activeEffects.first as? RagEffect)?.primitives.first?.id == EffectPrimitiveID(rawValue: 28))
        manager.removeAll()

        manager.spawn(EffectSpawnRequest(effectID: .ef_level99_3, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        #expect((manager.activeEffects.first as? RagEffect)?.primitives.first?.id == EffectPrimitiveID(rawValue: 29))
        manager.removeAll()

        manager.spawn(EffectSpawnRequest(effectID: .ef_gumgang, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        #expect((manager.activeEffects.first as? RagEffect)?.primitives.first?.id == EffectPrimitiveID(rawValue: 35))
        manager.removeAll()

        // EF_POTION_CON (218) & EF_POTION_BERSERK (220)
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_potion_con, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        #expect(world.playedSounds.map(\.name) == ["effect\\ac_concentration.wav"])
        #expect((manager.activeEffects.first as? RagEffect)?.primitives.first?.id == .pp_3dcylinder)
        manager.removeAll()

        world.playedSounds.removeAll()
        world.shakeCount = 0
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(
            effectID: .ef_potion_berserk,
            worldPosition: [5, 0, -5],
            targetObjectID: targetID,
            duration: 3.0
        ))
        for _ in 0..<20 {
            manager.stepOneTick(world: world)
        }
        #expect(world.shakeCount == 1)
        #expect(world.playedSounds.map(\.name) == ["effect\\ac_concentration.wav"])
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID
                && $0.modifier == .tint(color: SIMD4<Float>(250.0 / 255.0, 120.0 / 255.0, 120.0 / 255.0, 1.0), durationTicks: 2)
        })
        manager.removeAll()

        // EF_GRANDCROSS (226)
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_grandcross, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        let grandCross = manager.activeEffects.first as? RagEffect
        #expect(grandCross?.primitives.map(\.id) == [.pp_gi_3, .pp_grandcross2])
        #expect(world.playedSounds.map(\.name) == ["effect\\cru_grand cross.wav"])
        manager.removeAll()

        // EF_INTIMIDATE (227): 20 sprays + tick 0 & tick 35 audio
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_intimidate, worldPosition: [0, 0, 0], duration: 2.0))
        for _ in 0..<36 {
            manager.stepOneTick(world: world)
        }
        let intimidate = manager.activeEffects.first as? RagEffect
        #expect(intimidate?.primitives.count == 20)
        #expect(world.playedSounds.map(\.name) == [
            "effect\\EF_Bash.wav",
            "effect\\rog_intimidate.wav",
        ])
        manager.removeAll()

        // EF_MAGICROD (244) & EF_PROVIDENCE (248) & EF_SHIELDBOOMERANG (249)
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_magicrod, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        #expect(world.playedSounds.map(\.name) == ["effect\\sage_magic rod.wav"])
        manager.removeAll()

        manager.spawn(EffectSpawnRequest(effectID: .ef_providence, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        #expect((manager.activeEffects.first as? RagEffect)?.primitives.first?.id == EffectPrimitiveID(rawValue: 41))
        manager.removeAll()

        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(
            effectID: .ef_shieldboomerang,
            worldPosition: [10, 0, 0],
            sourceWorldPosition: [0, 0, 0],
            duration: 1.0
        ))
        manager.stepOneTick(world: world)
        #expect(world.playedSounds.map(\.name) == ["effect\\cru_shield boomerang.wav"])
        #expect((manager.activeEffects.first as? RagEffect)?.primitives.first?.id == .pp_shieldboomerang)
        manager.removeAll()

        // EF_MAKEBLUR (166): applies blur afterimage and tint modifier
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(
            effectID: .ef_makeblur,
            worldPosition: [5, 0, -5],
            targetObjectID: targetID,
            duration: 1.0
        ))
        manager.stepOneTick(world: world)
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID
                && $0.modifier == .afterimage(style: .blur, tint: SIMD4<Float>(250 / 255.0, 250 / 255.0, 250 / 255.0, 1), durationTicks: 15)
        })
        manager.removeAll()
    }
}
