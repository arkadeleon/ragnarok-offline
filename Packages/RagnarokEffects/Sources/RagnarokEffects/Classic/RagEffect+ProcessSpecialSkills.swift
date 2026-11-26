//
//  RagEffect+ProcessSpecialSkills.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {

    // MARK: - EF_ENHANCE (9)
    // CRagEffect::Enhance()

    // MARK: - EF_GLASSWALL (13)
    // CRagEffect::GlassWall()

    // MARK: - EF_NAPALMBEAT (32)
    // CRagEffect::NapalmFragments()

    // MARK: - EF_LOCKON (60)
    // CRagEffect::LockOnMarker()

    // MARK: - EF_STATUS_STATE (164)
    // CRagEffect::StatusIconColumn()

    // MARK: - EF_TANJI (265)
    // CRagEffect::TANJI()

    // MARK: - EF_CHIMTO (267)
    // CRagEffect::CHIMTO(char flag)

    // MARK: - EF_POKJUK (297)
    // CRagEffect::PokBurst()

    // MARK: - EF_THROWITEM (298)
    // CRagEffect::ThrowItem(const char* name, char kind)

    // MARK: - EF_GLASSWALL2 (315)
    // CRagEffect::GlassWallRising(const char* name)

    // MARK: - EF_WARPZONE2 (321)
    // CRagEffect::AlphaDownRipples(const char* name, char kind)

    // MARK: - EF_BLIND (334)
    // CRagEffect::BLIND(char flag)

    // MARK: - EF_JOBLVUP50 (337)

    /// Spawns `PP_SLASH1` (75) four-way fan quads for `EF_KAIZEL` (590).
    func jobLvUp50Pair(angle: Int16, context: EffectTickContext) {
        let texturePath = "effect\\magic_blue.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_slash1)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0

        for i in 0..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].maxHeight = 1.5
            primitive.state.slots[i].rotStart = Int16(i * 90) + angle
            primitive.state.slots[i].alphaB = 0
            primitive.state.slots[i].distance = 2.0
            primitive.state.slots[i].height[0] = 1.0
            primitive.state.slots[i].flag1[0] = 0
        }
    }

    // MARK: - EF_ANGEL2 (338)
    // CRagEffect::SuperAngel(char type, int dummy)

    // MARK: - EF_COLORPAPER (347)
    // CRagEffect::WeddingBurst(const char* name, char silent)

    // MARK: - EF_GHOST (358)
    // CRagEffect::Ghost(char type)

    // MARK: - EF_VALLENTINE (363)
    // CRagEffect::Vallentine(char kind)

    // MARK: - EF_LINELINK2 (384)

    /// Spawns a `PP_LINELINK` (38) target-tracking link for `EF_LINELINK2` (384).
    func trackTarget(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\alpha_center.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_linelink)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].distance = 0
        primitive.state.slots[0].maxHeight = 0.2
        primitive.state.slots[0].height[4] = 2.0
        primitive.state.slots[0].vecTNow = position

        let resolvedTargetObjectID: EffectTargetID? = if sourceObjectID != nil || sourcePosition != nil {
            sourceObjectID
        } else {
            targetObjectID
        }
        primitive.state.slots[0].targetObjectID = resolvedTargetObjectID

        let targetWorldPos = resolvedTargetObjectID.flatMap {
            context.world.targetState(for: $0)?.effectPosition
        } ?? sourcePosition
        if let targetWorldPos {
            primitive.state.slots[0].vecTPre = targetWorldPos
        } else {
            primitive.state.slots[0].life = 0
        }

        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
    }

    // MARK: - EF_LINELINK3 (395)
    // CRagEffect::TrackTargetWide()

    // MARK: - EF_PEONG (411)
    // CRagEffect::WhiteLightTrail(const char* name, char kind)

    // MARK: - EF_TANJI2 (412)
    // CRagEffect::TANJI2()

    // MARK: - EF_AIRTEXTURE (416)
    // CRagEffect::AirTexture(const char* name)

    // MARK: - EF_HITLINE4 (429)
    // CRagEffect::White02Burst(char kind)

    // MARK: - EF_ATTACKENERGY2 (438)
    // CRagEffect::AttackEnergy2(const char* name)

    // MARK: - EF_STOPEFFECT (444)
    // CRagEffect::RunStop(short angle)

    // MARK: - EF_NPC_STOP (453)
    // CRagEffect::NpcStop(char type)

    // MARK: - EF_SOULLINK (503)
    // CRagEffect::SoulLink(int)

    // MARK: - EF_GRAVITATION (522)
    // CRagEffect::Gravitation()

    // MARK: - EF_HATED (543)
    // CRagEffect::ParticleTime(const char* name, char kind)

    // MARK: - EF_SMA (551)
    // CRagEffect::SMA(char flag)

    // MARK: - EF_TWILIGHT1 (573)
    // CRagEffect::ScatterItemIcons(char kind)

    // MARK: - EF_KAIZEL (590)
    // CRagEffect::JobLvUp50_2(short angle)

    // MARK: - EF_MAP_MAGICZONE (650)
    // CRagEffect::Map_Pika(const char* name)

    // MARK: - EF_FROSTMYSTY (726)

    /// Spawns `PP_SAINTWING` (76) paired flapping angel wings for `EF_SAINTWING` (362).
    func saintWing(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_saintwing)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0
        for i in 0..<2 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].maxHeight = 10.0
            primitive.state.slots[i].distance = 2.0
            primitive.state.slots[i].height[0] = -8.0
            primitive.state.slots[i].rotStart = 0
            primitive.state.slots[i].fullDisplayAngle = 0
            primitive.state.slots[i].alphaB = 200
            primitive.state.slots[i].riseAngle = 0
        }
    }

    // MARK: - EF_TETRA (804)
    // CRagEffect::TetraVortexPillar(char kind)

    // MARK: - EF_FIREBALL3 (806)
    // CRagEffect::RocketPunch()

    // MARK: - EF_SPR_PARTICLE (851)
    // CRagEffect::Mavka(char flag)

    // MARK: - EF_SPR_PLANT (853)
    // CRagEffect::MonsterSpriteBurst(char kind)

    // MARK: - EF_FIREBALL6 (935)
    // CRagEffect::GreenRocketPunch()

    // MARK: - EF_ALL_FULL_THROTTLE (1042)
    // CRagEffect::FullThrottle()

    // MARK: - EF_SR_FLASHCOMBO (1043)
    // CRagEffect::FlashCombo()

    // MARK: - EF_RK_LUXANIMA (1044)
    // CRagEffect::LuxAnima()

    // MARK: - EF_SO_ELEMENTAL_SHIELD (1046)
    // CRagEffect::ElementalShield()

    // MARK: - EF_AB_OFFERTORIUM (1047)
    // CRagEffect::Offertorium()

    // MARK: - EF_GN_ILLUSIONDOPING (1049)
    // CRagEffect::IllusionDoping()

    // MARK: - EF_SOUL_REAPER_COLLECT (1240)
    // CRagEffect::DigitalSpace(int effectId)
}
