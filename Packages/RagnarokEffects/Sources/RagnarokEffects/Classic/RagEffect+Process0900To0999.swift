//
//  RagEffect+Process0900To0999.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs0900To0999: [EffectID] = [
        .ef_selfscroll,
        .ef_spr_lightprint,
        .ef_png_test,
        .ef_beginspell_yb,
        .ef_chemical2dash4,
        .ef_groundshake2,
        .ef_pressure2,
        .ef_rg_coin7,
        .ef_primecharge2,
        .ef_primecharge3,
        .ef_primecharge4,
        .ef_greencasting,
        .ef_wallofthorn,
        .ef_fireball5,
        .ef_throwitem11,
        .ef_spr_plant9,
        .ef_demonicfire,
        .ef_demonicfire2,
        .ef_demonicfire3,
        .ef_hellsplant,
        .ef_vacuum,
        .ef_spr_plant10,
        .ef_spr_lightprint2,
        .ef_poisonsmoke2,
        .ef_makehallu2,
        .ef_spr_plant11,
        .ef_coldthrow2,
        .ef_demonicfire4,
        .ef_pressure3,
        .ef_linkparticle2,
        .ef_soullight3,
        .ef_gumgang6,
        .ef_fireball6,
        .ef_gumgang7,
        .ef_gumgang8,
        .ef_gumgang9,
        .ef_bottom_de2,
        .ef_coldstatus,
        .ef_spr_lightprint3,
        .ef_waterball3,
        .ef_heal_n2,
        .ef_rain_particle2,
        .ef_cloud9,
        .ef_yellowfly3,
        .ef_el_gust,
        .ef_el_blast,
        .ef_el_aquaplay,
        .ef_el_upheaval,
        .ef_el_wild_storm,
        .ef_el_chilly_air,
        .ef_el_cursed_soil,
        .ef_el_cooler,
        .ef_el_tropic,
        .ef_el_pyrotechnic,
        .ef_el_petrology,
        .ef_el_heater,
        .ef_silent_breeze,
        .ef_magma_flow,
        .ef_graybody,
        .ef_chemical_allrange,
        .ef_tetra_fire,
        .ef_tetra_water,
        .ef_tetra_wind,
        .ef_tetra_ground,
    ]

    func process0900To0999(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_selfscroll:
            texturedDoubleSpiral(texturePath: "effect\\shockwave_c.bmp", context: context)
        case .ef_spr_lightprint:
            spriteRing(kind: 9, context: context)
        case .ef_png_test:
            texturedAura(texturePath: "pe_fur1_01.bmp", kind: 1, context: context)
        case .ef_beginspell_yb:
            beginSpellSwirl(alpha: 10, context: context)
        case .ef_chemical2dash4:
            for _ in 0..<4 {
                lineStreakTextured(kind: 10, texturePath: "effect\\throw.bmp", context: context)
                lineStreakTextured(kind: 11, texturePath: "effect\\throw.bmp", context: context)
            }
        case .ef_groundshake2:
            texturedLevelRing(texturePath: "effect\\explosive_1_128.bmp", process: 0, level: 10, context: context)
        case .ef_pressure2:
            if stateCnt == 3 {
                context.world.playSound(
                    named: K2L("effect\\프레셔.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt == 25 {
                context.world.playSound(
                    named: "effect\\LG_SHIELDPRESS.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedRain(texturePath: "effect\\shield.bmp", kind: 0, context: context)
            texturedLevelRing(texturePath: "effect\\explosive_1_128.bmp", process: -28, level: 0, context: context)
        case .ef_rg_coin7:
            if stateCnt == 26 {
                context.world.playSound(
                    named: "effect\\LG_PINPOINTATTACK.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt % 4 <= 1, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(.shake(amplitude: 2.0, durationTicks: 2), to: targetID)
            }
            for _ in 0..<4 {
                texturedSprayKind(texturePath: "effect\\shield.bmp", spin: 5.0, kind: 7, context: context)
                texturedSprayKind(texturePath: "effect\\sword.bmp", spin: 9.0, kind: 7, context: context)
            }
        case .ef_primecharge2:
            for _ in 0..<40 {
                texturedScatterSphere(texturePath: "effect\\alpha_center.tga", flag: 1, context: context)
            }
        case .ef_primecharge3:
            if stateCnt == 10 {
                context.world.playSound(
                    named: "effect\\LG_BANDING.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for _ in 0..<40 {
                texturedScatterSphere(texturePath: "effect\\alpha_center.tga", flag: 2, context: context)
            }
        case .ef_primecharge4:
            if stateCnt == 10 {
                context.world.playSound(
                    named: "effect\\LG_INSPIRATION.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for _ in 0..<40 {
                texturedScatterSphere(texturePath: "effect\\alpha_center.tga", flag: 3, context: context)
            }
        case .ef_greencasting:
            whiteSpellRings(context: context)
        case .ef_wallofthorn:
            texturedClassChange(kind: 61, context: context)
        case .ef_fireball5:
            paleFireballVolley(context: context)
        case .ef_throwitem11:
            throwItem(texturePath: K2L("유저인터페이스\\item\\폭탄버섯포자.bmp"), kind: 1, context: context)
        case .ef_spr_plant9:
            monsterSpriteBurst(kind: 9, context: context)
        case .ef_demonicfire:
            monsterSpriteBurst(kind: 10, context: context)
        case .ef_demonicfire2:
            monsterSpriteBurst(kind: 11, context: context)
        case .ef_demonicfire3:
            monsterSpriteBurst(kind: 12, context: context)
        case .ef_hellsplant:
            texturedClassChange(kind: 63, context: context)
        case .ef_vacuum:
            texturedClassChange(kind: 64, context: context)
            texturedClassChange(kind: 65, context: context)
        case .ef_spr_plant10:
            monsterSpriteBurst(kind: 13, context: context)
        case .ef_spr_lightprint2:
            spriteRing(kind: 10, context: context)
        case .ef_poisonsmoke2:
            poisonAttack(flag: 1, context: context)
        case .ef_makehallu2:
            spawnHallucinationTrail(context: context)
        case .ef_spr_plant11:
            monsterSpriteBurst(kind: 14, context: context)
        case .ef_coldthrow2:
            if stateCnt >= 6 && stateCnt <= 40, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(0.0, 0.0, 1.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
            for _ in 0..<3 {
                snowDrift(flag: 0, context: context)
            }
        case .ef_demonicfire4:
            monsterSpriteBurst(kind: 15, context: context)
        case .ef_pressure3:
            if stateCnt == 3 {
                context.world.playSound(
                    named: K2L("effect\\프레셔.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt == 22 {
                context.world.playSound(
                    named: K2L("effect\\S바레티르스피어.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedRain(texturePath: K2L("유저인터페이스\\item\\스피어.bmp"), kind: 4, context: context)
            texturedRain(texturePath: K2L("유저인터페이스\\item\\파이크.bmp"), kind: 4, context: context)
            texturedRain(texturePath: K2L("유저인터페이스\\item\\궁그닐.bmp"), kind: 4, context: context)
            texturedLevelRing(texturePath: "effect\\explosive_1_128.bmp", process: -28, level: 0, context: context)
        case .ef_linkparticle2:
            texturedTumbleOrb(texturePath: "effect\\whitelight.tga", flag: 2, context: context)
            texturedTumbleOrb(texturePath: "effect\\whitelight.tga", flag: 1, context: context)
        case .ef_soullight3:
            texturedStorm2(texturePath: "effect\\whitelight.tga", kind: 3, context: context)
        case .ef_gumgang6:
            texturedCrossKind(texturePath: "effect\\ring_white.tga", level: 4, context: context)
            if stateCnt >= 10 && stateCnt <= 34 && stateCnt % 4 < 2, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(1.0, 1.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_fireball6:
            greenRocketPunch(context: context)
        case .ef_gumgang7:
            texturedCrossKind(texturePath: "effect\\ring_red.tga", level: 4, context: context)
            if stateCnt <= 30, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(1.0, 0.0, 0.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_gumgang8:
            texturedCrossKind(texturePath: "effect\\ring_yellow.tga", level: 4, context: context)
            if stateCnt <= 30, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(1.0, 1.0, 0.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_gumgang9:
            texturedCrossKind(texturePath: "effect\\ring_brown.tga", level: 4, context: context)
            if stateCnt <= 30, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(80.0 / 255.0, 40.0 / 255.0, 0.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_bottom_de2:
            texturedGroundRing(texturePath: "effect\\ring_blue.tga", flag: 0, context: context)
        case .ef_coldstatus:
            texturedAura(texturePath: K2L("effect\\얼음결정체1.tga"), kind: 22, context: context)
        case .ef_spr_lightprint3:
            spriteRing(kind: 20, context: context)
        case .ef_waterball3:
            waterBallBurst(context: context)
        case .ef_heal_n2:
            if stateCnt >= 4 && stateCnt <= 52, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(55.0 / 255.0, 1.0, 55.0 / 255.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
            bubbleFanSweep(rising: 1, context: context)
        case .ef_rain_particle2:
            if stateCnt == 1 {
                context.world.playSound(
                    named: K2L("effect\\매직 크래쉬.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedFloatingDust(texturePath: "effect\\stone_part.bmp", context: context)
        case .ef_cloud9:
            for _ in 0..<65 {
                skyCloud(kind: 9, context: context)
            }
        case .ef_yellowfly3:
            whiteLightSparkle(kind: 2, context: context)
        case .ef_el_gust:
            texturedClassChange(kind: 70, context: context)
        case .ef_el_blast:
            texturedClassChange(kind: 71, context: context)
        case .ef_el_aquaplay:
            texturedClassChange(kind: 72, context: context)
        case .ef_el_upheaval:
            texturedClassChange(kind: 73, context: context)
        case .ef_el_wild_storm:
            texturedClassChange(kind: 74, context: context)
        case .ef_el_chilly_air:
            texturedClassChange(kind: 75, context: context)
        case .ef_el_cursed_soil:
            texturedClassChange(kind: 76, context: context)
        case .ef_el_cooler:
            texturedClassChange(kind: 77, context: context)
        case .ef_el_tropic:
            texturedClassChange(kind: 78, context: context)
        case .ef_el_pyrotechnic:
            texturedClassChange(kind: 79, context: context)
        case .ef_el_petrology:
            texturedClassChange(kind: 80, context: context)
        case .ef_el_heater:
            texturedClassChange(kind: 81, context: context)
        case .ef_silent_breeze:
            texturedClassChange(kind: 82, context: context)
        case .ef_magma_flow:
            texturedClassChange(kind: 83, context: context)
        case .ef_graybody:
            if let targetID = targetObjectID ?? ownerObjectID {
                let gray: Float = 105.0 / 255.0
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(gray, gray, gray, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_chemical_allrange:
            texturedSpinShards(texturePath: "effect\\melody_a.bmp", kind: 1, context: context)
            texturedSpinShards(texturePath: "effect\\melody_b.bmp", kind: 1, context: context)
            texturedSpinShards(texturePath: "effect\\melody_a.bmp", kind: 1, context: context)
            texturedSpinShards(texturePath: "effect\\melody_b.bmp", kind: 1, context: context)
        case .ef_tetra_fire, .ef_tetra_water, .ef_tetra_wind, .ef_tetra_ground:
            if stateCnt == 0 || stateCnt == 40 || stateCnt == 80 {
                context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
            }
            tetraVortexPillar(kind: 4, context: context)
            for _ in 0..<7 {
                texturedSpread(texturePath: "effect\\ring_red.tga", kind: 10, context: context)
            }
        default:
            return false
        }
        return true
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

    // MARK: - EF_SPR_LIGHTPRINT (901, 923, 941)

    /// Spawns 8-way orbiting sprite ring (`167`) across ticks `0...1` for `EF_SPR_LIGHTPRINT...3`.
    func spriteRing(kind: Int8, context: EffectTickContext) {
        guard stateCnt <= 1 else {
            return
        }

        let spriteBase = kind == 20 ? "m_ef05" : "m_ef03"
        let spritePath = K2L("이팩트\\\(spriteBase).spr")
        let actionPath = K2L("이팩트\\\(spriteBase).act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let primitive = launchPrimitive(167)
        primitive.state.duration = duration
        primitive.state.deltaPos2.y = 0
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.pattern |= 0x200
        primitive.state.repeatAnim = false
        primitive.state.animSpeed = 4
        primitive.state.spritePath = spritePath
        primitive.state.actionPath = actionPath

        let radius: Float = 5.0
        for i in 0..<4 {
            let rotStart = Int16((stateCnt * 4 + i) * 45)
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].rotStart = rotStart
            primitive.state.slots[i].height[0] = 0.3
            primitive.state.slots[i].vecBNow = SIMD3<Float>(
                EffectSpace.cosine(degrees: Int(rotStart)) * radius,
                -5.0,
                EffectSpace.sine(degrees: Int(rotStart)) * radius
            )
            if kind == 9 {
                primitive.state.slots[i].flag1[0] = 0
            } else if kind == 10 {
                primitive.state.slots[i].flag1[0] = 1
            } else if kind == 20 {
                primitive.state.slots[i].flag1[0] = 4
            }
        }

        primitive.initSegment()
    }

    // MARK: - EF_GREENCASTING (911)

    /// Plays cast audio and spawns dual sized white rings on tick 0 for `EF_GREENCASTING` (911).
    func whiteSpellRings(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_BeginSpell.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
        texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 15, context: context)
        texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_white.tga", kind: 15, context: context)
    }

    // MARK: - EF_FIREBALL5 (913)

    /// Emits 3 pale blue-white directional fireball volleys (`PP_3DPARTICLE` (5)) for `EF_FIREBALL5` (913).
    func paleFireballVolley(context: EffectTickContext) {
        if stateCnt == 5 {
            context.world.playSound(
                named: "effect\\EF_FireBall.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        func launchVolley(turn: Float, shade: Int, fade: Int) {
            let spritePath = K2L("이팩트\\fireball.spr")
            let actionPath = K2L("이팩트\\fireball.act")
            _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

            let primitive = launchPrimitive(.pp_3dparticle)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = 20
            primitive.state.pattern |= 0x120
            primitive.state.deltaPos2 = SIMD3<Float>(0, -15.0, 0)

            var face = Self.effectHeading(fromX: position.x, fromZ: position.z, toX: deltaPos.x, toZ: deltaPos.z)
            if turn != 0 {
                face += turn
                if face < 0 {
                    face += 360.0
                }
                if face >= 360.0 {
                    face -= 360.0
                }
            }

            primitive.state.longitude = -face
            var renderAngle = 180.0 - face
            if renderAngle < 0 {
                renderAngle += 360.0
            }
            primitive.angle = renderAngle

            let dist = Self.effectDistanceXZ(from: position, to: deltaPos)
            primitive.state.speed = -(dist / Float(primitive.state.duration))
            primitive.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(primitive.state.longitude)))
            primitive.state.size = 1.0
            primitive.state.animSpeed = 1
            primitive.state.red = shade
            primitive.state.green = shade
            primitive.state.blue = 255
            primitive.state.alpha = Float((fade - stateCnt) * 40)
            primitive.state.spritePath = spritePath
            primitive.state.actionPath = actionPath
            primitive.initSegment()
        }

        if stateCnt >= 0 && stateCnt <= 3 {
            launchVolley(turn: 0, shade: 155, fade: 5)
        } else if stateCnt >= 6 && stateCnt <= 9 {
            launchVolley(turn: -5.0, shade: 130, fade: 11)
        } else if stateCnt >= 12 && stateCnt <= 15 {
            launchVolley(turn: 5.0, shade: 105, fade: 17)
        }
    }

    // MARK: - EF_FIREBALL6 (935)

    /// Spawns green-tinted directional rocket-punch volleys (`PP_3DPARTICLE` (5)) on ticks 0, 2, 4, 6 for `EF_FIREBALL6` (935).
    func greenRocketPunch(context: EffectTickContext) {
        guard stateCnt == 0 || stateCnt == 2 || stateCnt == 4 || stateCnt == 6 else {
            return
        }

        let spritePath = K2L("이팩트\\남_로켓트펀치.spr")
        let actionPath = K2L("이팩트\\남_로켓트펀치.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let primitive = launchPrimitive(.pp_3dparticle)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = 20
        primitive.state.pattern |= 0x100
        primitive.state.deltaPos2 = SIMD3<Float>(0, -15.0, 0)

        var face = Self.effectHeading(fromX: position.x, fromZ: position.z, toX: deltaPos.x, toZ: deltaPos.z)
        primitive.state.longitude = -face
        if face < 0 {
            face += 360.0
        }
        primitive.angle = face

        let dist = Self.effectDistanceXZ(from: position, to: deltaPos)
        primitive.state.speed = -(dist / Float(primitive.state.duration))
        primitive.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(primitive.state.longitude)))
        primitive.state.size = 1.0
        primitive.state.animSpeed = 1
        if stateCnt == 0 {
            primitive.state.pattern |= 0x200
        }
        primitive.state.red = 105
        primitive.state.green = 255
        primitive.state.blue = 105
        primitive.state.alpha = Float((5 - stateCnt) * 40)
        primitive.state.spritePath = spritePath
        primitive.state.actionPath = actionPath

        let rawAngle = Int(EffectPrimitive.angle(dx: position.x - deltaPos.x, dy: position.z - deltaPos.z))
        var angle = (Int(context.world.cameraYawDegrees) + rawAngle) % 360
        if angle < 0 {
            angle += 360
        }

        let actionIndex: Int = if angle >= 180 && angle < 270 {
            4
        } else if angle >= 90 && angle < 180 {
            6
        } else if angle >= 0 && angle < 90 {
            0
        } else {
            2
        }
        primitive.previousAnimation = actionIndex
        primitive.currentMotion = 0
        primitive.initSegment()
    }

    // MARK: - EF_BOTTOM_DE2 (939)

    /// Spawns 4-ring expanding ground bands (`169`) across ticks `0...3` for `EF_BOTTOM_DE2` (939).
    func texturedGroundRing(texturePath: String, flag: Int8, context: EffectTickContext) {
        guard stateCnt <= 3 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(169)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = Float(flag)

        let baseOffsets: [(maxHeight: Float, offset: Float, subtractJitter: Bool)] = [
            (15.0, 0.5, true),
            (16.0, 1.0, false),
            (17.0, 1.5, true),
            (18.0, 2.0, false),
        ]

        for (index, config) in baseOffsets.enumerated() {
            let baseDistance = Float(stateCnt * 2) + config.offset
            let jitter = Float(Int.random(in: 0..<21)) * 0.1
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = config.maxHeight
            primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<100))
            primitive.state.slots[index].vecTNow.x = baseDistance
            primitive.state.slots[index].distance = config.subtractJitter ? (baseDistance - jitter) : (baseDistance + jitter)
            primitive.state.slots[index].riseAngle = 80
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
    }

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

    // MARK: - EF_CHEMICAL_ALLRANGE (969)

    /// Spawns 4-slot spinning melody shards (`170`) on ticks 0, 10, 20 for `EF_CHEMICAL_ALLRANGE` (969).
    func texturedSpinShards(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt < 30, stateCnt % 10 == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(170)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let riseAngle = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z)
        for i in 0..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].maxHeight = Float(Int.random(in: 0..<21)) * 0.001 + 0.4
            if kind == 3 {
                primitive.state.slots[i].distance = Float(Int.random(in: 0..<41)) * 0.1 + 1.0
            } else {
                primitive.state.slots[i].distance = Float(Int.random(in: 0..<21)) * 0.1 + 3.0
            }
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].riseAngle = riseAngle
            primitive.state.slots[i].vecBPre = SIMD3<Float>(0, -5.0, 0)
            primitive.state.slots[i].vecBNow = SIMD3<Float>(0, -5.0, 0)
            primitive.state.slots[i].height[0] = Float(riseAngle)
            primitive.state.slots[i].height[1] = Float(Int(riseAngle) + Int.random(in: 0..<360))
            primitive.state.slots[i].height[2] = Float(Int(riseAngle) + Int.random(in: 0..<360))
            primitive.state.slots[i].height[3] = 180.0
            primitive.state.slots[i].height[4] = 180.0
            primitive.state.slots[i].height[12] = 0
            primitive.state.slots[i].height[5] = Float(riseAngle)
            primitive.state.slots[i].height[6] = Float(Int(riseAngle) + Int.random(in: 0..<360))
            primitive.state.slots[i].height[7] = Float(Int(riseAngle) + Int.random(in: 0..<360))
            primitive.state.slots[i].height[8] = 180.0
            primitive.state.slots[i].height[9] = 180.0
            for j in 0..<10 {
                if primitive.state.slots[i].height[j] < 0 {
                    primitive.state.slots[i].height[j] += 360.0
                }
                if primitive.state.slots[i].height[j] >= 360.0 {
                    primitive.state.slots[i].height[j] -= 360.0
                }
            }
            primitive.state.slots[i].height[13] = 0
            primitive.state.slots[i].flag1[0] = kind
        }
    }
}
