//
//  RagEffect+ProcessElements.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {

    // MARK: - EF_FIREBALL (24)
    // CRagEffect::FireBall()

    // MARK: - EF_ICEARROW (26)
    // CRagEffect::IceArrow()

    // MARK: - EF_FROSTDIVER (27)
    // CRagEffect::FrostDiver(char type)

    // MARK: - EF_FROSTDIVER2 (28)

    /// Spawns 8 ice pyramid horns (`PP_3DQUADHORN` (9)) for `EF_FROSTDIVER2` (28).
    func frostDiver2(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_FrostDiver2.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = "effect\\ice.tga"
        _ = context.assets?.texture(atPath: texturePath)

        for _ in 0..<8 {
            let primitive = launchPrimitive(.pp_3dquadhorn)
            primitive.state.duration = 40
            primitive.state.pattern |= 1
            let angle = Int.random(in: 0..<360)
            let length = Float(Int.random(in: 0..<4) + 1) / 10.0
            primitive.state.deltaPos2 = SIMD3<Float>(
                EffectSpace.sine(degrees: angle) * length,
                30.0,
                -length * EffectSpace.cosine(degrees: angle)
            )
            primitive.state.size = Float(Int.random(in: 0..<250) + 100) / 100.0
            primitive.state.heightSize = Float(Int.random(in: 0..<100) + 200) / 100.0
            primitive.state.longitude = Float(Int.random(in: 0..<360))
            primitive.state.latitude = Float(Int.random(in: 0..<20) + 80)
            let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(primitive.state.latitude)))
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(primitive.state.longitude)))
            primitive.state.transform = rotY * rotX
            primitive.state.rotTransform = primitive.state.transform
            primitive.state.speed = 3.0
            let decay = -(primitive.state.speed / Float(primitive.state.duration))
            primitive.state.accel = decay + decay
            primitive.state.chCnt = 20
            primitive.state.alpha = 200.0
            primitive.state.fadeOutCnt = primitive.state.duration - 10
            primitive.state.texturePaths = [texturePath]
        }
    }

    // MARK: - EF_FIREARROW (31)
    // CRagEffect::FireArrow()

    // MARK: - EF_SANDWIND (46)
    // CRagEffect::SandScatter()

    // MARK: - EF_SPRAYPOND (48)
    // CRagEffect::SprayPond()

    // MARK: - EF_ICEWALL (74)
    // CRagEffect::IceWall()

    // MARK: - EF_STORMGUST (89)
    // CRagEffect::StormGust()

    // MARK: - EF_METEORSTORM (92)
    // CRagEffect::MeteorStorm()

    // MARK: - EF_FIREPILLAR (96)
    // CRagEffect::FirePillar()

    // MARK: - EF_FIREPILLARBOMB (97)
    // CRagEffect::FirePillarImpact()

    // MARK: - EF_CRASHEARTH (102)
    // CRagEffect::FirePillarBomb()

    // MARK: - EF_WATERBALL (116)
    // CRagEffect::WaterOut()

    // MARK: - EF_WATERBALL2 (117)
    // CRagEffect::WaterBall2()

    // MARK: - EF_SNOW (162)
    // CRagEffect::Snow()

    // MARK: - EF_SAKURA (163)
    // CRagEffect::Sakura()

    // MARK: - EF_SUMMONSLAVE (215)
    // CRagEffect::AlphaCenterRise()

    // MARK: - EF_BLOODDRAIN (216)
    // CRagEffect::RedParticleSpray(int count)

    // MARK: - EF_INTIMIDATE (227)
    // CRagEffect::WhiteSpray(char kind)

    // MARK: - EF_CLOUD (229)
    // CRagEffect::SkyCloud(char kind)

    // MARK: - EF_LINELINK (232)
    // CRagEffect::TrackCloud(char kind)

    // MARK: - EF_POKJUK_SOUND (301)
    // CRagEffect::Fireworks()

    // MARK: - EF_FORESTLIGHT (307)

    /// Spawns slanted pentagonal light shafts (`PP_FOREST` (66)) for `EF_FORESTLIGHT` (307).
    func forestLight(texturePath: String, flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_forest)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]

        let topOffset: SIMD3<Float> = flag == 10
            ? SIMD3<Float>(-15.0, -60.0, -15.0)
            : SIMD3<Float>(-70.0, -300.0, -70.0)
        let topPos = position + topOffset
        deltaPos = topPos

        for i in 0..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = i == 3 ? 180 : 0
            primitive.state.slots[i].alphaB = if flag == 2 || flag == 12 || flag == 13 {
                30
            } else if flag == 10 {
                25
            } else if flag == 11 {
                0
            } else {
                40
            }
            primitive.state.slots[i].distance = 0

            let radius: Float = if i == 3 {
                if flag == 1 || flag == 11 {
                    4.0
                } else if flag == 2 || flag == 12 || flag == 13 {
                    1.0
                } else {
                    2.0
                }
            } else if flag == 1 || flag == 11 {
                Float(i * 2) + 4.0
            } else if flag == 2 || flag == 12 || flag == 13 {
                Float(i) * 0.5 + 1.0
            } else {
                Float(i) + 2.0
            }

            primitive.state.slots[i].maxHeight = radius
            primitive.state.slots[i].height[0] = radius
            primitive.state.slots[i].rotStart = Int16(i * 25)
            primitive.state.slots[i].vecTNow = position
            primitive.state.slots[i].vecTPre = topPos
            primitive.state.slots[i].flag1[0] = flag
        }
    }

    // MARK: - EF_TRIPLEATTACK (329)
    // CRagEffect::CloudDrift()

    // MARK: - EF_MAPLE (333)
    // CRagEffect::Maple()

    // MARK: - EF_WATERFALL (349)
    // CRagEffect::FrostScatter(char swapAxes, char narrow)

    // MARK: - EF_WATERFALL (349)
    // CRagEffect::Waterfall(const char* name, char flag, char tall, char variant)

    // MARK: - EF_TRIPLEATTACK2 (388)
    // CRagEffect::AlphaCenterTrail()

    // MARK: - EF_PORTAL4 (389)
    // CRagEffect::Cloud11Burst(char kind)

    // MARK: - EF_TRIPLEATTACK3 (393)
    // CRagEffect::AlphaCenterStream()

    // MARK: - EF_BABY (408)
    // CRagEffect::FeatherBurst(const char* name, std::int16_t angle, char)

    // MARK: - EF_RAINBOW (410)

    /// Spawns `PP_RAINBOW` (93) 7-band spectral arch for `EF_RAINBOW` (396).
    func rainbow(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_rainbow)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        let yaw = Int(context.world.cameraYawDegrees)
        let facingYaw = Int16(((360 - yaw) % 360 + 360) % 360)
        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].alphaT = facingYaw
        primitive.state.slots[0].distance = 50.0
        primitive.state.slots[0].fullDisplayAngle = 180
        primitive.state.slots[0].rotStart = 0
        primitive.state.slots[0].riseAngle = facingYaw
    }

    // MARK: - EF_BLUEFALL (557)
    // CRagEffect::WaterfallSheets(char first, char second, char third)

    // MARK: - EF_KOUENKA (618)
    // CRagEffect::SakuraFireArrow()

    // MARK: - EF_BUBBLE_DROP (665)
    // CRagEffect::Bubble_Drop()

    // MARK: - EF_DUST (689)

    /// Spawns `PP_EFFECTTEXTURE_ANI` (128) animated billboard panel for `EF_DUST` (689).
    func torchDust(kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePaths: [String] = switch kind {
        case 0:
            (1...9).map { String(format: "effect\\dust%02d.bmp", $0) }
        case 1:
            (1...13).map { String(format: "effect\\torch_red%02d.bmp", $0) }
        case 2:
            (1...13).map { String(format: "effect\\torch_green%02d.bmp", $0) }
        case 3:
            (1...13).map { String(format: "effect\\torch_violet%02d.bmp", $0) }
        case 4:
            [
                "effect\\lord_stick_a.bmp",
                "effect\\lord_stick_b.bmp",
                "effect\\lord_stick_c.bmp",
                "effect\\lord_stick_e.bmp",
                "effect\\lord_stick_f.bmp",
                "effect\\lord_stick_g.bmp",
                "effect\\lord_stick_h.bmp",
                "effect\\lord_stick_plazma_a.bmp",
                "effect\\lord_stick_plazma_b.bmp",
                "effect\\lord_stick_plazma_c.bmp",
                "effect\\lord_blast_stick_a.bmp",
            ]
        default:
            []
        }

        for path in texturePaths {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(.pp_effecttexture_ani)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = texturePaths.count
        primitive.state.texturePaths = texturePaths
        primitive.state.size = 0

        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = param[0] > 0 ? param[0] : 20.0
        primitive.state.slots[0].vecBPre.y = position.y - 10.0
        primitive.state.slots[0].flag1[2] = 4
        if kind == 4 {
            primitive.state.slots[0].fullDisplayAngle = 120
            primitive.state.slots[0].height[10] = 1.0
            primitive.state.slots[0].height[8] = 0
            primitive.state.slots[0].alphaB = 130
        } else {
            primitive.state.slots[0].fullDisplayAngle = 135
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].height[8] = 0
            primitive.state.slots[0].alphaB = kind != 0 ? 130 : 100
        }
        primitive.state.slots[0].vecBNow.x = position.x
        primitive.state.slots[0].vecBNow.z = position.z
        primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[4] = kind
    }

    // MARK: - EF_FROSTMYSTY (726)
    // CRagEffect::SnowFall(const char*, char kind)

    // MARK: - EF_FIREBALL2 (751)
    // CRagEffect::ShadedFireballVolley()

    // MARK: - EF_COLDTHROW (791)
    // CRagEffect::SnowDrift(char flag)

    // MARK: - EF_WATERFALL_ANI (821)
    // CRagEffect::WaterBubble(int)

    // MARK: - EF_HEAL_N (832)
    // CRagEffect::BubbleFanSweep(const char*, char rising)

    // MARK: - EF_WATER_SMOKE (846)
    // CRagEffect::FrostSplash(int, int)

    // MARK: - EF_FIREBALL4 (891)
    // CRagEffect::BlueFireballVolley()

    // MARK: - EF_TRIPLEATTACK4 (892)
    // CRagEffect::CloudBurst()

    // MARK: - EF_FIREBALL5 (913)
    // CRagEffect::PaleFireballVolley()

    // MARK: - EF_WATERBALL3 (942)

    /// Spawns `PP_3DCIRCLE` (12) rings and a `PP_3DSPHERE` (14) burst for `EF_WATERBALL3` (942).
    func waterBallBurst(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\wizard_waterball_chulung.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let ringTexture = "effect\\ring_blue.tga"
        let iceTexture = "effect\\ice.tga"
        _ = context.assets?.texture(atPath: ringTexture)
        _ = context.assets?.texture(atPath: iceTexture)

        let firstRing = launchPrimitive(.pp_3dcircle)
        firstRing.state.duration = 30
        firstRing.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
        firstRing.state.latitude = 90.0
        firstRing.state.radiusSpeed = 1.75
        firstRing.state.radiusAccel = -(firstRing.state.radiusSpeed / Float(firstRing.state.duration)) * 0.5
        firstRing.state.innerSize = 12.0
        firstRing.state.alpha = 0
        firstRing.state.alphaSpeed = firstRing.state.maxAlpha / 15.0
        firstRing.state.fadeOutCnt = 10
        firstRing.initSegment()
        firstRing.state.texturePaths = [ringTexture]

        let sphere = launchPrimitive(.pp_3dsphere)
        sphere.state.duration = 30
        sphere.state.radiusSpeed = 1.15
        sphere.state.radiusAccel = -(sphere.state.radiusSpeed / Float(sphere.state.duration)) * 0.5
        sphere.state.longSpeed = 3.0
        sphere.state.alpha = 0
        sphere.state.alphaSpeed = sphere.state.maxAlpha / 15.0
        sphere.state.fadeOutCnt = 10
        sphere.state.texturePaths = [iceTexture]

        let secondRing = launchPrimitive(.pp_3dcircle)
        secondRing.state.duration = 20
        secondRing.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
        secondRing.state.latitude = 90.0
        secondRing.state.radiusSpeed = 1.75
        secondRing.state.radiusAccel = -(secondRing.state.radiusSpeed / Float(secondRing.state.duration)) * 0.5
        secondRing.state.innerSize = 12.0
        secondRing.state.alpha = 0
        secondRing.state.alphaSpeed = secondRing.state.maxAlpha / 15.0
        secondRing.state.fadeOutCnt = 10
        secondRing.initSegment()
        secondRing.state.texturePaths = [ringTexture]
    }

    // MARK: - EF_DARKPIERCING (1030)
    // CRagEffect::CloudSpread()

    // MARK: - EF_NEW_SEVERERAINSTORM_HIT (1286)
    // CRagEffect::SevereRainstormCylinder(int, const char*, char alpha, float distance)
}
