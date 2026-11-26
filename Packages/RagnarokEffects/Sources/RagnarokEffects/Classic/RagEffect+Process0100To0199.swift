//
//  RagEffect+Process0100To0199.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs0100To0199: [EffectID] = [
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
        .ef_overthrust,
        .ef_twohandquicken,
        .ef_grimtoothatk,
        .ef_bottom2,
        .ef_firepillaron,
        .ef_revive,
        .ef_heavensdrive,
        .ef_toprank,
        .ef_party,
        .ef_rain,
        .ef_snow,
        .ef_sakura,
        .ef_status_state,
        .ef_banjjakii,
        .ef_makeblur,
        .ef_cartrevolution,
        .ef_venomdust2,
        .ef_changedark,
        .ef_changefire,
        .ef_changecold,
        .ef_changewind,
        .ef_changeflame,
        .ef_changeearth,
        .ef_chaingeholy,
        .ef_changepoison,
        .ef_hitdark,
        .ef_sui_explosion,
        .ef_darkattack,
        .ef_telekhit,
    ]

    func process0100To0199(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_removetrap:
            removeTrap(context: context)
        case .ef_blastmine:
            break
        case .ef_bottom:
            bottom(context: context)
        case .ef_blitzbeat:
            blitzBeat(context: context)
        case .ef_waterball:
            waterOut(context: context)
        case .ef_waterball2:
            waterBall2(context: context)
        case .ef_fireivy:
            processFireIvy(context: context)
        case .ef_detecting:
            texturedSkillAura(type: 0, context: context)
        case .ef_cloaking:
            assassinCloaking(context: context)
        case .ef_sonicblow:
            processSonicBlow(context: context)
        case .ef_sonicblowhit:
            sonicBlowHit(context: context)
        case .ef_grimtooth:
            grimTooth(context: context)
        case .ef_enchantpoison:
            poisonAttack(flag: 0, context: context)
        case .ef_overthrust:
            stoneCurseRing(context: context)
        case .ef_twohandquicken:
            return twoHandQuicken(context: context)
        case .ef_grimtoothatk:
            grimToothAtk(context: context)
        case .ef_bottom2:
            bottom2(context: context)
        case .ef_firepillaron:
            ringStack(white: 0, context: context)
        case .ef_revive:
            processRevive(context: context)
        case .ef_heavensdrive:
            stoneSpike(context: context)
        case .ef_toprank:
            processTopRank(context: context)
        case .ef_party:
            processPartyMarker(context: context)
        case .ef_rain:
            break
        case .ef_snow:
            snow(context: context)
        case .ef_sakura:
            sakura(context: context)
        case .ef_status_state:
            statusIconColumn(context: context)
        case .ef_banjjakii:
            processBanjjakii(context: context)
        case .ef_makeblur:
            let tintRGB = deltaPos2 == .zero ? SIMD3<Float>(250, 250, 250) : deltaPos2
            spawnBlurAfterimage(tintRGB: tintRGB, context: context)
        case .ef_cartrevolution:
            return cartRevolution(context: context)
        case .ef_venomdust2:
            processVenomDust2(context: context)
        case .ef_changedark:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_black.tga", kind: 3, context: context)
            }
        case .ef_changefire:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_red.tga", kind: 3, context: context)
            }
        case .ef_changecold:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_blue.tga", kind: 3, context: context)
            }
        case .ef_changewind:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_yellow.tga", kind: 3, context: context)
            }
        case .ef_changeflame:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_jadu.tga", kind: 3, context: context)
            }
        case .ef_changeearth:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_brown.tga", kind: 3, context: context)
            }
        case .ef_chaingeholy:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_white.tga", kind: 3, context: context)
            }
        case .ef_changepoison:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_purple.tga", kind: 3, context: context)
            }
        case .ef_hitdark:
            hitDark(context: context)
        case .ef_sui_explosion:
            return processSuiExplosion(context: context)
        case .ef_darkattack:
            hitDark(context: context)
        case .ef_telekhit:
            break
        default:
            return false
        }
        return true
    }

    // MARK: - EF_REMOVETRAP (100)

    /// Spawns two bursts of 12 arching orbit sparks (`PP_3DPARTICLEORBIT` (7)) for `EF_REMOVETRAP` (100).
    func removeTrap(context: EffectTickContext) {
        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\hunter_removetrap.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        guard stateCnt == 0 || stateCnt == 7 else {
            return
        }

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        for _ in 0..<12 {
            let particle = launchPrimitive(.pp_3dparticleorbit)
            particle.state.duration = 50
            particle.state.radiusSpeed = 0.2
            particle.state.gravSpeed = -2.0
            particle.state.gravAccel = Float(Int.random(in: 0..<10)) / 1000.0 + 0.08
            particle.state.longitude = Float(Int.random(in: 0..<360))
            particle.state.size = 0.8
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(particle.state.longitude)))
            particle.state.transform = rotY
            particle.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, particle.state.radius), by: rotY)
            particle.state.fadeOutCnt = 35
            particle.state.spritePath = spritePath
            particle.state.actionPath = actionPath
            particle.initSegment()
        }
    }

    // MARK: - EF_BOTTOM (114)

    /// Spawns a four-wall ground barrier (`PP_3DTEXTURE` (15)) with `magic_violet.tga` for `EF_BOTTOM` (114).
    func bottom(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        var angle = Int(180.0 - longitude)
        if angle < 0 {
            angle += 360
        }

        let rotation = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: angle))
        duration = 9999

        let texturePath = "effect\\magic_violet.tga"
        _ = context.assets?.texture(atPath: texturePath)

        for side in stride(from: 1, through: -1, by: -2) {
            let sideZ = launchPrimitive(.pp_3dtexture)
            sideZ.state.duration = 9999
            sideZ.state.commonPattern = 1
            sideZ.state.pattern = 40
            sideZ.state.type = 50
            sideZ.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(side) * 5.0), by: rotation)
            sideZ.state.longitude = Float(angle + 90)
            sideZ.state.widthSize = 5.0
            sideZ.state.heightSize = 15.0
            sideZ.state.heightSpeed = 0.25
            sideZ.state.alpha = 0
            sideZ.state.maxAlpha = 180.0
            sideZ.state.alphaSpeed = sideZ.state.maxAlpha / 6.0
            sideZ.state.fadeOutCnt = sideZ.state.duration - 35
            sideZ.state.texturePaths = [texturePath]

            let sideX = launchPrimitive(.pp_3dtexture)
            sideX.state.duration = 9999
            sideX.state.commonPattern = 1
            sideX.state.pattern = 40
            sideX.state.type = 50
            sideX.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(Float(side) * 5.0, 0, 0), by: rotation)
            sideX.state.longitude = Float(angle)
            sideX.state.widthSize = 5.0
            sideX.state.heightSize = 15.0
            sideX.state.heightSpeed = 0.25
            sideX.state.alpha = 0
            sideX.state.maxAlpha = 180.0
            sideX.state.alphaSpeed = sideX.state.maxAlpha / 6.0
            sideX.state.fadeOutCnt = sideX.state.duration - 35
            sideX.state.texturePaths = [texturePath]
        }
    }

    // MARK: - EF_BLITZBEAT (115)

    /// Spawns radial feather streaks (`PP_3DCROSSTEXTURE` (16)) and falcon dive rings (`PP_3DCYLINDER` (13)) for `EF_BLITZBEAT` (115).
    func blitzBeat(context: EffectTickContext) {
        if stateCnt == 5 {
            context.world.playSound(
                named: "effect\\hunter_blitzbeat_1st.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        if stateCnt == 30 {
            context.world.playSound(
                named: "effect\\hunter_blitzbeat.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        if stateCnt == 0 {
            flag = 0
            let flareTex = "effect\\ac_center2.tga"
            _ = context.assets?.texture(atPath: flareTex)

            for _ in 0..<10 {
                let streak = launchPrimitive(.pp_3dcrosstexture)
                streak.state.duration = 20
                streak.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
                streak.state.longitude = longitude
                let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(streak.state.longitude)))
                streak.state.transform = rotY
                let spin = Int.random(in: 0..<360)
                let sine = EffectSpace.sine(degrees: spin)
                let cosine = EffectSpace.cosine(degrees: spin)
                streak.state.speed3d = EffectSpace.transformVector(SIMD3<Float>(0, 0, 15.0), by: rotY)
                streak.state.deltaPos += streak.state.speed3d
                streak.state.deltaPos2 = SIMD3<Float>(sine * 3.5, -7.0, cosine * -3.5)
                streak.state.speed = -1.2
                streak.state.accel = -0.1
                streak.state.widthSize = Float(Int.random(in: 0..<40) + 20) / 10.0
                streak.state.heightSize = 0.2
                streak.state.widthSpeed = 0.1
                streak.state.widthAccel = -0.01
                streak.state.alpha = 0
                streak.state.maxAlpha = 250.0
                streak.state.changePoint = 10
                streak.state.changeSpeed = -0.3
                streak.state.changeAccel = 0.001
                streak.state.alphaSpeed = streak.state.maxAlpha * 0.5
                streak.state.fadeOutCnt = streak.state.duration - 2
                streak.state.texturePaths = [flareTex]
                streak.state.slots[0].life = 0
            }
        }

        guard stateCnt > 35, stateCnt % 3 == 0, flag < count else {
            return
        }

        let greenTex = "effect\\magic_green.tga"
        _ = context.assets?.texture(atPath: greenTex)

        let driftX = Int.random(in: 0..<10)
        let driftY = Int.random(in: 0..<20)
        let ring = launchPrimitive(.pp_3dcylinder)
        ring.state.duration = 12
        ring.state.longitude = longitude
        ring.state.latitude = -90.0
        let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(ring.state.latitude)))
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(ring.state.longitude)))
        ring.state.transform = rotY * rotX
        ring.state.speed3d = EffectSpace.transformVector(SIMD3<Float>(0, -2.0, 1.0), by: ring.state.transform)
        ring.state.deltaPos += ring.state.speed3d
        ring.state.deltaPos2 = SIMD3<Float>(Float((driftX + 1) / 5), Float((driftY + 1) / 2 - 12), 0)
        ring.state.speed = 0.4
        ring.state.accel = -(ring.state.speed / Float(ring.state.duration)) * 0.5
        ring.state.outerSize = 1.5
        ring.state.innerSize = 0.5
        ring.state.heightSize = 3.5
        ring.state.fadeOutCnt = ring.state.duration - ring.state.duration / 2
        ring.state.texturePaths = [greenTex]
        flag += 1
    }

    // MARK: - EF_WATERBALL (116)

    /// Spawns an animated additive water burst quad (`PP_3DTEXTURE` (15)) for `EF_WATERBALL` (116).
    func waterOut(context: EffectTickContext) {
        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\wizard_waterball_chulung.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        guard stateCnt == 0 else {
            return
        }

        let texturePaths = [
            "effect\\water_out_a.bmp",
            "effect\\water_out_b.bmp",
            "effect\\water_out_c.bmp",
        ]
        for path in texturePaths {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(.pp_3dtexture)
        primitive.state.duration = duration
        primitive.state.pattern = 0x40 | 0x100
        primitive.state.renderFlag |= EffectPrimitiveState.RenderFlag.additive
        primitive.state.repeatAnim = true
        primitive.state.widthSize = 3.5
        primitive.state.heightSize = 3.5
        primitive.state.speed3d.y = -(25.0 / Float(primitive.state.duration))
        primitive.state.deltaPos2.y = -5.0
        primitive.state.animSpeed = 5
        primitive.state.totalTexture = 3
        primitive.state.texturePaths = texturePaths
    }

    // MARK: - EF_WATERBALL2 (117)

    /// Spawns a parabolic water orb spline (`PP_3DPARTICLESPLINE` (8)) toward the target for `EF_WATERBALL2` (117).
    func waterBall2(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\wizard_waterball_chulung.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let spritePath = K2L("이팩트\\Waterball.spr")
        let actionPath = K2L("이팩트\\Waterball.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let (origin, destination) = directionalLaunchEndpoints()
        let faceAngle = Self.effectHeading(fromX: origin.x, fromZ: origin.z, toX: destination.x, toZ: destination.z)

        let primitive = launchPrimitive(.pp_3dparticlespline)
        primitive.state.spritePath = spritePath
        primitive.state.actionPath = actionPath
        primitive.state.duration = 40
        primitive.state.deltaPos2 = SIMD3<Float>(0, -10.0, 0)
        primitive.state.radius = Self.effectDistanceXZ(from: origin, to: destination)
        primitive.state.longitude = -faceAngle
        primitive.state.speed = primitive.state.radius / Float(primitive.state.duration)
        primitive.state.gravSpeed = 3.5
        let rise = -(primitive.state.gravSpeed / Float(primitive.state.duration))
        primitive.state.gravAccel = rise + rise
        primitive.state.latiSpeed = -2.0
        let spread = -(primitive.state.latiSpeed / Float(primitive.state.duration))
        primitive.state.latiAccel = spread + spread
        primitive.state.roll = 0
        primitive.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(primitive.state.longitude)))
        let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, 1.0), by: primitive.state.transform)
        primitive.state.deltaPos3 = forward
        primitive.state.rotAxis = forward
        primitive.state.size = 0.75
        primitive.state.numSegment = 12
        primitive.initSegment()
    }

    // MARK: - EF_DETECTING (119)

    /// Spawns rising expanding glow panel (`PP_3DTEXTURE` (15)) and aura sound for `EF_DETECTING` (119).
    func texturedSkillAura(type: Int, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let soundByType: [Int: String] = [
            0: "effect\\hunter_detecting.wav",
            2: "effect\\priest_benedictio.wav",
            4: "effect\\cru_grand cross.wav",
            5: "effect\\ANALYZE.wav",
        ]
        if let soundName = soundByType[type] {
            context.world.playSound(
                named: soundName,
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        let texturePath = "effect\\fashasha.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_3dtexture)
        primitive.state.duration = 57
        primitive.state.widthSpeed = 1.5
        primitive.state.heightSpeed = 1.5
        primitive.state.widthAccel = primitive.state.widthSpeed / 14.0
        primitive.state.heightAccel = primitive.state.heightSpeed / 14.0
        primitive.state.speed3d.y = -0.5
        primitive.state.roll = 90.0

        if type == 3 || type == 6 {
            primitive.state.changePoint = 10
            primitive.state.fadeOutCnt = 30
        } else {
            primitive.state.changePoint = 17
            primitive.state.fadeOutCnt = 40
        }

        switch type {
        case 4:
            primitive.state.red = 0xFF
            primitive.state.green = 0x8C
            primitive.state.blue = 0x8C
        case 5:
            primitive.state.red = 0xD2
            primitive.state.green = 0xFA
            primitive.state.blue = 0xD2
        case 6:
            primitive.state.red = 10
            primitive.state.green = 10
            primitive.state.blue = 10
        case 7:
            primitive.state.red = 0xFA
            primitive.state.green = 0xD2
            primitive.state.blue = 0x8C
        case 8:
            primitive.state.red = 0x8C
            primitive.state.green = 0xFF
            primitive.state.blue = 0x8C
        default:
            break
        }

        primitive.state.changeWidthSpeed = 0.1
        primitive.state.changeHeightSpeed = 0.1
        primitive.state.changeWidthAccel = primitive.state.changeWidthSpeed / 30.0
        primitive.state.changeHeightAccel = primitive.state.changeHeightSpeed / 30.0
        primitive.state.deltaPos2.y = -5.0
        primitive.state.texturePaths = [texturePath]
    }

    // MARK: - EF_SONICBLOWHIT (122)

    func sonicBlowHit(context: EffectTickContext) {
        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\assasin_sonicblow.wav",
                atWorldPosition: worldPosition,
                delay: 0
            )
        }

        guard stateCnt == 0 else {
            return
        }

        let facing = Int(180.0 - longitude)
        let spreadX = Int.random(in: 0..<10)
        let spreadY = Int.random(in: 0..<20)

        let texturePath = "effect\\magic_red.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let ring = launchPrimitive(.pp_3dcylinder)
        ring.state.duration = 12
        ring.state.longitude = Float(facing < 0 ? facing + 360 : facing)
        ring.state.latitude = -90.0
        let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(ring.state.latitude)))
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(ring.state.longitude)))
        ring.state.transform = rotY * rotX
        ring.state.speed3d = EffectSpace.transformVector(SIMD3<Float>(0, -2.0, 0), by: ring.state.transform)
        ring.state.deltaPos += ring.state.speed3d
        ring.state.deltaPos2 = SIMD3<Float>(Float((spreadX + 1) / 4), Float((spreadY + 1) / 2 - 11), 0)
        ring.state.speed = 0.4
        ring.state.accel = -(ring.state.speed / Float(ring.state.duration)) * 0.5
        ring.state.outerSize = 7.0
        ring.state.innerSize = 4.0
        ring.state.heightSize = 3.5
        ring.state.fadeOutCnt = ring.state.duration - ring.state.duration / 2
        ring.state.texturePaths = [texturePath]
    }

    // MARK: - EF_GRIMTOOTH (123)

    /// Spawns ground rock spikes (`PP_3DQUADHORN` (9)) advancing toward the target for `EF_GRIMTOOTH` (123).
    func grimTooth(context: EffectTickContext) {
        let (origin, destination) = directionalLaunchEndpoints()

        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\EF_FrostDiver.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
            let faceAngle = Self.effectHeading(fromX: origin.x, fromZ: origin.z, toX: destination.x, toZ: destination.z)
            longitude = faceAngle
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(-faceAngle)))
            deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, 2.0), by: rotY)
            deltaPos3 = (origin - position) - deltaPos2
        }

        guard flag == 0 else {
            return
        }

        if stateCnt % 3 == 0 {
            if Self.effectDistanceXZ(from: position + deltaPos3, to: destination) <= 2.5 {
                flag = 1
            }

            let texturePath = "effect\\stone.bmp"
            _ = context.assets?.texture(atPath: texturePath)

            let spike = launchPrimitive(.pp_3dquadhorn)
            spike.state.pattern |= 1
            spike.state.duration = 40
            spike.state.deltaPos2 = SIMD3<Float>(0, 20.0, 0) + deltaPos3
            spike.state.size = Float(Int.random(in: 0..<40) + 60) / 100.0
            spike.state.heightSize = 10.0
            spike.state.longitude = Float(Int.random(in: 0..<360))
            spike.state.latitude = Float(Int.random(in: 0..<30) + 75)
            let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(spike.state.latitude)))
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spike.state.longitude)))
            spike.state.transform = rotY * rotX
            spike.state.rotTransform = spike.state.transform
            spike.state.speed = 3.0
            let decay = -(spike.state.speed / Float(spike.state.duration))
            spike.state.accel = decay + decay
            spike.state.chCnt = 6
            spike.state.fadeOutCnt = spike.state.duration - 10
            spike.state.texturePaths = [texturePath]
        }

        deltaPos3 -= deltaPos2
    }

    // MARK: - EF_OVERTHRUST (128)

    /// Plays Overthrust audio and spawns a 2D shockwave ring (`PP_2DCIRCLE` (4)) for `EF_OVERTHRUST` (128).
    func stoneCurseRing(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\black_overthrust.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
        duration = 9999
        context.world.playSound(
            named: "effect\\EF_StoneCurse.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = "effect\\alpha_center.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let ring = launchPrimitive(.pp_2dcircle)
        ring.state.duration = 40
        ring.state.deltaPos2.y = -20.0
        ring.state.arcAngle = 10.0
        ring.state.innerSize = 10.0
        ring.state.radiusSpeed = 7.0
        let slowdown = -(ring.state.radiusSpeed / Float(ring.state.duration + 40))
        ring.state.radiusAccel = slowdown + slowdown
        ring.state.fadeOutCnt = 0
        ring.state.texturePaths = [texturePath]
    }

    // MARK: - EF_TWOHANDQUICKEN (130)

    /// Plays Two-Hand Quicken audio on frame 0 and advances `TwoHand.str` for `EF_TWOHANDQUICKEN` (130) and `EF_SPEARQUICKEN` (250).
    func twoHandQuicken(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: "TwoHand.str")
            duration = 9999
            context.world.playSound(
                named: "effect\\knight_twohandquicken.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        return processEZ2STRRaised(context: context)
    }

    // MARK: - EF_GRIMTOOTHATK (132)

    /// Spawns 3 upright stone ambush spikes (`PP_3DQUADHORN` (9)) around the target for `EF_GRIMTOOTHATK` (132).
    func grimToothAtk(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\stone.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        duration = 1000
        let offsets: [SIMD3<Float>] = [
            SIMD3<Float>(0, 40.0, -12.0),
            SIMD3<Float>(12.0, 40.0, 6.0),
            SIMD3<Float>(-12.0, 40.0, 6.0),
        ]

        for (index, offset) in offsets.enumerated() {
            let spike = launchPrimitive(.pp_3dquadhorn)
            spike.state.pattern |= 1
            spike.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
            spike.state.duration = 1000
            spike.state.deltaPos2 = offset
            spike.state.size = 0.9
            spike.state.heightSize = 25.0
            spike.state.longitude = Float((6 - index) * 120)
            spike.state.latitude = 75.0
            let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(spike.state.latitude)))
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spike.state.longitude)))
            spike.state.transform = rotY * rotX
            spike.state.rotTransform = spike.state.transform
            spike.state.speed = 3.5
            spike.state.accel = 0.001
            spike.state.chCnt = 10
            spike.state.fadeOutCnt = spike.state.duration - 10
            spike.state.texturePaths = [texturePath]
            deltaPos3 -= spike.state.deltaPos2
        }
    }

    // MARK: - EF_BOTTOM2 (137)

    /// Spawns a four-wall ground barrier (`PP_3DTEXTURE` (15)) with `magic_green.tga` for `EF_BOTTOM2` (137).
    func bottom2(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        var angle = Int(180.0 - longitude)
        if angle < 0 {
            angle += 360
        }

        let yaw = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: angle))
        duration = 9999
        let widthSize: Float = 2.5

        let texturePath = "effect\\magic_green.tga"
        _ = context.assets?.texture(atPath: texturePath)

        for side in stride(from: 1, through: -1, by: -2) {
            let sideZ = launchPrimitive(.pp_3dtexture)
            sideZ.state.duration = 9999
            sideZ.state.commonPattern = 1
            sideZ.state.pattern = 40
            sideZ.state.type = 50
            sideZ.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, widthSize * Float(side)), by: yaw)
            sideZ.state.longitude = Float(angle + 90)
            sideZ.state.widthSize = widthSize
            sideZ.state.heightSize = 15.0
            sideZ.state.heightSpeed = 0.25
            sideZ.state.alpha = 180.0
            sideZ.state.fadeOutCnt = 9999 - 35
            sideZ.state.texturePaths = [texturePath]

            let sideX = launchPrimitive(.pp_3dtexture)
            sideX.state.duration = 9999
            sideX.state.commonPattern = 1
            sideX.state.pattern = 40
            sideX.state.type = 50
            sideX.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(widthSize * Float(side), 0, 0), by: yaw)
            sideX.state.longitude = Float(angle)
            sideX.state.widthSize = widthSize
            sideX.state.heightSize = 15.0
            sideX.state.heightSpeed = 0.25
            sideX.state.alpha = 180.0
            sideX.state.fadeOutCnt = 9999 - 35
            sideX.state.texturePaths = [texturePath]
        }
    }

    // MARK: - EF_FIREPILLARON (138)

    /// Spawns 3 concentric tall casting cylinders (`PP_3DCYLINDER` (13)) for `EF_FIREPILLARON` (138).
    func ringStack(white: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = white == 0 ? "effect\\magic_red.tga" : "effect\\ring_white.tga"
        _ = context.assets?.texture(atPath: texturePath)

        for i in 0..<3 {
            let cylinder = launchPrimitive(.pp_3dcylinder)
            cylinder.state.duration = duration
            cylinder.state.longSpeed = -3.0
            cylinder.state.outerSize = Float(i + 4)
            cylinder.state.innerSize = Float(i + 1) + 1.5
            cylinder.state.heightSize = Float((6 - 2 * i) * (4 - i) + 1) + 2.5
            cylinder.state.rollSpeed = -0.5
            cylinder.state.alpha = Float(stateCnt * -7 + 240)
            cylinder.state.texturePaths = [texturePath]
        }
    }

    // MARK: - EF_HEAVENSDRIVE (142)

    /// Spawns a 5x5 grid of erupting stone spikes (`PP_3DQUADHORN` (9)) and camera quake for `EF_HEAVENSDRIVE` (142).
    func stoneSpike(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\wizard_earthspike.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
        context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
        duration += 50

        let texturePath = "effect\\stone.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        for z in stride(from: -10, to: 15, by: 5) {
            for x in stride(from: -10, to: 15, by: 5) {
                let spike = launchPrimitive(.pp_3dquadhorn)
                spike.state.duration = Int.random(in: 0..<30) + duration - 10
                spike.state.pattern = 1 | 2
                let heightRand = Int.random(in: 0..<60)
                spike.state.deltaPos2 = SIMD3<Float>(Float(x), 10.0, Float(z))
                spike.state.size = Float(Int.random(in: 0..<50) + 300) / 100.0
                spike.state.heightSize = Float(heightRand + 1) / 10.0 + 9.0
                spike.state.longitude = Float(Int.random(in: 0..<360))
                spike.state.latitude = Float(Int.random(in: 0..<20) + 80)
                let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(spike.state.latitude)))
                let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spike.state.longitude)))
                spike.state.transform = rotY * rotX
                spike.state.rotTransform = spike.state.transform
                spike.state.changeSpeed3d.y = -1.0
                spike.state.changeAccel3d.y = -0.01
                spike.state.speed = 1.0
                spike.state.accel = 0.01
                spike.state.changePoint = 11
                spike.state.changeSpeed = -1.2
                spike.state.changeAccel = 0
                spike.state.chCnt = 14
                spike.state.texturePaths = [texturePath]
            }
        }
    }

    // MARK: - EF_SNOW (162)

    /// Spawns drifting snow sprite particles (`PP_3DPARTICLE_NOMASTER` (21)) while `duration - stateCnt > 160` for `EF_SNOW` (162).
    func snow(context: EffectTickContext) {
        guard duration - stateCnt > 160 else {
            return
        }

        let spritePath = K2L("이팩트\\ef_snow.spr")
        let actionPath = K2L("이팩트\\ef_snow.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let terrainY = context.world.terrainHeight(atEffectX: position.x, effectZ: position.z) - 100.0
        for _ in 0..<2 {
            let flake = launchPrimitive(.pp_3dparticle_nomaster)
            flake.state.orgPos = position
            flake.state.duration = 320
            let yaw = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
            let z = Float(Int.random(in: 0..<300) - 300)
            flake.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, terrainY, z), by: yaw)
            flake.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: 90))
            flake.state.speed = -0.5
            flake.state.accel = 0
            flake.state.size = Float(Int.random(in: 0..<15) + 25) / 50.0
            flake.state.rollSpeed = 0
            flake.state.alpha = 0
            flake.state.alphaSpeed = flake.state.maxAlpha / 10.0
            flake.state.fadeOutCnt = flake.state.duration - flake.state.duration / 5
            flake.state.spritePath = spritePath
            flake.state.actionPath = actionPath
            flake.initSegment()
        }
    }

    // MARK: - EF_SAKURA (163)

    /// Spawns falling cherry blossom petals (`PP_SAKURA` (40)) every other tick for `EF_SAKURA` (163).
    func sakura(context: EffectTickContext) {
        if stateCnt == 99_999_998 {
            stateCnt = 0
            duration = 99_999_999
        } else if (stateCnt & 1) != 0 || stateCnt >= 300 {
            return
        }

        let spritePath = K2L("이팩트\\sakura01.spr")
        let actionPath = K2L("이팩트\\sakura01.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let petal = launchPrimitive(.pp_sakura)
        petal.state.duration = duration
        petal.state.slots[0].life = 1
        petal.state.slots[0].maxHeight = Float(Int.random(in: 0..<2) + 2) * 0.1
        petal.state.size = Float(Int.random(in: 0..<6) + 22) / 100.0
        for h in 0..<4 {
            petal.state.slots[0].height[h] = Float(Int.random(in: 0..<360))
        }
        petal.state.slots[0].vecBPre = SIMD3<Float>(
            Float(Int.random(in: 0..<300)) + position.x - 150.0,
            position.y - 200.0,
            Float(Int.random(in: 0..<300)) + position.z - 150.0
        )
        petal.state.slots[0].flag1[0] = 0
        petal.state.alpha = 200.0
        petal.state.spritePath = spritePath
        petal.state.actionPath = actionPath
        petal.currentMotion = Int.random(in: 0..<3)
        petal.initSegment()
        for i in 1..<4 {
            petal.state.slots[i].life = 0
        }
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

    // MARK: - EF_CARTREVOLUTION (170)

    /// Spawns shockwave rings and blast spheres on ticks 7 and 20 and advances `CartRevolution.str` for `EF_CARTREVOLUTION` (170).
    func cartRevolution(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: "CartRevolution.str")
        }

        if stateCnt == 7 || stateCnt == 20 {
            context.world.playSound(
                named: "effect\\EF_MagnumBreak.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )

            let ringTex = "effect\\ring_yellow.tga"
            let blastTex = K2L("effect\\대폭발.tga")
            _ = context.assets?.texture(atPath: ringTex)
            _ = context.assets?.texture(atPath: blastTex)

            let ring = launchPrimitive(.pp_3dcircle)
            ring.state.duration = 20
            ring.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
            ring.state.maxAlpha = 180.0
            ring.state.latitude = 90.0
            ring.state.radiusSpeed = 1.75
            ring.state.radiusAccel = -(ring.state.radiusSpeed / Float(ring.state.duration)) * 0.5
            ring.state.innerSize = 5.0
            ring.state.alpha = 0
            ring.state.alphaSpeed = ring.state.maxAlpha / 15.0
            ring.state.fadeOutCnt = ring.state.duration - 15
            ring.initSegment()
            ring.state.texturePaths = [ringTex]

            let blast = launchPrimitive(.pp_3dsphere)
            blast.state.duration = 20
            blast.state.radiusSpeed = 1.35
            blast.state.radiusAccel = -(blast.state.radiusSpeed / Float(blast.state.duration)) * 0.5
            blast.state.longSpeed = 3.0
            blast.state.alpha = 0
            blast.state.maxAlpha = 240.0
            blast.state.alphaSpeed = blast.state.maxAlpha / 7.0
            blast.state.fadeOutCnt = blast.state.duration - 15
            blast.state.texturePaths = [blastTex]
        }

        if stateCnt >= 300 {
            return false
        }

        _ = processEZ2STRRaised(context: context)
        return true
    }

    // MARK: - EF_HITDARK (180)

    /// Spawns a dark impact cylinder (`PP_3DCYLINDER` (13)) and dark particle bursts (`PP_3DPARTICLE` (5), `PP_3DPARTICLEGRAVITY` (6)) for `EF_HITDARK` (180) and `EF_DARKATTACK` (184).
    func hitDark(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        var facing = Int(180.0 - longitude)
        if facing < 0 {
            facing += 360
        }

        let ringTex = "effect\\ring_blue.tga"
        _ = context.assets?.texture(atPath: ringTex)

        let cylinder = launchPrimitive(.pp_3dcylinder)
        cylinder.state.duration = 10
        cylinder.state.longitude = Float(facing)
        cylinder.state.latitude = -90.0
        let cRotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(cylinder.state.latitude)))
        let cRotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(cylinder.state.longitude)))
        cylinder.state.transform = cRotY * cRotX
        cylinder.state.deltaPos2 = SIMD3<Float>(0, -10.0, 0)
        cylinder.state.speed = 0.7
        cylinder.state.accel = -(cylinder.state.speed / Float(cylinder.state.duration)) * 0.5
        cylinder.state.outerSize = 10.0
        cylinder.state.innerSize = 5.0
        cylinder.state.heightSize = 3.5
        cylinder.state.fadeOutCnt = cylinder.state.duration - cylinder.state.duration / 2
        cylinder.state.texturePaths = [ringTex]

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        for _ in 0..<2 {
            let spark = launchPrimitive(.pp_3dparticle)
            spark.state.longitude = Float(Int.random(in: 0..<80) + (facing - 40))
            spark.state.latitude = Float(Int.random(in: 0..<100) - 50)
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spark.state.longitude)))
            let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(spark.state.latitude)))
            spark.state.transform = rotX * rotY
            let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<4) + 4)), by: spark.state.transform)
            spark.state.deltaPos3 = forward
            spark.state.deltaPos2 = SIMD3<Float>(forward.x, forward.y - 10.0, forward.z)
            spark.state.speed = Float(Int.random(in: 0..<90) + 60) / 100.0
            spark.state.duration = Int.random(in: 0..<24) + 6
            spark.state.accel = -(spark.state.speed / Float(spark.state.duration)) * 0.5
            spark.state.size = Float(Int.random(in: 0..<100) + 60) / 100.0
            spark.state.red = 20
            spark.state.green = 20
            spark.state.blue = 20
            spark.state.fadeOutCnt = 0
            spark.state.spritePath = spritePath
            spark.state.actionPath = actionPath
            spark.state.numSegment = 3
            spark.initSegment()
        }

        for _ in 0..<2 {
            let spark = launchPrimitive(.pp_3dparticlegravity)
            spark.state.longitude = Float(Int.random(in: 0..<80) + (facing + 140))
            spark.state.latitude = Float(Int.random(in: 0..<100) - 50)
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spark.state.longitude)))
            let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(spark.state.latitude)))
            let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<4) + 4)), by: rotX * rotY)
            spark.state.deltaPos3 = forward
            spark.state.deltaPos2 = SIMD3<Float>(forward.x, forward.y - 10.0, forward.z)
            spark.state.transform = rotY
            spark.state.duration = Int.random(in: 0..<24) + 6
            spark.state.speed = Float(Int.random(in: 0..<90) + 60) / 100.0
            spark.state.accel = -(spark.state.speed / Float(spark.state.duration)) * 0.5
            spark.state.gravSpeed = -Float(Int.random(in: 0..<90) + 30) / 100.0
            spark.state.gravAccel = -(spark.state.gravSpeed / Float(spark.state.duration) * 2.0)
            spark.state.size = Float(Int.random(in: 0..<100) + 60) / 100.0
            spark.state.red = 20
            spark.state.green = 20
            spark.state.blue = 20
            spark.state.fadeOutCnt = 0
            spark.state.spritePath = spritePath
            spark.state.actionPath = actionPath
            spark.state.numSegment = 3
            spark.initSegment()
        }
    }

    // MARK: - Inline OnProcess Cases (100...199)

    private func processFireIvy(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\wizard_fire_ivy.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = "effect\\fire_ivy.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let panel = launchPrimitive(.pp_3dtexture)
        panel.state.duration = duration
        panel.state.pattern = 0x40 | 0x100
        panel.state.renderFlag |= EffectPrimitiveState.RenderFlag.additive
        panel.state.widthSize = 3.5
        panel.state.heightSize = 3.5
        panel.state.speed3d.y = -(25.0 / Float(panel.state.duration))
        panel.state.deltaPos2.y = -5.0
        panel.state.texturePaths = [texturePath]
    }

    private func processSonicBlow(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_StoneCurse.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = "effect\\alpha_center.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let ring = launchPrimitive(.pp_2dcircle)
        ring.state.duration = duration
        ring.state.fadeOutCnt = 0
        ring.state.deltaPos2.y = -20.0
        ring.state.arcAngle = 10.0
        ring.state.innerSize = 10.0
        ring.state.radiusSpeed = 7.0
        ring.state.radiusAccel = -(ring.state.radiusSpeed / Float(ring.state.duration + 40)) * 2.0
        ring.state.texturePaths = [texturePath]
    }

    private func processRevive(context: EffectTickContext) {
        guard stateCnt % 25 == 0 else {
            return
        }

        let texturePath = "effect\\ring_yellow.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let cylinder = launchPrimitive(.pp_3dcylinder)
        cylinder.state.duration = 60
        cylinder.state.longSpeed = 1.5
        cylinder.state.longAccel = 0.03
        cylinder.state.outerSize = 10.5
        cylinder.state.innerSpeed = -0.12
        cylinder.state.innerAccel = 0.003
        cylinder.state.outerSpeed = -0.12
        cylinder.state.outerAccel = 0.003
        cylinder.state.innerSize = 7.5
        cylinder.state.heightSize = 7.5
        cylinder.state.alpha = 240.0
        cylinder.state.fadeOutCnt = cylinder.state.duration - cylinder.state.duration / 2

        if stateCnt == 0 {
            cylinder.state.duration = duration
            cylinder.state.innerSpeed = 0
            cylinder.state.innerAccel = 0
            cylinder.state.longSpeed = 1.5
            cylinder.state.outerSize = 11.0
            cylinder.state.innerSize = 7.5
            cylinder.state.outerSpeed = 0
            cylinder.state.outerAccel = 0
            cylinder.state.fadeOutCnt = cylinder.state.duration - cylinder.state.duration / 10
        }

        cylinder.state.texturePaths = [texturePath]
    }

    private func processTopRank(context: EffectTickContext) {
        if stateCnt == 9998 {
            stateCnt = 0
        }

        if stateCnt == 0 {
            let texturePath = "effect\\LockOn128.tga"
            _ = context.assets?.texture(atPath: texturePath)

            let badge = launchPrimitive(.pp_3dtexture)
            badge.state.duration = 9999
            badge.state.longitude = 0
            badge.state.longSpeed = 4.5
            badge.state.roll = 90.0
            badge.state.widthSize = 4.0
            badge.state.heightSize = 4.0
            if count != 11 {
                let tintChannel = max(0, (10 - Int(count)) * 25)
                badge.state.red = 250
                badge.state.blue = tintChannel
                badge.state.green = tintChannel
            } else {
                badge.state.red = 0
                badge.state.blue = 0
                badge.state.green = 250
            }
            badge.state.texturePaths = [texturePath]
        }

        position.y = context.world.terrainHeight(atEffectX: position.x, effectZ: position.z) - 2.0
    }

    private func processPartyMarker(context: EffectTickContext) {
        if stateCnt == 9998 {
            stateCnt = 0
        }

        if stateCnt == 0 {
            let texturePath = "effect\\party.tga"
            _ = context.assets?.texture(atPath: texturePath)

            let marker = launchPrimitive(.pp_3dtexture)
            marker.state.duration = 9999
            marker.state.longitude = 0
            marker.state.roll = 90.0
            marker.state.widthSize = 4.0
            marker.state.heightSize = 4.0
            marker.state.red = 50
            marker.state.blue = 253
            marker.state.green = 50
            marker.state.texturePaths = [texturePath]
        }

        position.y = context.world.terrainHeight(atEffectX: position.x, effectZ: position.z) - 2.0
    }

    private func processBanjjakii(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\크리스마스.spr")
        let actionPath = K2L("이팩트\\크리스마스.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        if param[0] <= 0 {
            param[0] = 1.0
        }
        if param[1] < 1.0 {
            param[1] = 1.0
        }

        let ornament = launchPrimitive(.pp_3dparticle)
        ornament.state.pattern |= 0x200
        ornament.state.duration = 125
        ornament.state.deltaPos2.y = -10.0
        ornament.state.animSpeed = Int(param[1])
        ornament.state.spritePath = spritePath
        ornament.state.actionPath = actionPath
        let kind = Int.random(in: 0..<10)
        ornament.state.size = kind % 3 == 1 ? 0.01 : 1.0
        ornament.currentMotion = kind / 2
        ornament.initSegment()
    }

    private func processVenomDust2(context: EffectTickContext) {
        guard stateCnt % 5 == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle3.spr")
        let actionPath = K2L("이팩트\\particle3.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let cloud = launchPrimitive(.pp_3dparticle)
        cloud.state.duration = 10
        cloud.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: 90))
        cloud.state.speed = Float(Int.random(in: 0..<20) + 20) / 80.0
        cloud.state.accel = -(cloud.state.speed / Float(cloud.state.duration)) * 0.5
        cloud.state.size = 0.8
        cloud.state.rollSpeed = 3.0
        cloud.state.alpha = 70.0
        cloud.state.alphaSpeed = cloud.state.maxAlpha / 10.0
        cloud.state.fadeOutCnt = cloud.state.duration - cloud.state.duration / 5
        cloud.state.spritePath = spritePath
        cloud.state.actionPath = actionPath
        cloud.initSegment()
    }

    private func processSuiExplosion(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: "sui_explosion.str")
            hit2(option: 1, context: context)
        } else if stateCnt == 3 || stateCnt == 7 || stateCnt == 9 {
            context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
        }

        return processEZ2STRRaised(context: context)
    }
}
