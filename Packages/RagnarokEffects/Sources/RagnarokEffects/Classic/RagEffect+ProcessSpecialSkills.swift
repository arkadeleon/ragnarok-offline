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

    /// Spawns expanding enhance ground ring (`PP_3DCIRCLE` (12)), aura cylinder (`PP_3DCYLINDER` (13)), and cross sparkles (`PP_3DCROSSTEXTURE` (16)) for `EF_ENHANCE` (9).
    func enhance(context: EffectTickContext) {
        let ringTex = "effect\\ring_yellow.tga"
        let auraTex = "effect\\alpha_down.tga"

        if stateCnt == 0 {
            _ = context.assets?.texture(atPath: ringTex)
            _ = context.assets?.texture(atPath: auraTex)

            let ring = launchPrimitive(.pp_3dcircle)
            ring.state.duration = duration
            ring.state.arcAngle = 22.5
            ring.state.size = 7.0
            ring.state.latitude = 90.0
            ring.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(ring.state.latitude)))
            ring.state.alpha = 128.0
            ring.state.fadeOutCnt = ring.state.duration - ring.state.duration / 3
            ring.initSegment()
            ring.state.texturePaths = [ringTex]

            let cylinder = launchPrimitive(.pp_3dcylinder)
            cylinder.state.duration = duration
            cylinder.state.outerSize = 6.0
            cylinder.state.innerSize = 6.0
            cylinder.state.heightSpeed = 2.0
            cylinder.state.heightAccel = -(cylinder.state.heightSpeed / Float(cylinder.state.duration)) / 1.5
            cylinder.state.maxHeightSize = 50.0
            cylinder.state.alpha = 128.0
            cylinder.state.fadeOutCnt = cylinder.state.duration - cylinder.state.duration / 3
            cylinder.state.texturePaths = [auraTex]
        }

        let interval = context.usesMinimalEffects ? 15 : 5
        guard stateCnt % interval == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: auraTex)
        let streak = launchPrimitive(.pp_3dcrosstexture)
        streak.state.duration = 50
        let yaw = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
        streak.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<5) + 2)), by: yaw)
        streak.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: 90))
        streak.state.speed = 2.0
        streak.state.widthSize = 7.0
        streak.state.heightSize = 0.25
        streak.state.texturePaths = [auraTex]
        streak.state.slots[0].life = 0
    }

    // MARK: - EF_GLASSWALL (13)

    /// Spawns four vertical barrier walls (`PP_3DTEXTURE` (15)) and advances `SafetyWall.str` for `EF_GLASSWALL` (13).
    func glassWall(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: "SafetyWall.str")
            context.world.playSound(
                named: "effect\\EF_GlassWall.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )

            var angle = Int(180.0 - longitude)
            if angle < 0 {
                angle += 360
            }
            let rotation = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: angle))

            let texturePath = "effect\\ring_blue.tga"
            _ = context.assets?.texture(atPath: texturePath)

            for side in stride(from: 1, through: -1, by: -2) {
                let sideZ = launchPrimitive(.pp_3dtexture)
                sideZ.state.duration = duration
                sideZ.state.pattern = 40
                sideZ.state.type = 50
                sideZ.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, 2.6 * Float(side)), by: rotation)
                sideZ.state.longitude = Float(angle + 90)
                sideZ.state.widthSize = 3.0
                sideZ.state.heightSize = 40.0
                sideZ.state.heightSpeed = 0.25
                sideZ.state.alpha = 0
                sideZ.state.maxAlpha = 180.0
                sideZ.state.alphaSpeed = sideZ.state.maxAlpha / 6.0
                sideZ.state.fadeOutCnt = sideZ.state.duration - 6
                sideZ.state.texturePaths = [texturePath]

                let sideX = launchPrimitive(.pp_3dtexture)
                sideX.state.duration = duration
                sideX.state.pattern = 40
                sideX.state.type = 50
                sideX.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(3.0 * Float(side), 0, 0), by: rotation)
                sideX.state.longitude = Float(angle)
                sideX.state.widthSize = 2.6
                sideX.state.heightSize = 40.0
                sideX.state.heightSpeed = 0.25
                sideX.state.alpha = 0
                sideX.state.maxAlpha = 180.0
                sideX.state.alphaSpeed = sideX.state.maxAlpha / 6.0
                sideX.state.fadeOutCnt = sideX.state.duration - 6
                sideX.state.texturePaths = [texturePath]
            }
        }

        _ = processEZ2STRRaised(context: context)
        return stateCnt != duration
    }

    // MARK: - EF_NAPALMBEAT (32)

    /// Spawns 2D animated explosion fragments (`PP_2DTEXTURE` (0)) for `EF_NAPALMBEAT` (32).
    func napalmFragments(context: EffectTickContext) {
        guard stateCnt < 15, stateCnt >= stateCnt % 5 else {
            return
        }

        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\EF_NapalmBeat.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        let texturePaths = (1...8).map { K2L("effect\\폭발\($0).TGA") }
        for path in texturePaths {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(.pp_2dtexture)
        primitive.state.duration = 30
        let distance = Int.random(in: 0..<50) + 10
        let radius = Float(distance)
        let angle = Int.random(in: 0..<360)
        primitive.state.deltaPos2.x = EffectSpace.sine(degrees: angle) * radius
        primitive.state.deltaPos2.y = EffectSpace.cosine(degrees: angle) * -Float(distance) - 20.0
        let size = Float(Int.random(in: 0..<40) + 20)
        primitive.state.heightSize = size
        primitive.state.widthSize = size
        primitive.state.alpha = 0
        primitive.state.alphaSpeed = primitive.state.maxAlpha / 10.0
        primitive.state.fadeOutCnt = primitive.state.duration - primitive.state.duration / 3
        primitive.state.repeatAnim = false
        primitive.state.animSpeed = 2
        primitive.state.totalTexture = 8
        primitive.state.texturePaths = texturePaths
        primitive.state.slots[0].life = 0
    }

    // MARK: - EF_LOCKON (60)

    /// Spawns dual counter-rotating ground lock-on reticles (`PP_3DTEXTURE` (15)) for `EF_LOCKON` (60).
    func lockOnMarker(context: EffectTickContext) {
        if stateCnt == 0 {
            let texturePath = "effect\\LockOn128.tga"
            _ = context.assets?.texture(atPath: texturePath)

            for initialLongitude: Float in [0.0, 45.0] {
                let reticle = launchPrimitive(.pp_3dtexture)
                reticle.state.duration = duration
                reticle.state.pattern |= 0x800
                reticle.state.longitude = initialLongitude
                reticle.state.longSpeed = 4.5
                reticle.state.roll = 90.0
                reticle.state.changeWidthAccel = 0
                reticle.state.changeHeightAccel = 0
                reticle.state.widthSize = 30.0
                reticle.state.heightSize = 30.0
                reticle.state.widthSpeed = -1.0
                reticle.state.heightSpeed = -1.0
                reticle.state.changePoint = 20
                reticle.state.changeWidthSpeed = 0
                reticle.state.changeHeightSpeed = 0
                reticle.state.rgbCycleDelay = 20
                reticle.state.red = 250
                reticle.state.blue = 150
                reticle.state.blueSpeed = -15
                reticle.state.green = 150
                reticle.state.greenSpeed = -15
                reticle.state.texturePaths = [texturePath]
            }
        }

        position.y = context.world.terrainHeight(atEffectX: position.x, effectZ: position.z) - 2.0
    }

    // MARK: - EF_STATUS_STATE (164)

    /// Manages reset semantics for HUD status icon column (`EF_STATUS_STATE` (164)).
    func statusIconColumn(context: EffectTickContext) {
        if stateCnt == 99_999_998 {
            stateCnt = 0
        }

        if count != 0 {
            count = 0
            stateCnt = 0
            for primitive in primitives {
                primitive.stop()
            }
        }
    }

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
