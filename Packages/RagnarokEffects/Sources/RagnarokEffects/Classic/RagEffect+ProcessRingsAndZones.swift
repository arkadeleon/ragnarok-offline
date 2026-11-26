//
//  RagEffect+ProcessRingsAndZones.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {

    // MARK: - EF_WARP (8)
    // CRagEffect::Warp()

    // MARK: - EF_PORTAL (36)
    // CRagEffect::Portal()

    // MARK: - EF_BEGINSPELL2 (54)
    // CRagEffect::QuadRingStackSized(const char* name, char kind)

    // MARK: - EF_WARPZONE (61)
    // CRagEffect::WarpZone()

    // MARK: - EF_PIERCE (81)
    // CRagEffect::RingBurstSparks()

    // MARK: - EF_BOTTOM (114)
    // CRagEffect::Bottom()

    // MARK: - EF_OVERTHRUST (128)
    // CRagEffect::StoneCurseRing()

    // MARK: - EF_BOTTOM2 (137)
    // CRagEffect::Bottom2()

    // MARK: - EF_FIREPILLARON (138)
    // CRagEffect::RingStack(char white)

    // MARK: - EF_LEVEL99 (200)
    // CRagEffect::TripleRingStack(const char* name, char large)

    // MARK: - EF_LEVEL99_3 (202)
    // CRagEffect::FreezingCircle(char kind)

    // MARK: - EF_DEFENDER (222)
    // CRagEffect::QuadRingStack(const char* name)

    // MARK: - EF_WIND (224)

    /// Spawns 4 orbiting cloud wind ribbons (`PP_WIND` (62)) for `EF_WIND` (224).
    func healCloudRings(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\cloud11.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_wind)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0

        let configs: [(arc: Int16, rotStart: Int16, distance: Float, height: Float)] = [
            (90, 0, 3.0, 3.0),
            (70, 10, 3.2, 2.5),
            (50, 20, 3.4, 2.0),
            (30, 30, 3.6, 1.5),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = config.arc
            primitive.state.slots[index].maxHeight = 8.0
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = config.distance
            primitive.state.slots[index].riseAngle = 90
            primitive.state.slots[index].alphaT = 0
            for j in 0..<21 {
                primitive.state.slots[index].height[j] = config.height
                primitive.state.slots[index].flag1[j] = 0
            }
        }

        context.world.playSound(
            named: "_heal_effect.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
    }

    // MARK: - EF_GRANDCROSS (226)

    /// Spawns corner casting rings (`PP_GI_3` (34)) for `EF_GRANDCROSS2` (450).
    func grandCrossRings(angle: Int16, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\cru_grand cross.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = kind == 0 ? "effect\\ring_white.tga" : "effect\\ring_black.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_gi_3)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = kind == 0 ? 1.0 : 12.0

        let configs: [(rotStart: Int16, offsetX: Int8, offsetZ: Int8)] = [
            (180, 23, 23),
            (90, 23, -23),
            (0, -23, -23),
            (270, -23, 23),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 90
            primitive.state.slots[index].maxHeight = 120.0
            primitive.state.slots[index].alphaB = angle
            primitive.state.slots[index].distance = 19.9
            primitive.state.slots[index].riseAngle = 90
            primitive.state.slots[index].flag1[4] = kind
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].flag1[0] = config.offsetX
            primitive.state.slots[index].flag1[1] = config.offsetZ
        }
    }

    // MARK: - EF_CHOOKGI (228)
    // CRagEffect::ElementalOrbit(char kind)

    // MARK: - EF_MAGICROD (244)
    // CRagEffect::SageMagicRod()

    // MARK: - EF_ABSORBSPIRITS (253)
    // CRagEffect::HealRingSparkle(const char* name, char type)

    // MARK: - EF_BOTTOM_LULLABY (278)

    /// Spawns `PP_BOTTOM` (47) ground particles for `EF_BOTTOM_WHISTLE` (286).
    func bottomMusic(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_bottom)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }

        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = switch kind {
        case 1: 5.0
        case 4: 15.0
        case 6: 8.0
        case 9: 1.5
        default: 3.0
        }
        primitive.state.slots[0].height[8] = 0
        primitive.state.slots[0].alphaB = 200
        primitive.state.slots[0].vecBNow.x = position.x
        primitive.state.slots[0].vecBNow.z = position.z
        primitive.state.slots[0].vecBPre.y = position.y - 6.0
        primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].fullDisplayAngle = 45
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[2] = 2
        primitive.state.slots[0].height[7] = 0

        if kind == 4 {
            primitive.state.slots[0].height[9] = 10.0
        } else if kind == 2 {
            for i in 1..<4 {
                primitive.state.slots[i].life = 1
                primitive.state.slots[i].alphaB = 0
            }
        } else if kind == 3 {
            primitive.state.slots[0].flag1[2] = 3
        } else if kind == 5 || kind == 6 {
            primitive.state.slots[0].flag1[2] = 4
        } else if kind == 7 {
            primitive.state.slots[0].flag1[2] = 7
        } else if kind == 9 {
            primitive.state.slots[0].flag1[2] = 9
            primitive.state.slots[0].flag1[3] = 6
        }
    }

    // MARK: - EF_BOTTOM_ROKISWEIL (283)

    /// Spawns `PP_BOTTOMOUT` (49) orbiting ground particles for `EF_BOTTOM_ROKISWEIL` (283).
    func bottomOut(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_bottomout)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]

        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }

        let count = kind == 1 ? 1 : 2
        for i in 0..<count {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = Int.random(in: 0..<11)
            if kind == 0 {
                primitive.state.slots[i].distance = Float(Int.random(in: 0..<6)) + 5.0
                primitive.state.slots[i].vecBPre.y = position.y
            } else {
                primitive.state.slots[i].distance = Float(Int.random(in: 0..<20)) * 0.1 + 3.0
                primitive.state.slots[i].vecBPre.y = position.y - 5.0
            }
            primitive.state.slots[i].height[8] = 0
            primitive.state.slots[i].alphaB = 0
            primitive.state.slots[i].vecBNow = SIMD3<Float>(position.x, primitive.state.slots[i].vecBPre.y, position.z)
            primitive.state.slots[i].fullDisplayAngle = 45
            primitive.state.slots[i].flag1[0] = 0
            primitive.state.slots[i].flag1[1] = kind
            primitive.state.slots[i].flag1[2] = 2
            primitive.state.slots[i].height[7] = 0
        }
    }

    // MARK: - EF_CHEMICALPROTECTION (300)
    // CRagEffect::ShockwaveRing(std::int16_t angle)

    // MARK: - EF_TELEPORTATION2 (304)
    // CRagEffect::TeleportRings(const char* name, std::int16_t level)

    // MARK: - EF_EXIT2 (314)
    // CRagEffect::TeleportSpiral(const char* name)

    // MARK: - EF_READYPORTAL2 (316)
    // CRagEffect::BlueRingWave()

    // MARK: - EF_PORTAL2 (317)
    // CRagEffect::VioletRingCloud(char type)

    // MARK: - EF_CALLZONE (340)
    // CRagEffect::CALLZONE(const char* name)

    // MARK: - EF_HEARTCASTING (343)
    // CRagEffect::RingRedPulse(const char* name, float x, float z)

    // MARK: - EF_ENTRY2 (344)
    // CRagEffect::PortalRings()

    // MARK: - EF_SPHEREWIND (346)
    // CRagEffect::FeatherRing(const char* name, std::int16_t angle, char large)

    // MARK: - EF_AURABLADE (367)
    // CRagEffect::WhiteYellowRings()

    // MARK: - EF_HITLINE5 (430)
    // CRagEffect::WhiteSparkRing(char kind)

    // MARK: - EF_ELECTRIC (432)

    /// Spawns `PP_ELECTRIC` (101) radial lightning arcs on ticks 20...23 for `EF_ELECTRIC` (432).
    func electricRingLate(kind: Int16, angle: Int16, context: EffectTickContext) {
        guard stateCnt >= 20, stateCnt <= 23 else {
            return
        }

        let texturePath = "effect\\elec1.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_electric)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = 0.1
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].riseAngle = Int16(index * 45) + angle
            primitive.state.slots[index].distance = 0
            primitive.state.slots[index].height[0] = 0
            primitive.state.slots[index].vecTNow.x = Float(Int.random(in: 0..<11)) * 0.01
            primitive.state.slots[index].vecBNow = position
            primitive.state.slots[index].vecTNow.y = 20.0
            for step in 1...20 {
                primitive.state.slots[index].height[step] = 0
                primitive.state.slots[index].flag1[step] = 0
            }
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].alphaT = kind
            primitive.state.slots[index].fullDisplayAngle = 0
        }
    }

    // MARK: - EF_BLUECASTING (441)
    // CRagEffect::BlueSpellRings()

    // MARK: - EF_DARKCASTING (454)
    // CRagEffect::BlackSpellRings(char silent)

    // MARK: - EF_GROUNDSAMPLE (513)

    /// Spawns primitive `112` terrain-conformed magic target grid for `EF_GROUNDSAMPLE` (513).
    func groundSample(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\magic_target.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(112)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].rotStart = 0
    }

    // MARK: - EF_MAP_MAGICZONE (650)
    // CRagEffect::Map_MagicZone(const char* name, char type)

    // MARK: - EF_MAP_MAGICZONE (650)
    // CRagEffect::WideTripleRingStack(const char* name)

    // MARK: - EF_GLASSWALL3 (754)
    // CRagEffect::WhiteRingWave()

    // MARK: - EF_ELECTRIC3 (781)
    // CRagEffect::ElectricRingEarly(char kind, std::int16_t angle)

    // MARK: - EF_FIRETHROW (787)
    // CRagEffect::TorchRedRing(char kind)

    // MARK: - EF_BOTTOM_MANHOLE (822)
    // CRagEffect::WhiteRingRipple(char size)

    // MARK: - EF_BOTTOM_ANI (827)
    // CRagEffect::TorchDustRing(const char* name, char kind, std::int16_t angle)

    // MARK: - EF_BEGINSPELL_N1 (830)

    /// Spawns primitive `144` expanding bubble-spiral ground arcs for `EF_BEGINSPELL_N1` (830).
    func bubbleSpiralKind(angle: Int16, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        if duration < 100 {
            duration = 100
        }

        let primitive = launchPrimitive(144)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration

        if kind <= 1 {
            let paths = (1...27).map { String(format: "effect\\W_bubble%02d.tga", $0) }
            primitive.state.totalTexture = paths.count
            primitive.state.texturePaths = paths
            for path in paths {
                _ = context.assets?.texture(atPath: path)
            }
            primitive.state.size = kind == 1 ? 4.0 : 0.0
        } else if kind <= 3 {
            let paths = (1...29).map { String(format: "effect\\W_A_top%02d.tga", $0) }
            primitive.state.totalTexture = paths.count
            primitive.state.texturePaths = paths
            for path in paths {
                _ = context.assets?.texture(atPath: path)
            }
            primitive.state.size = kind == 3 ? 4.0 : 0.0
        }

        let configs: [(maxHeight: Float, rotStart: Int16, alphaOffset: Int16)] = [
            (30.0, 180, 135),
            (29.0, 270, 90),
            (28.0, 0, 45),
            (27.0, 90, 0),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = duration <= 60 ? index * -5 : 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = config.maxHeight
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = duration <= 60 ? 0 : (angle + config.alphaOffset)
            primitive.state.slots[index].distance = 4.1
            primitive.state.slots[index].riseAngle = 80
            primitive.state.slots[index].alphaT = Int16(kind)
            primitive.state.slots[index].vecBNow.y = 0
            for step in 0..<21 {
                primitive.state.slots[index].height[step] = 0
                primitive.state.slots[index].flag1[step] = 0
            }
        }
    }

    // MARK: - EF_BEGINSPELL_N2 (831)
    // CRagEffect::BeginSpellSwirl(int, const char*, char alpha)

    // MARK: - EF_BEGINSPELL_150 (880)
    // CRagEffect::BubbleSpiral(std::int16_t angle, const char*, char flag)

    // MARK: - EF_ELECTRIC4 (888)
    // CRagEffect::ElectricRing(char kind, std::int16_t angle)

    // MARK: - EF_SPR_LIGHTPRINT (901)
    // CRagEffect::SpriteRing(char kind)

    // MARK: - EF_GREENCASTING (911)
    // CRagEffect::WhiteSpellRings()

    // MARK: - EF_SMA_BLACK2 (1205)
    // CRagEffect::BlueRingStack()

    // MARK: - EF_NEW_REVERBERATION (1569)
    // CRagEffect::WhiteRingRippleSized(char size)
}
