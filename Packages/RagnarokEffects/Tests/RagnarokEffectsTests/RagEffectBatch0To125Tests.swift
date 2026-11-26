//
//  RagEffectBatch0To125Tests.swift
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
@Suite("RagEffect Batch 0...125 Procedural Effects")
struct RagEffectBatch0To125Tests {
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

    private static let batch1NewEffectIDs: [EffectID] = [
        .ef_hit1,
        .ef_hit2,
        .ef_hit3,
        .ef_hit4,
        .ef_hit5,
        .ef_hit6,
        .ef_exit,
        .ef_warp,
        .ef_enhance,
        .ef_coin,
        .ef_endure,
        .ef_beginspell,
        .ef_glasswall,
        .ef_healsp,
        .ef_magnumbreak,
        .ef_pattack,
        .ef_detoxication,
        .ef_sight,
        .ef_fireball,
        .ef_icearrow,
        .ef_frostdiver,
        .ef_firearrow,
        .ef_napalmbeat,
        .ef_ruwach,
        .ef_teleportation,
        .ef_readyportal,
        .ef_portal,
        .ef_incagility,
        .ef_decagility,
        .ef_aqua,
        .ef_signum,
        .ef_blessing,
        .ef_incagidex,
        .ef_smoke,
        .ef_firefly,
        .ef_sandwind,
        .ef_torch,
        .ef_spraypond,
        .ef_firesplashhit,
        .ef_coldhit,
        .ef_poisonhit,
        .ef_beginspell2,
        .ef_beginspell3,
        .ef_beginspell4,
        .ef_beginspell5,
        .ef_beginspell6,
        .ef_beginspell7,
        .ef_lockon,
        .ef_warpzone,
        .ef_sightrasher,
        .ef_barrier,
        .ef_cone,
        .ef_sphere,
        .ef_bowlingbash,
        .ef_icewall,
        .ef_earthspike,
        .ef_spearbmr,
        .ef_pierce,
        .ef_turnundead,
        .ef_aspersio,
        .ef_stormgust,
        .ef_yufitel,
        .ef_yufitelhit,
        .ef_hasteup,
        .ef_flasher,
        .ef_removetrap,
        .ef_blastmine,
        .ef_bottom,
        .ef_blitzbeat,
        .ef_waterball,
        .ef_waterball2,
        .ef_fireivy,
        .ef_detecting,
        .ef_cloaking,
        .ef_sonicblow,
        .ef_sonicblowhit,
        .ef_grimtooth,
        .ef_enchantpoison,
    ]

    @Test("All 78 new Batch 1 effects in 0...125 are supported, spawn cleanly, and advance 65 ticks")
    func allBatch1EffectsSpawnAndStep() {
        #expect(Self.batch1NewEffectIDs.count == 78)

        let manager = EffectManager()
        let world = RecordingWorldContext()
        let targetID: EffectTargetID = 1001
        world.targets[targetID] = EffectTargetState(
            objectID: targetID,
            worldPosition: [10, 0, 10],
            facingAngle: 45
        )

        for effectID in Self.batch1NewEffectIDs {
            #expect(manager.supports(effectID), "Expected EffectManager to support \(effectID.rawValue)")

            manager.spawn(
                EffectSpawnRequest(
                    effectID: effectID,
                    worldPosition: [10, 0, 10],
                    sourceWorldPosition: [4, 0, 6],
                    ownerObjectID: targetID,
                    targetObjectID: targetID,
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

    @Test("Spot checks primitives, audio, camera shake, modifiers, and hybrid STR definitions in 0...125")
    func spotCheckKeyBatch1Effects() {
        let manager = EffectManager()
        let world = RecordingWorldContext()
        let targetID: EffectTargetID = 77
        world.targets[targetID] = EffectTargetState(
            objectID: targetID,
            worldPosition: [5, 0, -5],
            facingAngle: 90
        )

        // EF_HIT1 (0): 1 cylinder + 2 pp_3dparticle + 2 pp_3dparticlegravity
        manager.spawn(EffectSpawnRequest(effectID: .ef_hit1, worldPosition: [0, 0, 0]))
        manager.stepOneTick(world: world)
        let hit1 = manager.activeEffects.first as? RagEffect
        #expect(hit1?.primitives.count == 5)
        manager.removeAll()

        // EF_HIT2 (1): audio + 8 radial 2D quads
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_hit2, worldPosition: [0, 0, 0]))
        manager.stepOneTick(world: world)
        let hit2 = manager.activeEffects.first as? RagEffect
        #expect(hit2?.primitives.count == 8)
        #expect(world.playedSounds.map(\.name) == ["effect\\EF_hit2.wav"])
        manager.removeAll()

        // EF_BEGINSPELL (12) & EF_BEGINSPELL2 (54)
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_beginspell, worldPosition: [0, 0, 0]))
        manager.stepOneTick(world: world)
        let begin1 = manager.activeEffects.first as? RagEffect
        #expect(begin1?.primitives.count == 2)
        #expect(begin1?.primitives.allSatisfy { $0.id == EffectPrimitiveID(rawValue: 30) } == true)
        #expect(world.playedSounds.map(\.name) == ["effect\\EF_BeginSpell.wav"])
        manager.removeAll()

        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_beginspell2, worldPosition: [0, 0, 0]))
        manager.stepOneTick(world: world)
        let begin2 = manager.activeEffects.first as? RagEffect
        #expect(begin2?.primitives.count == 1)
        #expect(begin2?.primitives.first?.id == .pp_3dcasting)
        #expect(world.playedSounds.map(\.name) == ["effect\\EF_BeginSpell.wav"])
        manager.removeAll()

        // EF_GLASSWALL (13): 4 barrier panels + audio
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_glasswall, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        let glassWall = manager.activeEffects.first as? RagEffect
        #expect(glassWall?.primitives.count == 4)
        #expect(world.playedSounds.map(\.name) == ["effect\\EF_GlassWall.wav"])
        manager.removeAll()

        // EF_FIREBALL (24): spawns projectiles at ticks 20, 24, 28, 32
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(
            effectID: .ef_fireball,
            worldPosition: [10, 0, 10],
            sourceWorldPosition: [0, 0, 0],
            duration: 2.0
        ))
        for _ in 0..<35 {
            manager.stepOneTick(world: world)
        }
        #expect(world.playedSounds.filter { $0.name == "effect\\EF_FireBall.wav" }.count == 4)
        manager.removeAll()

        // EF_EARTHSPIKE (79): camera shake + sound + 7 horns
        world.playedSounds.removeAll()
        world.shakeCount = 0
        manager.spawn(EffectSpawnRequest(effectID: .ef_earthspike, worldPosition: [0, 0, 0], duration: 5.0))
        manager.stepOneTick(world: world)
        let earthSpike = manager.activeEffects.first as? RagEffect
        #expect(world.shakeCount == 1)
        #expect(world.playedSounds.map(\.name) == ["effect\\wizard_earthspike.wav"])
        #expect(earthSpike?.primitives.count == 7)
        manager.removeAll()

        // EF_STORMGUST (89): hybrid procedural + STR (not in STRDefinition table)
        #expect(RagEffect.STRDefinition.definition(for: .ef_stormgust) == nil)
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_stormgust, worldPosition: [0, 0, 0], duration: 4.0))
        for _ in 0..<60 {
            manager.stepOneTick(world: world)
        }
        #expect(world.playedSounds.map(\.name) == ["effect\\wizard_stormgust.wav"])
        let stormGust = manager.activeEffects.first as? RagEffect
        #expect((stormGust?.primitives.count ?? 0) >= 2)
        manager.removeAll()

        // EF_SIGNUM (40): audio burst at tick 30
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_signum, worldPosition: [0, 0, 0], duration: 2.0))
        for _ in 0..<32 {
            manager.stepOneTick(world: world)
        }
        #expect(world.playedSounds.map(\.name) == ["effect\\EF_Signum.wav", "effect\\EF_Bash.wav"])
        manager.removeAll()

        // EF_ASPERSIO (86): hybrid STR + audio at tick 70
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_aspersio, worldPosition: [0, 0, 0], duration: 3.0))
        for _ in 0..<72 {
            manager.stepOneTick(world: world)
        }
        #expect(world.playedSounds.map(\.name) == ["effect\\priest_aspersio.wav"])
        manager.removeAll()

        // EF_CLOAKING (120): sound + cloaking modifier
        world.playedSounds.removeAll()
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(
            effectID: .ef_cloaking,
            worldPosition: [5, 0, -5],
            targetObjectID: targetID,
            duration: 1.0
        ))
        manager.stepOneTick(world: world)
        #expect(world.playedSounds.map(\.name) == ["effect\\assasin_cloaking.wav"])
        #expect(world.appliedModifiers.contains { $0.targetID == targetID && $0.modifier == .cloaking(alpha: 50.0 / 255.0) })
        manager.removeAll()

        // EF_RUWACH (33): body + shadow particles on tick 0
        manager.spawn(EffectSpawnRequest(effectID: .ef_ruwach, worldPosition: [0, 0, 0], duration: 1.0))
        manager.stepOneTick(world: world)
        let ruwach = manager.activeEffects.first as? RagEffect
        #expect(ruwach?.primitives.count == 2)
        manager.removeAll()

        // EF_YUFITEL (93): sound + 2 directional quads
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(
            effectID: .ef_yufitel,
            worldPosition: [10, 0, 0],
            sourceWorldPosition: [0, 0, 0],
            duration: 1.0
        ))
        manager.stepOneTick(world: world)
        let yufitel = manager.activeEffects.first as? RagEffect
        #expect(world.playedSounds.map(\.name) == ["effect\\hunter_shockwavetrap.wav"])
        #expect(yufitel?.primitives.count == 2)
        manager.removeAll()

        // EF_BLITZBEAT (115): tick 5 and tick 30 audio + dive rings after tick 35 when count > 0
        world.playedSounds.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_blitzbeat, worldPosition: [0, 0, 0], duration: 2.0))
        if let blitzBeat = manager.activeEffects.first as? RagEffect {
            blitzBeat.count = 3
        }
        for _ in 0..<45 {
            manager.stepOneTick(world: world)
        }
        #expect(world.playedSounds.map(\.name) == [
            "effect\\hunter_blitzbeat_1st.wav",
            "effect\\hunter_blitzbeat.wav",
        ])
        manager.removeAll()

        // EF_BLASTMINE (105): supported no-op
        manager.spawn(EffectSpawnRequest(effectID: .ef_blastmine, worldPosition: [0, 0, 0], duration: 0.1))
        manager.stepOneTick(world: world)
        let blastMine = manager.activeEffects.first as? RagEffect
        #expect(blastMine?.primitives.isEmpty == true)
        manager.removeAll()
    }
}
