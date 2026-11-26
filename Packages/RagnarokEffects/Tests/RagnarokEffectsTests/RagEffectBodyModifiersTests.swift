//
//  RagEffectBodyModifiersTests.swift
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
@Suite("RagEffect *BODY Target Visual Modifiers")
struct RagEffectBodyModifiersTests {
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

    private static let allBodyEffectIDs: [EffectID] = [
        .ef_steelbody,
        .ef_redbody,
        .ef_transbluebody,
        .ef_pinkbody,
        .ef_pressedbody,
        .ef_spinedbody,
        .ef_kickedbody,
        .ef_hitbody,
        .ef_reflectbody,
        .ef_babybody,
        .ef_babybody2,
        .ef_giantbody,
        .ef_giantbody2,
        .ef_asurabody,
        .ef_4waybody,
        .ef_quakebody,
        .ef_asurabody_monster,
        .ef_jumpbody,
        .ef_landbody,
        .ef_quakebody2,
        .ef_spinedbody2,
        .ef_chemicalbody,
        .ef_piercebody,
        .ef_doublecastbody,
        .ef_greenbody,
        .ef_babybody_back,
        .ef_bluebody,
        .ef_redlightbody,
        .ef_quakebody3,
        .ef_quakebody4,
        .ef_undeadbody,
        .ef_undeadbody_del,
        .ef_purplebody,
        .ef_blackbody,
        .ef_graybody,
        .ef_bluelightbody,
        .ef_yellobody,
        .ef_whitebody,
        .ef_jumpbody1,
        .ef_blink_body,
    ]

    @Test("All 40 *BODY effects are supported, spawn cleanly, and advance 65 ticks")
    func allBodyEffectsSupportedAndStep() {
        #expect(Self.allBodyEffectIDs.count == 40)

        let manager = EffectManager()
        let world = RecordingWorldContext()
        let targetID: EffectTargetID = 5001
        world.targets[targetID] = EffectTargetState(
            objectID: targetID,
            worldPosition: [4, 0, -4],
            facingAngle: 90
        )

        for effectID in Self.allBodyEffectIDs {
            #expect(manager.supports(effectID), "Expected EffectManager to support \(effectID.rawValue)")

            manager.spawn(
                EffectSpawnRequest(
                    effectID: effectID,
                    worldPosition: [4, 0, -4],
                    ownerObjectID: targetID,
                    targetObjectID: targetID,
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

    @Test("Spot checks upgraded 400...499 body modifiers (squash, kick lift, white flash, jump/land, outlines)")
    func spotCheckUpgradedBodyModifiers() {
        let manager = EffectManager()
        let world = RecordingWorldContext()
        let targetID: EffectTargetID = 6001
        world.targets[targetID] = EffectTargetState(objectID: targetID, worldPosition: [0, 0, 0])

        // EF_PRESSEDBODY (413): progressive vertical squash at tick 18 (phase 1 -> scaleY = 0.8)
        manager.spawn(EffectSpawnRequest(effectID: .ef_pressedbody, worldPosition: .zero, targetObjectID: targetID, duration: 1.0))
        for _ in 0..<19 {
            manager.stepOneTick(world: world)
        }
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .scale(SIMD3<Float>(1.0, 0.8, 1.0), durationTicks: 2)
        })
        manager.removeAll()

        // EF_KICKEDBODY (415): vertical lift offset (not roll) after tick 30
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_kickedbody, worldPosition: .zero, targetObjectID: targetID, duration: 2.0))
        for _ in 0..<40 {
            manager.stepOneTick(world: world)
        }
        #expect(world.appliedModifiers.contains {
            guard $0.targetID == targetID, case .spriteOffset(let offset, durationTicks: 2) = $0.modifier else {
                return false
            }
            return offset.x == 0 && offset.y > 0
        })
        manager.removeAll()

        // EF_HITBODY (417): white additive flash overlay (peak 1.0 at tick 6...8)
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_hitbody, worldPosition: .zero, targetObjectID: targetID, duration: 1.0))
        for _ in 0..<8 {
            manager.stepOneTick(world: world)
        }
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .flash(color: SIMD4<Float>(1, 1, 1, 1), durationTicks: 2)
        })
        manager.removeAll()

        // EF_REFLECTBODY (419) & EF_ASURABODY (424): outline aura modifiers
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_reflectbody, worldPosition: .zero, targetObjectID: targetID, duration: 1.0))
        manager.stepOneTick(world: world)
        #expect(world.appliedModifiers.contains {
            guard $0.targetID == targetID, case .outline(_, _, layers: 4, durationTicks: 2) = $0.modifier else {
                return false
            }
            return true
        })
        manager.removeAll()

        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_asurabody, worldPosition: .zero, targetObjectID: targetID, duration: 1.0))
        manager.stepOneTick(world: world)
        manager.stepOneTick(world: world)
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .outline(
                color: SIMD4<Float>(1, 1, 1, 1.0 / 255.0),
                spread: 6.0,
                layers: 2,
                durationTicks: 2
            )
        })
        manager.removeAll()

        // EF_JUMPBODY (445): upward launch offset + fading alpha after tick 35
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_jumpbody, worldPosition: .zero, targetObjectID: targetID, duration: 2.0))
        for _ in 0..<38 {
            manager.stepOneTick(world: world)
        }
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .spriteOffset(SIMD2<Float>(0, 20), durationTicks: 2)
        })
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .alpha(235.0 / 255.0, durationTicks: 2)
        })
        manager.removeAll()
    }

    @Test("Spot checks newly implemented 500...1209 body modifiers")
    func spotCheckNewBodyModifiers500To1209() {
        let manager = EffectManager()
        let world = RecordingWorldContext()
        let targetID: EffectTargetID = 6002
        world.targets[targetID] = EffectTargetState(objectID: targetID, worldPosition: [0, 0, 0])

        // EF_BABYBODY_BACK (540): reverse shrink pulse from 0.5 back to 1.0
        manager.spawn(EffectSpawnRequest(effectID: .ef_babybody_back, worldPosition: .zero, targetObjectID: targetID, duration: 1.0))
        for _ in 0..<16 {
            manager.stepOneTick(world: world)
        }
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .scale(SIMD3<Float>(0.5, 0.5, 0.5), durationTicks: 2)
        })
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .scale(SIMD3<Float>(1.0, 1.0, 1.0), durationTicks: 2)
        })
        manager.removeAll()

        // EF_QUAKEBODY4 (602): audio at tick 20 + shake + red/white tint after tick 20
        world.playedSounds.removeAll()
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_quakebody4, worldPosition: .zero, targetObjectID: targetID, duration: 1.0))
        for _ in 0..<23 {
            manager.stepOneTick(world: world)
        }
        #expect(world.playedSounds.map(\.name) == ["effect\\ef_hit6.wav"])
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .shake(amplitude: 2.0, durationTicks: 2)
        })
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .tint(
                color: SIMD4<Float>(250.0 / 255.0, 50.0 / 255.0, 50.0 / 255.0, 1.0),
                durationTicks: 2
            )
        })
        manager.removeAll()

        // EF_UNDEADBODY (655) & EF_UNDEADBODY_DEL (656): green outline
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_undeadbody, worldPosition: .zero, targetObjectID: targetID, duration: 1.0))
        manager.stepOneTick(world: world)
        manager.stepOneTick(world: world)
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .outline(
                color: SIMD4<Float>(5.0 / 255.0, 155.0 / 255.0, 5.0 / 255.0, 1.0 / 255.0),
                spread: 2.0,
                layers: 2,
                durationTicks: 2
            )
        })
        manager.removeAll()

        // EF_BLACKBODY (812): spawns PP_3DTEXTURE aura + black/white blink
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_blackbody, worldPosition: .zero, targetObjectID: targetID, duration: 2.0))
        for _ in 0..<8 {
            manager.stepOneTick(world: world)
        }
        #expect((manager.activeEffects.first as? RagEffect)?.primitives.first?.id == .pp_3dtexture)
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .tint(color: SIMD4<Float>(0, 0, 0, 1), durationTicks: 2)
        })
        manager.removeAll()

        // EF_JUMPBODY1 (1072): audio at tick 0 + upward launch offset after tick 10
        world.playedSounds.removeAll()
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_jumpbody1, worldPosition: .zero, targetObjectID: targetID, duration: 1.0))
        for _ in 0..<13 {
            manager.stepOneTick(world: world)
        }
        #expect(world.playedSounds.map(\.name) == [K2L("effect\\T_회피2.wav")])
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .spriteOffset(SIMD2<Float>(0, 20), durationTicks: 2)
        })
        manager.removeAll()

        // EF_BLINK_BODY (1209): alternating periwinkle / dark gray tint
        world.appliedModifiers.removeAll()
        manager.spawn(EffectSpawnRequest(effectID: .ef_blink_body, worldPosition: .zero, targetObjectID: targetID, duration: 1.0))
        manager.stepOneTick(world: world)
        manager.stepOneTick(world: world)
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .tint(
                color: SIMD4<Float>(155.0 / 255.0, 155.0 / 255.0, 1.0, 1.0),
                durationTicks: 2
            )
        })
        #expect(world.appliedModifiers.contains {
            $0.targetID == targetID && $0.modifier == .tint(
                color: SIMD4<Float>(50.0 / 255.0, 50.0 / 255.0, 50.0 / 255.0, 1.0),
                durationTicks: 2
            )
        })
        manager.removeAll()
    }
}
