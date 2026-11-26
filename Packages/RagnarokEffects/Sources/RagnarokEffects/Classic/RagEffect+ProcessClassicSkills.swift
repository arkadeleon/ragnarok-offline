//
//  RagEffect+ProcessClassicSkills.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {

    // MARK: - EF_ENTRY (6)

    /// Spawns counter-rotating `PP_3DCYLINDER` (13) rings for `EF_ENTRY` (6).
    func entry(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\ring_blue.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let outer = launchPrimitive(.pp_3dcylinder)
        outer.state.duration = 55
        let outerRotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(outer.state.latitude)))
        let outerRotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(outer.state.longitude)))
        outer.state.transform = outerRotY * outerRotX
        outer.state.accel = -0.00007
        outer.state.longSpeed = -10.0
        outer.state.outerSize = 6.0
        outer.state.outerSpeed = 0.08
        outer.state.innerSize = 5.0
        outer.state.heightSize = 6.5
        outer.state.heightSpeed = -0.1
        outer.state.alpha = 5.0
        outer.state.maxAlpha = 245.0
        outer.state.alphaSpeed = 10.0
        outer.state.fadeOutCnt = outer.state.duration - outer.state.duration / 5
        outer.state.texturePaths = [texturePath]

        let inner = launchPrimitive(.pp_3dcylinder)
        inner.state.duration = 55
        inner.state.arcAngle = 45.0
        inner.state.longSpeed = 10.0
        inner.state.outerSize = 4.5
        inner.state.innerSize = 4.5
        inner.state.heightSpeed = 2.5
        let accel = -(inner.state.heightSpeed / Float(inner.state.duration))
        inner.state.heightAccel = accel + accel
        inner.state.alpha = 160.0
        inner.state.fadeOutCnt = inner.state.duration - inner.state.duration / 3
        inner.state.texturePaths = [texturePath]
    }

    // MARK: - EF_EXIT (7)
    // CRagEffect::Exit()

    // MARK: - EF_COIN (10)
    // CRagEffect::Coin()

    // MARK: - EF_ENDURE (11)
    // CRagEffect::Endure()

    // MARK: - EF_HEALSP (14)
    // CRagEffect::HealSP()

    // MARK: - EF_SOULSTRIKE (15)

    /// Spawns arcing `PP_3DPARTICLESPLINE` (8) sprite missiles with 12-segment trails for `EF_SOULSTRIKE` (15).
    func soulStrike(flag: Int8, context: EffectTickContext) {
        let missileCount = count > 0 ? Int(count) : max(1, min(7, level > 0 ? level : 5))
        let (total, base, step): (Int, Int, Int) = switch missileCount {
        case 1: (1, 0, 1)
        case 2: (2, -90, 180)
        case 3: (3, -90, 90)
        case 4: (4, -90, 60)
        case 5: (5, -90, 45)
        case 6: (6, -90, 30)
        case 7: (7, -90, 25)
        default: (0, 0, 0)
        }

        let dist = 11
        let delay = 5
        guard (stateCnt + delay) % dist == 0, (stateCnt + delay) / dist <= total else {
            return
        }

        let rollAngle = base + (stateCnt + delay) / dist * step
        context.world.playSound(
            named: "effect\\EF_SoulStrike.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let spritePath = flag == 0 ? K2L("이팩트\\particle1.spr") : K2L("이팩트\\particle5.spr")
        let actionPath = flag == 0 ? K2L("이팩트\\particle1.act") : K2L("이팩트\\particle5.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let launchOrigin = sourcePosition ?? position
        let destination = sourcePosition != nil ? position : (deltaPos == .zero ? position + SIMD3<Float>(25, 0, 0) : deltaPos)
        let dx = destination.x - launchOrigin.x
        let dz = destination.z - launchOrigin.z
        let travelDistance = hypotf(dx, dz)
        let facingDegrees = atan2f(dx, dz) * (180.0 / .pi)

        let primitive = launchPrimitive(.pp_3dparticlespline)
        primitive.state.duration = 40
        primitive.state.deltaPos2 = (launchOrigin - position) + SIMD3<Float>(0, -10.0, 0)
        primitive.state.radius = travelDistance
        primitive.angle = facingDegrees
        primitive.state.longitude = -facingDegrees
        primitive.state.speed = travelDistance / Float(primitive.state.duration)
        primitive.state.gravSpeed = 3.5
        let rise = -(primitive.state.gravSpeed / Float(primitive.state.duration))
        primitive.state.gravAccel = rise + rise
        primitive.state.latiSpeed = -2.0
        let spread = -(primitive.state.latiSpeed / Float(primitive.state.duration))
        primitive.state.latiAccel = spread + spread
        primitive.state.roll = Float(rollAngle)
        primitive.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(primitive.state.longitude)))
        let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, 1), by: primitive.state.transform)
        primitive.state.deltaPos3 = forward
        primitive.state.rotAxis = forward
        primitive.state.size = 2.75
        primitive.state.spritePath = spritePath
        primitive.state.actionPath = actionPath
        primitive.state.numSegment = 12
        primitive.position = launchOrigin + SIMD3<Float>(0, -10.0, 0)
        primitive.initSegment()
    }

    // MARK: - EF_BASH (16)

    /// Spawns a `PP_2DCIRCLE` (4) flash ring and 20 `PP_2DFLASH` (3) radial sparks for `EF_BASH` (16).
    func bash(context: EffectTickContext) {
        guard !context.usesMinimalEffects else {
            return
        }

        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_Bash.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let ringTexture = "effect\\alpha_down.tga"
        let sparkTexture = "EFFECT\\alpha_center.tga"
        _ = context.assets?.texture(atPath: ringTexture)
        _ = context.assets?.texture(atPath: sparkTexture)

        let ring = launchPrimitive(.pp_2dcircle)
        ring.state.duration = 40
        ring.state.pattern |= 1
        ring.state.deltaPos2.y = -40.0
        ring.state.radius = 100.0
        ring.state.alpha = 0
        ring.state.maxAlpha = 170.0
        ring.state.alphaSpeed = ring.state.maxAlpha / 6.0
        ring.state.fadeOutCnt = ring.state.duration - 10
        ring.state.texturePaths = [ringTexture]

        let sparkCount = 20
        for _ in 0..<sparkCount {
            let spark = launchPrimitive(.pp_2dflash)
            spark.state.duration = 40
            spark.state.deltaPos2.y = -40.0
            spark.state.longitude = Float(Int.random(in: 0..<360))
            spark.state.longSpeed = Float(Int.random(in: 0..<60) + 10) / 10.0
            spark.state.longAccel = -(spark.state.longSpeed / Float(spark.state.duration)) / 1.5
            spark.state.arcAngle = Float(Int.random(in: 0..<25) + 5) / 10.0
            spark.state.heightSize = Float(Int.random(in: 0..<40) + 20)
            spark.state.heightSpeed = Float(Int.random(in: 0..<30) + 20) / 10.0
            spark.state.alpha = 0
            spark.state.maxAlpha = 200.0
            spark.state.alphaSpeed = spark.state.maxAlpha / 10.0
            spark.state.fadeOutCnt = spark.state.duration - spark.state.duration / 3
            spark.state.texturePaths = [sparkTexture]
        }
    }

    // MARK: - EF_MAGNUMBREAK (17)
    // CRagEffect::MagnumBreak()

    // MARK: - EF_STEAL (18)

    /// Spawns 10 bouncing `PP_3DPARTICLEGRAVITY` (6) sprite particles for `EF_STEAL` (18).
    func steal(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_Steal.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let spritePath = K2L("이팩트\\particle7.spr")
        let actionPath = K2L("이팩트\\particle7.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        for _ in 0..<10 {
            let primitive = launchPrimitive(.pp_3dparticlegravity)
            primitive.state.longitude = Float(Int.random(in: 0..<360))
            primitive.state.latitude = Float(Int.random(in: 0..<100) - 50)
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(primitive.state.longitude)))
            let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(primitive.state.latitude)))
            primitive.state.transform = rotX * rotY
            let radial = Float(Int.random(in: 0..<4) + 4)
            primitive.state.deltaPos3 = EffectSpace.transformVector(SIMD3<Float>(0, 0, radial), by: primitive.state.transform)
            primitive.state.deltaPos2 = SIMD3<Float>(primitive.state.deltaPos3.x, primitive.state.deltaPos3.y - 10.0, primitive.state.deltaPos3.z)
            primitive.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(primitive.state.longitude)))
            primitive.state.duration = duration
            primitive.state.speed = Float(Int.random(in: 0..<50) + 50) / 100.0
            primitive.state.accel = -(primitive.state.speed / Float(max(1, primitive.state.duration))) * 0.5
            primitive.state.gravSpeed = -Float(Int.random(in: 0..<90) + 60) / 100.0
            primitive.state.gravAccel = -(primitive.state.gravSpeed / Float(max(1, primitive.state.duration))) * 2.0
            primitive.state.size = Float(Int.random(in: 0..<100) + 100) / 100.0
            primitive.state.sizeSpeed = -(primitive.state.size / Float(max(1, primitive.state.duration)))
            primitive.state.fadeOutCnt = primitive.state.duration - primitive.state.duration / 3
            primitive.state.spritePath = spritePath
            primitive.state.actionPath = actionPath
            primitive.initSegment()
        }
    }

    // MARK: - EF_PATTACK (20)
    // CRagEffect::PoisonAttack(char flag)

    // MARK: - EF_DETOXICATION (21)
    // CRagEffect::Detoxication()

    // MARK: - EF_SIGHT (22)
    // CRagEffect::Sight()

    // MARK: - EF_INCAGILITY (37)
    // CRagEffect::AgilityChange(char increase, const std::string& textureName)

    // MARK: - EF_INCAGILITY (37)
    // CRagEffect::IncAgility()

    // MARK: - EF_DECAGILITY (38)
    // CRagEffect::DecAgility()

    // MARK: - EF_SIGNUM (40)
    // CRagEffect::Signum()

    // MARK: - EF_ANGELUS (41)
    // CRagEffect::Angelus()

    // MARK: - EF_BLESSING (42)
    // CRagEffect::Blessing()

    // MARK: - EF_INCAGIDEX (43)
    // CRagEffect::IncAgiDex()

    // MARK: - EF_SIGHTRASHER (62)
    // CRagEffect::Sightrasher()

    // MARK: - EF_INVENOM (65)
    // CRagEffect::Envenom()

    // MARK: - EF_CURE (66)
    // CRagEffect::Cure()

    // MARK: - EF_PROVOKE (67)
    // CRagEffect::Provoke()

    // MARK: - EF_MVP (68)
    // CRagEffect::Mvp()

    // MARK: - EF_SKIDTRAP (69)
    // CRagEffect::SkidTrap()

    // MARK: - EF_SPHERE (72)
    // CRagEffect::Sphere()

    // MARK: - EF_BOWLINGBASH (73)
    // CRagEffect::BowlingBash()

    // MARK: - EF_GLORIA (75)
    // CRagEffect::Gloria()

    // MARK: - EF_MAGNIFICAT (76)
    // CRagEffect::Magnificat()

    // MARK: - EF_RESURRECTION (77)
    // CRagEffect::Resurrection()

    // MARK: - EF_RECOVERY (78)
    // CRagEffect::Recovery()

    // MARK: - EF_EARTHSPIKE (79)
    // CRagEffect::EarthSpike(char type)

    // MARK: - EF_SPEARBMR (80)
    // CRagEffect::SpearBmr()

    // MARK: - EF_TURNUNDEAD (82)
    // CRagEffect::TurnUndead()

    // MARK: - EF_SANCTUARY (83)
    // CRagEffect::Sanctuary()

    // MARK: - EF_IMPOSITIO (84)
    // CRagEffect::Impositio()

    // MARK: - EF_LEXAETERNA (85)
    // CRagEffect::LexAeterna()

    // MARK: - EF_ASPERSIO (86)
    // CRagEffect::Aspersio()

    // MARK: - EF_LEXDIVINA (87)
    // CRagEffect::LexDivina()

    // MARK: - EF_SUFFRAGIUM (88)
    // CRagEffect::Suffragium()

    // MARK: - EF_BENEDICTIO (91)
    // CRagEffect::Benedictio()

    // MARK: - EF_YUFITEL (93)
    // CRagEffect::Yufitel(char F1)

    // MARK: - EF_HASTEUP (98)
    // CRagEffect::HasteUp()

    // MARK: - EF_FLASHER (99)
    // CRagEffect::Flasher()

    // MARK: - EF_REMOVETRAP (100)
    // CRagEffect::RemoveTrap()

    // MARK: - EF_PERFECTION (103)
    // CRagEffect::WeaponPerfection()

    // MARK: - EF_MAXPOWER (104)
    // CRagEffect::MaximizePower()

    // MARK: - EF_BLASTMINEBOMB (106)
    // CRagEffect::BlastMineExplosion()

    // MARK: - EF_CLAYMORE (107)
    // CRagEffect::ClaymoreTrap()

    // MARK: - EF_FREEZING (108)
    // CRagEffect::FreezingTrap()

    // MARK: - EF_SPRINGTRAP (111)
    // CRagEffect::SpringTrap()

    // MARK: - EF_KYRIE (112)
    // CRagEffect::KyrieEleison()

    // MARK: - EF_MAGNUS (113)
    // CRagEffect::Magnus()

    // MARK: - EF_BLITZBEAT (115)
    // CRagEffect::BlitzBeat()

    // MARK: - EF_GRIMTOOTH (123)
    // CRagEffect::GrimTooth()

    // MARK: - EF_POISONREACT2 (127)
    // CRagEffect::PoisonReact2()

    // MARK: - EF_TWOHANDQUICKEN (130)
    // CRagEffect::TwoHandQuicken()

    // MARK: - EF_AUTOCOUNTER (131)
    // CRagEffect::AutoCounter()

    // MARK: - EF_GRIMTOOTHATK (132)
    // CRagEffect::GrimToothAtk()

    // MARK: - EF_HEAVENSDRIVE (142)
    // CRagEffect::StoneSpike()

    // MARK: - EF_CONCENTRATION (153)
    // CRagEffect::Concentration()

    // MARK: - EF_REFINEOK (154)
    // CRagEffect::RefineSuccess()

    // MARK: - EF_REFINEFAIL (155)
    // CRagEffect::RefineFailed()

    // MARK: - EF_CARTREVOLUTION (170)
    // CRagEffect::CartRevolution()

    // MARK: - EF_ENERGYDRAIN (217)
    // CRagEffect::BloodDrain()

    // MARK: - EF_POTION_CON (218)
    // CRagEffect::PotionPillar(float heightSpeed, int duration)

    // MARK: - EF_POTION_BERSERK (220)
    // CRagEffect::Potion_Berserk()

    // MARK: - EF_GRANDCROSS (226)

    /// Spawns ground cross pillars (`PP_GRANDCROSS2` (37)) for `EF_GRANDCROSS2` (450).
    func grandCross2(flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = flag == 0 ? "effect\\ring_yellow.tga" : "effect\\ring_black.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_grandcross2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 1.0

        for index in 0..<2 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = 60.0
            primitive.state.slots[index].rotStart = Int16(index * 90)
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].height[0] = 24.0
            primitive.state.slots[index].height[1] = 3.2
            primitive.state.slots[index].height[2] = 0
        }
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0
    }

    // MARK: - EF_DEMONSTRATION (302)
    // CRagEffect::Demonstration()

    // MARK: - EF_FIRSTAID (309)

    /// Spawns `PP_FIRSTAID` (58) pulsing glow panel for `EF_FIRSTAID` (309).
    func firstAid(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "_heal_effect.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = "effect\\pikapika2.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_firstaid)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = 10.0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].vecBNow = SIMD3<Float>(position.x, position.y - 12.0, position.z)
        primitive.state.slots[0].height[6] = 0.02
        primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[2] = 1
        primitive.state.slots[0].height[8] = Float(Int.random(in: 0..<360))
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
            primitive.state.slots[i].alphaB = 0
        }
    }

    // MARK: - EF_HEAL (312)

    /// Spawns pulsing casting columns (`60`) and rising particles (`PP_PARTICLE_UP` (59)) for `EF_HEAL` (312) and `EF_HEAL3` (320).
    func healBurst(texturePath: String, flag: Int8, context: EffectTickContext) {
        let limit = flag != 0 ? 25 : 50

        if stateCnt == 0 {
            let primitive = launchPrimitive(60)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = [texturePath]
            _ = context.assets?.texture(atPath: texturePath)

            if flag == 0 {
                primitive.state.size = 9.0
            } else if flag == 1 {
                primitive.state.size = 5.0
            }

            primitive.state.slots[0].life = 1
            primitive.state.slots[0].process = 0
            primitive.state.slots[0].fullDisplayAngle = 360
            primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[0].alphaB = 0
            primitive.state.slots[0].riseAngle = 90
            primitive.state.slots[0].vecBNow.y = 0

            if flag == 0 {
                primitive.state.slots[0].alphaT = 60
                primitive.state.slots[0].maxHeight = 40.0
                primitive.state.slots[0].distance = 4.6
            } else if flag == 1 {
                primitive.state.slots[0].alphaT = 30
                primitive.state.slots[0].maxHeight = Float(Int.random(in: 0..<20)) + 40.0
                primitive.state.slots[0].distance = 4.5 + Float(Int.random(in: 0..<100)) * 0.005
            }

            for i in 0..<21 {
                primitive.state.slots[0].height[i] = 0
                primitive.state.slots[0].flag1[i] = 0
            }

            primitive.state.slots[1].life = 1
            primitive.state.slots[1].process = 0
            primitive.state.slots[1].fullDisplayAngle = 360
            primitive.state.slots[1].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[1].alphaB = 0
            primitive.state.slots[1].riseAngle = 90
            primitive.state.slots[1].vecBNow.y = 0

            if flag == 0 {
                primitive.state.slots[1].alphaT = 60
                primitive.state.slots[1].maxHeight = 40.0
                primitive.state.slots[1].distance = 4.8
            } else if flag == 1 {
                primitive.state.slots[1].alphaT = 30
                primitive.state.slots[1].maxHeight = primitive.state.slots[0].maxHeight
                primitive.state.slots[1].distance = primitive.state.slots[0].distance + 0.2
            }

            for i in 0..<21 {
                primitive.state.slots[1].height[i] = 0
                primitive.state.slots[1].flag1[i] = 0
            }

            primitive.state.slots[2].life = 0
            primitive.state.slots[3].life = 0

            context.world.playSound(
                named: "_heal_effect.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
            return
        }

        guard stateCnt <= limit, stateCnt % 6 == 0 else {
            return
        }

        if flag == 0 {
            let primitive = launchPrimitive(.pp_particle_up)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = ["effect\\pok1.tga"]
            _ = context.assets?.texture(atPath: "effect\\pok1.tga")
            primitive.state.size = 0
            primitive.position = position

            for i in 0..<4 {
                primitive.state.slots[i].life = 1
                primitive.state.slots[i].process = 0
                primitive.state.slots[i].distance = Float(Int.random(in: 0..<10)) * 0.1 + 2.0
                primitive.state.slots[i].height[8] = 0
                primitive.state.slots[i].alphaB = 0
                primitive.state.slots[i].vecBNow.x = Float(Int.random(in: 0..<13)) + position.x - 6.0
                primitive.state.slots[i].vecBNow.z = Float(Int.random(in: 0..<13)) + position.z - 6.0
                primitive.state.slots[i].vecBNow.y = position.y
                primitive.state.slots[i].rotStart = 0
                primitive.state.slots[i].height[1] = 0
                primitive.state.slots[i].height[2] = Float(Int.random(in: 0..<40)) * 0.01 + 0.3
                primitive.state.slots[i].fullDisplayAngle = 0
                primitive.state.slots[i].flag1[0] = 0
                primitive.state.slots[i].flag1[1] = 0
                primitive.state.slots[i].flag1[2] = 11
                primitive.state.slots[i].height[7] = 0
            }
            return
        }

        if flag == 1 {
            let primitive = launchPrimitive(.pp_particle_up)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = ["effect\\pok1.tga", "effect\\pok3.tga"]
            _ = context.assets?.texture(atPath: "effect\\pok1.tga")
            _ = context.assets?.texture(atPath: "effect\\pok3.tga")
            primitive.state.size = 0
            primitive.position = position

            for i in 0..<4 {
                primitive.state.slots[i].life = 1
                primitive.state.slots[i].process = 0
                primitive.state.slots[i].distance = Float(Int.random(in: 0..<10)) * 0.1 + 2.0
                primitive.state.slots[i].height[8] = 0
                primitive.state.slots[i].alphaB = 0
                primitive.state.slots[i].vecBNow.x = Float(Int.random(in: 0..<13)) + position.x - 6.0
                primitive.state.slots[i].vecBNow.z = Float(Int.random(in: 0..<13)) + position.z - 6.0
                primitive.state.slots[i].vecBNow.y = position.y
                primitive.state.slots[i].rotStart = 0
                primitive.state.slots[i].height[1] = 0
                primitive.state.slots[i].height[2] = Float(Int.random(in: 0..<40)) * 0.01 + 0.4
                primitive.state.slots[i].fullDisplayAngle = 0
                primitive.state.slots[i].flag1[0] = 0
                primitive.state.slots[i].flag1[1] = 1
                primitive.state.slots[i].flag1[2] = 11
                primitive.state.slots[i].height[7] = 0
            }
        }
    }

    // MARK: - EF_BEGINASURA (328)
    // CRagEffect::AsuraStrike(char kind)

    // MARK: - EF_POISON (335)

    /// Spawns primitive `72` tiled poison mist overlay for `EF_POISON` (335).
    func poison(flag: Int8, context: EffectTickContext) {
        if stateCnt == 99_999_998 {
            stateCnt = 0
            duration = 99_999_999
        } else if stateCnt != 0 {
            return
        }

        let texturePath = flag == 0 ? "effect\\poison_f.bmp" : "effect\\white02.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(72)
        primitive.state.renderFlag |= 0x200
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        position.y -= 9.0
        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = 30.0
        primitive.state.slots[0].maxHeight = 0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].flag1[10] = flag
    }

    // MARK: - EF_GUARD (336)

    /// Spawns `PP_GUARD` (61) sphere cage and plays the guard sound for `EF_GUARD` (336).
    func kyrieGuard(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\kyrie_guard.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let secondaryTexture = "effect\\guardK2.tga"
        _ = context.assets?.texture(atPath: texturePath)
        _ = context.assets?.texture(atPath: secondaryTexture)

        let primitive = launchPrimitive(.pp_guard)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 2
        primitive.state.texturePaths = [texturePath, secondaryTexture]
        primitive.state.size = 11.0
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].maxHeight = 7.8
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].distance = 1.0
        primitive.state.slots[0].height[0] = 0
        primitive.state.slots[1].life = 0
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0

        if kind == 2 || kind == 3 || kind == 4 || kind == 5 {
            primitive.state.slots[0].flag1[0] = kind
        } else {
            primitive.state.slots[0].flag1[0] = 0
        }
    }

    // MARK: - EF_MAGNUM2 (339)

    /// Emits `PP_MAGNUM2` (73) shockwave waves and sound cues for `EF_MAGNUM2` (339).
    func magnum2(texturePath: String, context: EffectTickContext) {
        if stateCnt == 0 {
            flag = 0
        }

        if stateCnt == 20 {
            context.world.playSound(
                named: "permeter_attack.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        } else if stateCnt == 30 {
            context.world.playSound(
                named: "effect\\EF_MagnumBreak.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        guard stateCnt >= 25, stateCnt <= 55, stateCnt % 3 == 0 else {
            return
        }

        flag += 1
        guard flag < 11 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let time = stateCnt - 25
        let primitive = launchPrimitive(.pp_magnum2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 5.0

        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }

        for i in 0..<2 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].fullDisplayAngle = 360
            primitive.state.slots[i].maxHeight = 20.0 - Float(time) * 0.7
            primitive.state.slots[i].rotStart = Int16(i * 9 + time * 6)
            primitive.state.slots[i].alphaB = 0
            primitive.state.slots[i].distance = Float(time) * 0.2 + 5.0
            primitive.state.slots[i].riseAngle = Int16(70 - i * 8 - time * 2)
            primitive.state.slots[i].alphaT = Int16(i)
        }
    }

    // MARK: - EF_ENERGYDRAIN2 (378)
    // CRagEffect::EnergyDrain2()

    // MARK: - EF_AGIUP (456)
    // CRagEffect::IncAgilityCenter(char kind)

    // MARK: - EF_EDP (493)
    // CRagEffect::EnchantPoison2()

    // MARK: - EF_GUARD2 (496)
    // CRagEffect::BlackMaximize(const char* name)

    // MARK: - EF_SHIELDBOOMERANG3 (520)
    // CRagEffect::ShieldBoomerang3(const char* name)

    // MARK: - EF_EARTHWALL (732)
    // CRagEffect::StoneWall()

    // MARK: - EF_POTION_BERSERK2 (756)
    // CRagEffect::Potion_Awakening()

    // MARK: - EF_FIREWALL2 (920)
    // CRagEffect::ShieldCharge()
}
