//
//  RagEffect+ProcessTexturedMotion.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {

    // MARK: - EF_SHIELDBOOMERANG (249)

    /// Spawns a boomerang shield projectile with 3 trail slots (`PP_SHIELDBOOMERANG` (42)) for `EF_SHIELDBOOMERANG` (249).
    func texturedShieldThrow(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\cru_shield boomerang.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        _ = context.assets?.texture(atPath: texturePath)

        let (origin, destination) = directionalLaunchEndpoints()
        let deltaX = destination.x - origin.x
        let deltaZ = destination.z - origin.z
        let travelDistance = max(0.001, sqrtf(deltaZ * deltaZ + deltaX * deltaX))

        let shield = launchPrimitive(.pp_shieldboomerang)
        shield.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        shield.state.duration = duration
        shield.state.texturePaths = [texturePath]
        shield.state.size = 0
        shield.state.deltaPos = destination
        shield.state.slots[0].life = 1
        shield.state.slots[0].process = 0
        shield.state.slots[0].maxHeight = travelDistance
        shield.state.slots[0].distance = 7.0
        shield.state.slots[0].height[8] = 0
        shield.state.slots[0].alphaB = 255
        shield.state.slots[0].vecBNow = SIMD3<Float>(origin.x, origin.y - 8.0, origin.z)
        shield.state.slots[0].rotStart = 0
        shield.state.slots[0].height[1] = 2.0
        shield.state.slots[0].height[2] = (shield.state.slots[0].height[1] / travelDistance) * (destination.y - origin.y)
        shield.state.slots[0].fullDisplayAngle = 0
        shield.state.slots[0].flag1[0] = 0
        shield.state.slots[0].flag1[1] = 0
        shield.state.slots[0].flag1[2] = 0

        for i in 1..<4 {
            shield.state.slots[i].life = 1
            shield.state.slots[i].alphaB = 0
        }
    }

    // MARK: - EF_TEIHIT1 (262)
    // CRagEffect::TexturedScatter(const char* name, char flag)

    // MARK: - EF_RG_COIN (274)
    // CRagEffect::TexturedSpray(const char* name)

    // MARK: - EF_TEIHIT3 (276)
    // CRagEffect::TexturedScatterLow(const char* name, char flag)

    // MARK: - EF_FOOT (326)
    // CRagEffect::TexturedRise(const char* name, char large)

    // MARK: - EF_HPTIME (331)
    // CRagEffect::TexturedRisingOrbs(const char* name, char kind)

    // MARK: - EF_SAINTWING (345)
    // CRagEffect::TexturedPair(const char* name)

    // MARK: - EF_LIGHTSPHERE (348)
    // CRagEffect::TexturedSparkle(const char* name)

    // MARK: - EF_PRESSURE (365)
    // CRagEffect::TexturedRain(const char* name, char kind)

    // MARK: - EF_BASH3D (366)
    // CRagEffect::TexturedQuadSpin(const char* name, char phase, char kind)

    // MARK: - EF_PEONG (411)
    // CRagEffect::TexturedScatterArc(const char* name, std::int16_t angle, int phase)

    // MARK: - EF_ATTACKENERGY (437)
    // CRagEffect::TexturedBurst(const char* name)

    // MARK: - EF_FLOWERCAST (488)

    /// Spawns dual-phase petal casting rings (`PP_FLOWERCAST` (108)) for `EF_FLOWERCAST` (488).
    func texturedSlashAir(texturePath: String, size: Int8, phase: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_flowercast)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = Float(size)

        let configs: [(distance: Float, riseAngle: Int16, maxHeight: Float, rotStart: Int16)] = if phase == 0 {
            [
                (4.5, 85, 27.0, 0),
                (5.0, 80, 28.0, 90),
                (5.5, 70, 29.0, 180),
                (5.0, 75, 30.0, 270),
            ]
        } else {
            [
                (5.5, 50, 30.0, 90),
                (6.0, 55, 29.0, 180),
                (6.5, 65, 28.0, 270),
                (6.0, 60, 27.0, 0),
            ]
        }

        for (i, config) in configs.enumerated() {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].fullDisplayAngle = 315
            primitive.state.slots[i].alphaB = 0
            primitive.state.slots[i].vecBNow.y = 0
            primitive.state.slots[i].distance = config.distance
            primitive.state.slots[i].riseAngle = config.riseAngle
            primitive.state.slots[i].maxHeight = config.maxHeight
            primitive.state.slots[i].rotStart = config.rotStart
            primitive.state.slots[i].vecTNow.x = Float(config.riseAngle)
            primitive.state.slots[i].vecTNow.y = config.maxHeight
            for j in 0..<21 {
                primitive.state.slots[i].height[j] = 0
                primitive.state.slots[i].flag1[j] = 0
            }
        }
    }

    // MARK: - EF_RG_COIN2 (495)
    // CRagEffect::TexturedSprayKind(const char* name, float spin, char kind)

    // MARK: - EF_SOULLINK (503)
    // CRagEffect::TexturedOrbit(const char* name)

    // MARK: - EF_SOULLIGHT (506)
    // CRagEffect::TexturedStorm2(const char* name, char kind)

    // MARK: - EF_BOTTOM_HERMODE (517)
    // CRagEffect::TexturedSpin(const char* name)

    // MARK: - EF_CARTTER (518)
    // CRagEffect::TexturedTumble(const char* name, char)

    // MARK: - EF_STIN (547)
    // CRagEffect::TexturedSlashFan(const char* name)

    // MARK: - EF_STIN2 (553)
    // CRagEffect::TexturedSlashLevel(const char* name, char kind)

    // MARK: - EF_SMA3 (556)
    // CRagEffect::TexturedComet(const char* name, char kind)

    // MARK: - EF_HAMICASTLE (570)
    // CRagEffect::TexturedClassChange(char kind)

    // MARK: - EF_STIN4 (621)
    // CRagEffect::TexturedSlashWave(const char* name, char kind)

    // MARK: - EF_MAP_MAGICZONE2 (651)
    // CRagEffect::TexturedOrbitDust(const char* name, char rise, char kind)

    // MARK: - EF_FIREPILLARON2 (718)
    // CRagEffect::TexturedSpreadFlat(const char* name, char kind)

    // MARK: - EF_ROLLING1 (758)
    // CRagEffect::TexturedSlam(const char* name, std::int16_t kind, char)

    // MARK: - EF_TETRA (804)
    // CRagEffect::TexturedSpread(const char* name, char kind)

    // MARK: - EF_BEGINSPELL_N2 (831)
    // CRagEffect::TexturedTwinSpin(const char* name, char kind)

    // MARK: - EF_WATER_FADE (839)

    /// Spawns primitive `148` cross-fading dual-texture ground square for `EF_WATER_FADE` (839).
    func texturedDualSpin(
        firstTexturePath: String,
        secondTexturePath: String,
        context: EffectTickContext
    ) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: firstTexturePath)
        _ = context.assets?.texture(atPath: secondTexturePath)

        let primitive = launchPrimitive(148)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 2
        primitive.state.texturePaths = [firstTexturePath, secondTexturePath]
        primitive.state.slots[0].life = 1
        primitive.state.slots[1].life = 0
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = param[0] < 5.0 ? 20.0 : param[0]
        let rotation = param[1]
        primitive.state.slots[0].rotStart = (rotation < 0 || rotation >= 360) ? 45 : Int16(rotation)
        primitive.state.slots[0].riseAngle = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].height[0] = -2.0
        primitive.state.slots[0].height[1] = 0
    }

    // MARK: - EF_LINKPARTICLE (849)
    // CRagEffect::TexturedTumbleOrb(const char* name, char flag)

    // MARK: - EF_CHEMICAL_V (854)
    // CRagEffect::TexturedForkBolt(const char* name, char flag)

    // MARK: - EF_BOT_REVERB (856)
    // CRagEffect::TexturedDrop(const char* name, char flag)

    // MARK: - EF_RAIN_PARTICLE (857)
    // CRagEffect::TexturedFloatingDust(const char* name, int)

    // MARK: - EF_PRIMECHARGE (882)

    /// Spawns primitive `159` inward-collapsing spiral blades for `EF_PRIMECHARGE` (882).
    func texturedScatterSphere(texturePath: String, flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(159)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]

        for index in 0..<4 {
            let riseAngle = Int16(Int.random(in: 0..<360))
            let rotStart = Int16(Int.random(in: 0..<360))
            let radius = EffectSpace.cosine(degrees: Int(riseAngle)) * 70.0
            let z = EffectSpace.sine(degrees: Int(riseAngle)) * 70.0
            let x = radius * EffectSpace.cosine(degrees: Int(rotStart))
            let y = radius * EffectSpace.sine(degrees: Int(rotStart)) - 5.0

            primitive.state.slots[index].life = 1
            primitive.state.slots[index].height[4] = 0
            primitive.state.slots[index].process = -Int.random(in: 0..<101)
            primitive.state.slots[index].distance = 4.0
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].riseAngle = riseAngle
            primitive.state.slots[index].rotStart = rotStart
            primitive.state.slots[index].height[0] = -5.0
            primitive.state.slots[index].height[1] = 0.5
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].flag1[1] = 0
            primitive.state.slots[index].flag1[2] = flag
            primitive.state.slots[index].vecBNow = SIMD3<Float>(x, y, z)
        }
    }

    // MARK: - EF_GRADIUS_LASER (884)
    // CRagEffect::TexturedTripleOrbit(const char* name)

    // MARK: - EF_DQ9_CHARGE (895)
    // CRagEffect::TexturedSpiral(const char* name, int, int)

    // MARK: - EF_DQ9_CHARGE2 (896)
    // CRagEffect::TexturedSpiralSmall(const char* name, int, int)

    // MARK: - EF_DQ9_CHARGE3 (897)
    // CRagEffect::TexturedSpiralTall(const char* name, int, int)

    // MARK: - EF_DQ9_CHARGE4 (898)

    /// Spawns primitive `165` dual-layer curved fan trails for `EF_DQ9_CHARGE4` (898).
    func texturedSpiralFade(texturePath: String, context: EffectTickContext) {
        guard stateCnt <= 2 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(165)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        for slot in 0..<4 {
            primitive.state.slots[slot].life = 1
            primitive.state.slots[slot].process = 0
            primitive.state.slots[slot].distance = 0
            primitive.state.slots[slot].height[10] = 0
            primitive.state.slots[slot].maxHeight = 15.0
            primitive.state.slots[slot].alphaB = 0
            primitive.state.slots[slot].riseAngle = Int16((stateCnt * 4 + slot) * 30)
            primitive.state.slots[slot].rotStart = 0
            primitive.state.slots[slot].height[0] = -5.0
            primitive.state.slots[slot].height[1] = 0
        }
    }

    // MARK: - EF_SELFSCROLL (900)

    /// Spawns dual-layer primitive `166` folding ribbons for `EF_SELFSCROLL` (900).
    func texturedDoubleSpiral(texturePath: String, context: EffectTickContext) {
        guard stateCnt <= 1 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let layers: [(distance: Float, alphaB: Int16, phaseSpeed: Float, shadeFlag: Float)] = [
            (6.0, 205, 0.01, 0.0),
            (10.5, 255, 0.015, 1.0),
        ]

        for layer in layers {
            let primitive = launchPrimitive(166)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.totalTexture = 1
            primitive.state.texturePaths = [texturePath]

            for index in 0..<4 {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = 0
                primitive.state.slots[index].distance = layer.distance
                primitive.state.slots[index].alphaB = layer.alphaB
                primitive.state.slots[index].riseAngle = Int16((stateCnt * 4 + index) * 45)
                primitive.state.slots[index].rotStart = 0
                primitive.state.slots[index].height[0] = -5.0
                primitive.state.slots[index].height[1] = 0
                primitive.state.slots[index].height[9] = 0
                primitive.state.slots[index].height[2] = layer.phaseSpeed
                primitive.state.slots[index].height[3] = layer.shadeFlag
            }
        }
    }

    // MARK: - EF_CHEMICAL_ALLRANGE (969)
    // CRagEffect::TexturedSpinShards(const char* name, char kind)

    // MARK: - EF_NEW_SONICWAVE (1678)
    // CRagEffect::TexturedFanSweep(const char* name, char wide)

    // MARK: - EF_STATUS_CRATE_UP (2288)
    // CRagEffect::TexturedQuadSpiral(const char* name)

    // MARK: - EF_CRUEL_BITE_LINE (2439)
    // CRagEffect::TexturedSwirl(unsigned char clockwise, const char* name)
}
