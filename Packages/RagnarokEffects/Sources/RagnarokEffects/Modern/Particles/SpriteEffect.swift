//
//  SpriteEffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation
import RagnarokCore
import RagnarokRendering
import simd

/// Modern ACT/SPR-based particle effect supporting aura, immune property, costume, and burst sprite effects.
@MainActor
public final class SpriteEffect: ParticleEffect {
    public private(set) var particles: [SpriteParticle] = []

    /// Render flags matching `RSF_*` bitmasks used by `SpriteParticle`.
    private enum RenderFlag {
        static let alpha: UInt32 = 0x1
        static let depthSorted: UInt32 = 0x4
        static let customBlend: UInt32 = 0x20
        static let topmost: UInt32 = 0x40
    }

    public nonisolated static let supportedEffectIDs: [EffectID] = [
        .ef_ground_explosion,
        .ef_bakuretsu_hadou,
        .ef_popcorn,
        .ef_immune_property_nothing,
        .ef_immune_property_water,
        .ef_immune_property_ground,
        .ef_immune_property_fire,
        .ef_immune_property_wind,
        .ef_immune_property_poison,
        .ef_immune_property_saint,
        .ef_immune_property_darkness,
        .ef_immune_property_telekinesis,
        .ef_immune_property_undead,
        .ef_random_opt_yellow,
        .ef_subject_aura_1211,
        .ef_subject_aura_1212,
        .ef_subject_aura_1213,
        .ef_book_of_dimension,
        .ef_book_of_creatingstar,
        .ef_curse_explosion,
        .ef_soul_reaper,
        .ef_soul_shadow,
        .ef_soul_fairy,
        .ef_soul_falcon,
        .ef_soul_explosion,
        .ef_valkyrie_wing,
        .ef_c_amdarais_effect,
        .ef_blackbubble_small,
        .ef_blackbubble_midium,
        .ef_blackbubble_large,
        .ef_serpent_shadow,
        .ef_violen_hit,
        .ef_c_aura_of_ghost_s,
        .ef_atque_poenitentia,
        .ef_perm_frost_oblivion,
        .ef_c_guide_of_dead_text,
        .ef_c_medjed_text,
        .ef_s_beelzebub_wing,
        .ef_c_2025rosfesta,
    ]

    public override func open(context: EffectTickContext) {
        let particle = SpriteParticle(position: position, renderOptions: 0x200)
        particle.effectID = effectID
        particle.groupIndex = 1
        particle.columnIndex = 1
        particle.rowIndex = 0
        setupParticle(particle)
        particle.actorID = ownerObjectID
        particles.append(particle)
    }

    public override func close() {
        particles.removeAll()
    }

    public override func evaluateIsAlive() -> Bool {
        switch effectID {
        case .ef_ground_explosion:
            return !isFinished
        case .ef_random_opt_yellow:
            return ownerObjectID != nil && actorExists
        case .ef_bakuretsu_hadou,
             .ef_immune_property_nothing,
             .ef_immune_property_water,
             .ef_immune_property_ground,
             .ef_immune_property_fire,
             .ef_immune_property_wind,
             .ef_immune_property_poison,
             .ef_immune_property_saint,
             .ef_immune_property_darkness,
             .ef_immune_property_telekinesis,
             .ef_immune_property_undead,
             .ef_subject_aura_1211,
             .ef_subject_aura_1212,
             .ef_subject_aura_1213,
             .ef_valkyrie_wing,
             .ef_c_amdarais_effect,
             .ef_blackbubble_small,
             .ef_blackbubble_midium,
             .ef_blackbubble_large,
             .ef_serpent_shadow,
             .ef_c_aura_of_ghost_s,
             .ef_atque_poenitentia,
             .ef_perm_frost_oblivion,
             .ef_c_guide_of_dead_text,
             .ef_c_medjed_text,
             .ef_c_2025rosfesta,
             .ef_s_beelzebub_wing:
            return actorExists
        default:
            return particles.contains(where: \.isActive)
        }
    }

    public override func onProcess(context: EffectTickContext) {
        let ownerState = ownerObjectID.flatMap { context.world.targetState(for: $0) }
        let nameOffset = ownerState.map { $0.headHeight * EffectSpace.worldToEffectScale }

        for particle in particles {
            particle.elapsedFrames += 1
            particle.advanceFrame(assets: context.assets)

            switch effectID {
            case .ef_bakuretsu_hadou:
                let height = Float(Int((nameOffset ?? 0) + 8.0))
                particle.position = SIMD3<Float>(position.x, position.y - height, position.z)
            case .ef_popcorn, .ef_random_opt_yellow:
                particle.position = SIMD3<Float>(position.x, position.y - 3.0, position.z)
            case .ef_immune_property_nothing,
                 .ef_immune_property_water,
                 .ef_immune_property_ground,
                 .ef_immune_property_fire,
                 .ef_immune_property_wind,
                 .ef_immune_property_poison,
                 .ef_immune_property_saint,
                 .ef_immune_property_darkness,
                 .ef_immune_property_telekinesis,
                 .ef_immune_property_undead:
                let height = Float(Int((nameOffset ?? 0) + 25.0))
                particle.position = SIMD3<Float>(position.x, position.y - height, position.z)
            case .ef_subject_aura_1211,
                 .ef_subject_aura_1212,
                 .ef_subject_aura_1213:
                if let nameOffset {
                    let height = Float(Int(nameOffset + 8.0))
                    particle.position = SIMD3<Float>(position.x, position.y - height, position.z)
                }
            case .ef_valkyrie_wing:
                if let nameOffset {
                    let height = Float(Int(nameOffset + 3.0))
                    particle.position = SIMD3<Float>(position.x, position.y - height, position.z)
                }
            case .ef_serpent_shadow,
                 .ef_c_aura_of_ghost_s:
                if let nameOffset {
                    let height = Float(Int(nameOffset))
                    particle.position = SIMD3<Float>(position.x, position.y - height, position.z)
                }
            case .ef_c_guide_of_dead_text,
                 .ef_c_medjed_text:
                if let nameOffset {
                    particle.position = SIMD3<Float>(position.x, position.y - nameOffset, position.z)
                }
            case .ef_atque_poenitentia:
                if let nameOffset {
                    let lift = nameOffset + 17.0
                    particle.position = SIMD3<Float>(position.x, position.y - lift, position.z)
                }
            case .ef_perm_frost_oblivion:
                if ownerState != nil {
                    particle.position = SIMD3<Float>(position.x, position.y - 0.4, position.z)
                }
            case .ef_s_beelzebub_wing:
                particle.applyActorExtent = true
                particle.applyActorLift = true
                particle.screenOffsetY = -105.0
                particle.screenOffsetX = 0.0
                particle.position = position
            case .ef_c_2025rosfesta:
                particle.applyActorExtent = true
                particle.applyActorLift = true
                particle.screenOffsetY = 0.0
                particle.screenOffsetX = 0.0
                particle.position = position
            default:
                particle.position = position
            }
        }
    }

    public override func collectParticles(
        into collector: inout EffectPrimitiveBatchCollector,
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext,
        assets: EffectAssetStore?
    ) {
        for particle in particles where particle.elapsedFrames > 0 {
            particle.render(into: &collector, assets: assets)
        }
    }

    private func setupParticle(_ particle: SpriteParticle) {
        particle.renderOptions |= 0x200
        particle.frameDelay = 2.0
        particle.alpha = 255
        effectLifetime = 100

        switch effectID {
        case .ef_ground_explosion:
            particle.setSprite(K2L("이팩트\\m_ef03.spr"))
            particle.setAction(K2L("이팩트\\m_ef03.act"))
            particle.frameDelay = 4.0
            particle.scale = 1.5
        case .ef_bakuretsu_hadou:
            particle.setSprite(K2L("이팩트\\bakuretsu_hadou\\bakuretsu_hadou.spr"))
            particle.setAction(K2L("이팩트\\bakuretsu_hadou\\bakuretsu_hadou.act"))
            particle.renderOptions |= 0x200
            particle.depthOffset = 0.0003
            particle.flags = RenderFlag.alpha | RenderFlag.depthSorted
            particle.loopMode = .loop
            particle.frameDelay = 8.0
        case .ef_popcorn:
            particle.setSprite(K2L("이팩트\\EF_POPCORN\\EF_POPCORN.spr"))
            particle.setAction(K2L("이팩트\\EF_POPCORN\\EF_POPCORN.act"))
            particle.loopMode = .oneTime
            particle.depthOffset = 0.0003
            particle.frameDelay = 8.0
        case .ef_immune_property_nothing:
            configureImmuneProperty(particle, suffix: "NOTHING")
        case .ef_immune_property_water:
            configureImmuneProperty(particle, suffix: "WATER")
        case .ef_immune_property_ground:
            configureImmuneProperty(particle, suffix: "GROUND")
        case .ef_immune_property_fire:
            configureImmuneProperty(particle, suffix: "FIRE")
        case .ef_immune_property_wind:
            configureImmuneProperty(particle, suffix: "WIND")
        case .ef_immune_property_poison:
            configureImmuneProperty(particle, suffix: "POISON")
        case .ef_immune_property_saint:
            configureImmuneProperty(particle, suffix: "SAINT")
        case .ef_immune_property_darkness:
            configureImmuneProperty(particle, suffix: "DARKNESS")
        case .ef_immune_property_telekinesis:
            configureImmuneProperty(particle, suffix: "TELEKINESIS")
        case .ef_immune_property_undead:
            configureImmuneProperty(particle, suffix: "UNDEAD")
        case .ef_random_opt_yellow:
            particle.setSprite(K2L("이팩트\\random_opt_spr\\yellow.spr"))
            particle.setAction(K2L("이팩트\\random_opt_spr\\yellow.act"))
            particle.loopMode = .loop
            particle.frameDelay = 4.0
        case .ef_subject_aura_1211,
             .ef_subject_aura_1212,
             .ef_subject_aura_1213:
            particle.setSprite(K2L("이팩트\\subject_aura\\subject_aura.spr"))
            particle.setAction(K2L("이팩트\\subject_aura\\subject_aura.act"))
            particle.frameDelay = 8.0
            particle.loopMode = .loop
            particle.depthOffset = 0.0003
            particle.flags = RenderFlag.alpha | RenderFlag.depthSorted
            if effectID == .ef_subject_aura_1212 {
                particle.animation = 0
            } else if effectID == .ef_subject_aura_1213 {
                particle.animation = 1
            } else {
                particle.animation = 2
            }
        case .ef_book_of_dimension:
            configureOneTimeAlphaSprite(particle, folder: "book_of_dimension", depthOffset: 0)
        case .ef_book_of_creatingstar:
            configureOneTimeAlphaSprite(particle, folder: "book_of_creatingstar", depthOffset: 0)
        case .ef_curse_explosion:
            configureOneTimeAlphaSprite(particle, folder: "curse_explosion", depthOffset: 0)
        case .ef_soul_reaper:
            configureOneTimeAlphaSprite(particle, folder: "soul_reaper", depthOffset: 0)
        case .ef_soul_shadow:
            configureOneTimeAlphaSprite(particle, folder: "soul_shadow", depthOffset: 0.0003)
        case .ef_soul_fairy:
            configureOneTimeAlphaSprite(particle, folder: "soul_fairy", depthOffset: 0.0003)
        case .ef_soul_falcon:
            configureOneTimeAlphaSprite(particle, folder: "soul_falcon", depthOffset: 0.0003)
        case .ef_soul_explosion:
            configureOneTimeAlphaSprite(particle, folder: "soul_explosion", depthOffset: 0.0003)
        case .ef_valkyrie_wing:
            particle.setSprite(K2L("이팩트\\valkyrie_wing\\valkyrie_wing.spr"))
            particle.setAction(K2L("이팩트\\valkyrie_wing\\valkyrie_wing.act"))
            particle.loopMode = .loop
            particle.depthOffset = 0.001
            particle.frameDelay = 6.0
            particle.flags = RenderFlag.alpha | RenderFlag.depthSorted
        case .ef_c_amdarais_effect:
            particle.setSprite(K2L("이팩트\\c_amdarais_effect.spr"))
            particle.setAction(K2L("이팩트\\c_amdarais_effect.act"))
            particle.depthOffset = 0.0001
            particle.frameDelay = 6.0
            particle.loopMode = .loop
            particle.flags = RenderFlag.alpha
        case .ef_blackbubble_small:
            particle.setSprite(K2L("이팩트\\black_bubble\\small\\blackbubble_small.spr"))
            particle.setAction(K2L("이팩트\\black_bubble\\small\\blackbubble_small.act"))
            particle.depthOffset = 0.0001
            particle.frameDelay = 6.0
            particle.loopMode = .loop
            particle.flags = RenderFlag.alpha
        case .ef_blackbubble_midium:
            particle.setSprite(K2L("이팩트\\black_bubble\\midium\\blackbubble_midium.spr"))
            particle.setAction(K2L("이팩트\\black_bubble\\midium\\blackbubble_midium.act"))
            particle.depthOffset = 0.0001
            particle.frameDelay = 6.0
            particle.loopMode = .loop
            particle.flags = RenderFlag.alpha
        case .ef_blackbubble_large:
            particle.setSprite(K2L("이팩트\\black_bubble\\large\\blackbubble_large.spr"))
            particle.setAction(K2L("이팩트\\black_bubble\\large\\blackbubble_large.act"))
            particle.depthOffset = 0.0001
            particle.frameDelay = 6.0
            particle.loopMode = .loop
            particle.flags = RenderFlag.alpha
        case .ef_serpent_shadow:
            particle.setSprite(K2L("이팩트\\Serpent_Shadow\\Serpent_Shadow.spr"))
            particle.setAction(K2L("이팩트\\Serpent_Shadow\\Serpent_Shadow.act"))
            particle.loopMode = .loop
            particle.depthOffset = 0.001
            particle.frameDelay = 4.0
            particle.flags = RenderFlag.alpha | RenderFlag.customBlend | RenderFlag.topmost
        case .ef_violen_hit:
            particle.setSprite(K2L("몬스터\\violen_hit.spr"))
            particle.setAction(K2L("몬스터\\violen_hit.act"))
            particle.loopMode = .oneTime
            particle.depthOffset = 0.001
            particle.frameDelay = 4.0
        case .ef_c_aura_of_ghost_s:
            particle.setSprite(K2L("이팩트\\C_Aura_Of_Ghost_S\\C_Aura_Of_Ghost_S.spr"))
            particle.setAction(K2L("이팩트\\C_Aura_Of_Ghost_S\\C_Aura_Of_Ghost_S.act"))
            particle.loopMode = .loop
            particle.depthOffset = 0.001
            particle.frameDelay = 4.0
        case .ef_c_guide_of_dead_text:
            particle.setSprite(K2L("이팩트\\C_Guide_Of_Dead_Text\\C_Guide_Of_Dead_Text.spr"))
            particle.setAction(K2L("이팩트\\C_Guide_Of_Dead_Text\\C_Guide_Of_Dead_Text.act"))
            particle.loopMode = .loop
            particle.depthOffset = 0.001
            particle.frameDelay = 12.0
        case .ef_c_medjed_text:
            particle.setSprite(K2L("이팩트\\C_Medjed_Text\\C_Medjed_Text.spr"))
            particle.setAction(K2L("이팩트\\C_Medjed_Text\\C_Medjed_Text.act"))
            particle.loopMode = .loop
            particle.depthOffset = 0.001
            particle.frameDelay = 12.0
        case .ef_atque_poenitentia:
            particle.setSprite(K2L("이팩트\\Atque_Poenitentia\\Atque_Poenitentia.spr"))
            particle.setAction(K2L("이팩트\\Atque_Poenitentia\\Atque_Poenitentia.act"))
            particle.loopMode = .loop
            particle.depthOffset = 0.001
            particle.frameDelay = 4.0
            particle.flags = RenderFlag.alpha | RenderFlag.customBlend | RenderFlag.topmost
        case .ef_perm_frost_oblivion:
            particle.setSprite(K2L("이팩트\\Perm_Frost_Oblivion\\Perm_Frost_Oblivion.spr"))
            particle.setAction(K2L("이팩트\\Perm_Frost_Oblivion\\Perm_Frost_Oblivion.act"))
            particle.depthOffset = 0.001
            particle.frameDelay = 4.0
            particle.loopMode = .loop
            particle.flags = RenderFlag.alpha
        case .ef_s_beelzebub_wing:
            particle.setSprite(K2L("이팩트\\S_Beelzebub_Wing\\S_Beelzebub_Wing.spr"))
            particle.setAction(K2L("이팩트\\S_Beelzebub_Wing\\S_Beelzebub_Wing.act"))
            particle.flags = RenderFlag.alpha
            particle.depthOffset = 0.0015
            particle.loopMode = .loop
            particle.frameDelay = 8.0
        case .ef_c_2025rosfesta:
            particle.setSprite(K2L("이팩트\\C_2025RosFesta.spr"))
            particle.setAction(K2L("이팩트\\C_2025RosFesta.act"))
            particle.depthOffset = 0.0015
            particle.flags = RenderFlag.alpha
            particle.loopMode = .loop
            particle.frameDelay = 8.0
        default:
            break
        }
    }

    private func configureImmuneProperty(_ particle: SpriteParticle, suffix: String) {
        particle.setSprite(K2L("이팩트\\EF_IMMUNE_PROPERTY\\EF_IMMUNE_PROPERTY_\(suffix).spr"))
        particle.setAction(K2L("이팩트\\EF_IMMUNE_PROPERTY\\EF_IMMUNE_PROPERTY_\(suffix).act"))
        particle.loopMode = .loop
        particle.depthOffset = 0.0003
    }

    private func configureOneTimeAlphaSprite(
        _ particle: SpriteParticle,
        folder: String,
        depthOffset: Float
    ) {
        particle.setSprite(K2L("이팩트\\\(folder)\\\(folder).spr"))
        particle.setAction(K2L("이팩트\\\(folder)\\\(folder).act"))
        particle.frameDelay = 4.0
        particle.loopMode = .oneTime
        particle.depthOffset = depthOffset
        particle.flags = RenderFlag.alpha | RenderFlag.depthSorted
    }
}
