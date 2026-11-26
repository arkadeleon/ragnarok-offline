//
//  RagEffect+Process0000To0099.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs0000To0099: [EffectID] = [
        .ef_hit1,
        .ef_hit2,
        .ef_hit3,
        .ef_hit4,
        .ef_hit5,
        .ef_hit6,
        .ef_entry,
        .ef_exit,
        .ef_warp,
        .ef_enhance,
        .ef_coin,
        .ef_endure,
        .ef_beginspell,
        .ef_glasswall,
        .ef_healsp,
        .ef_soulstrike,
        .ef_bash,
        .ef_magnumbreak,
        .ef_steal,
        .ef_pattack,
        .ef_detoxication,
        .ef_sight,
        .ef_fireball,
        .ef_icearrow,
        .ef_frostdiver,
        .ef_frostdiver2,
        .ef_firearrow,
        .ef_napalmbeat,
        .ef_ruwach,
        .ef_teleportation,
        .ef_readyportal,
        .ef_portal,
        .ef_incagility,
        .ef_decagility,
        .ef_aqua,
        .ef_signum,
        .ef_blessing,
        .ef_incagidex,
        .ef_smoke,
        .ef_firefly,
        .ef_sandwind,
        .ef_torch,
        .ef_spraypond,
        .ef_firesplashhit,
        .ef_coldhit,
        .ef_poisonhit,
        .ef_beginspell2,
        .ef_beginspell3,
        .ef_beginspell4,
        .ef_beginspell5,
        .ef_beginspell6,
        .ef_beginspell7,
        .ef_lockon,
        .ef_warpzone,
        .ef_sightrasher,
        .ef_barrier,
        .ef_cone,
        .ef_sphere,
        .ef_bowlingbash,
        .ef_icewall,
        .ef_earthspike,
        .ef_spearbmr,
        .ef_pierce,
        .ef_turnundead,
        .ef_aspersio,
        .ef_stormgust,
        .ef_yufitel,
        .ef_yufitelhit,
        .ef_hasteup,
        .ef_flasher,
    ]

    func process0000To0099(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_hit1:
            hit1(context: context)
        case .ef_hit2:
            hit2(option: 0, context: context)
        case .ef_hit3:
            hit3(context: context)
        case .ef_hit4:
            hit4(context: context)
        case .ef_hit5:
            hit5(context: context)
        case .ef_hit6:
            hit6(context: context)
        case .ef_entry:
            entry(context: context)
        case .ef_exit:
            exit(context: context)
        case .ef_warp:
            warp(context: context)
        case .ef_enhance:
            enhance(context: context)
        case .ef_coin:
            return coin(context: context)
        case .ef_endure:
            endure(context: context)
        case .ef_beginspell:
            processBeginSpellTexturedRing(texturePath: "effect\\ring_yellow.tga", kind: 1, context: context)
        case .ef_glasswall:
            return glassWall(context: context)
        case .ef_healsp:
            healSP(context: context)
        case .ef_soulstrike:
            soulStrike(flag: 0, context: context)
        case .ef_bash:
            bash(context: context)
        case .ef_magnumbreak:
            magnumBreak(context: context)
        case .ef_steal:
            steal(context: context)
        case .ef_pattack:
            poisonAttack(flag: 0, context: context)
        case .ef_detoxication:
            detoxication(context: context)
        case .ef_sight:
            sight(context: context)
        case .ef_fireball:
            fireBall(context: context)
        case .ef_icearrow:
            iceArrow(context: context)
        case .ef_frostdiver:
            frostDiver(type: 0, context: context)
        case .ef_frostdiver2:
            frostDiver2(context: context)
        case .ef_firearrow:
            fireArrow(context: context)
        case .ef_napalmbeat:
            napalmFragments(context: context)
        case .ef_ruwach:
            processRuwach(context: context)
        case .ef_teleportation:
            processTeleportation(context: context)
        case .ef_readyportal:
            processReadyPortal(context: context)
        case .ef_portal:
            portal(context: context)
        case .ef_incagility:
            incAgility(context: context)
        case .ef_decagility:
            decAgility(context: context)
        case .ef_aqua:
            processAqua(context: context)
        case .ef_signum:
            return signum(context: context)
        case .ef_blessing:
            blessing(context: context)
        case .ef_incagidex:
            incAgiDex(context: context)
        case .ef_smoke:
            processSmoke(context: context)
        case .ef_firefly:
            fireSparks(context: context)
        case .ef_sandwind:
            sandScatter(context: context)
        case .ef_torch:
            processTorch(context: context)
        case .ef_spraypond:
            sprayPond(context: context)
        case .ef_firesplashhit:
            processFireSplashHit(context: context)
        case .ef_coldhit:
            coldHit(context: context)
        case .ef_poisonhit:
            processPoisonHit(context: context)
        case .ef_beginspell2:
            processBeginSpellQuadStack(texturePath: "effect\\ring_blue.tga", kind: 2, context: context)
        case .ef_beginspell3:
            processBeginSpellQuadStack(texturePath: "effect\\ring_yellow.tga", kind: 1, context: context)
        case .ef_beginspell4:
            processBeginSpellQuadStack(texturePath: "effect\\Magic_Green.tga", kind: 33, context: context)
        case .ef_beginspell5:
            processBeginSpellQuadStack(texturePath: "effect\\ring_yellow.tga", kind: 0, context: context)
        case .ef_beginspell6:
            processBeginSpellTexturedRing(texturePath: "effect\\ring_white.tga", kind: 0, context: context)
        case .ef_beginspell7:
            processBeginSpellQuadStack(texturePath: "effect\\Magic_Violet.tga", kind: 33, context: context)
        case .ef_lockon:
            lockOnMarker(context: context)
        case .ef_warpzone:
            warpZone(context: context)
        case .ef_sightrasher:
            sightrasher(context: context)
        case .ef_barrier:
            processBarrier(context: context)
        case .ef_cone:
            processCone(context: context)
        case .ef_sphere:
            sphere(context: context)
        case .ef_bowlingbash:
            bowlingBash(context: context)
        case .ef_icewall:
            iceWall(context: context)
        case .ef_earthspike:
            earthSpike(type: 0, context: context)
        case .ef_spearbmr:
            spearBmr(context: context)
        case .ef_pierce:
            ringBurstSparks(context: context)
        case .ef_turnundead:
            turnUndead(context: context)
        case .ef_aspersio:
            return aspersio(context: context)
        case .ef_stormgust:
            return stormGust(context: context)
        case .ef_yufitel:
            yufitel(flag: 0, context: context)
        case .ef_yufitelhit:
            yufitelHit(kind: 0, context: context)
        case .ef_hasteup:
            hasteUp(context: context)
        case .ef_flasher:
            flasher(context: context)
        default:
            return false
        }
        return true
    }

    // MARK: - EF_HIT1 (0)

    func hit1(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        var facing = Int(180.0 - longitude)
        if facing < 0 {
            facing += 360
        }

        let ringTexture = "effect\\ring_blue.tga"
        _ = context.assets?.texture(atPath: ringTexture)

        let ring = launchPrimitive(.pp_3dcylinder)
        ring.state.duration = 10
        ring.state.longitude = Float(facing)
        ring.state.latitude = -90.0
        let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(ring.state.latitude)))
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(ring.state.longitude)))
        ring.state.transform = rotY * rotX
        ring.state.deltaPos2 = SIMD3<Float>(0, -10.0, 0)
        ring.state.speed = 0.7
        ring.state.accel = -(ring.state.speed / Float(ring.state.duration)) * 0.5
        ring.state.outerSize = 10.0
        ring.state.innerSize = 5.0
        ring.state.heightSize = 3.5
        ring.state.fadeOutCnt = ring.state.duration - ring.state.duration / 2
        ring.state.texturePaths = [ringTexture]

        guard !context.usesMinimalEffects else {
            return
        }

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        for _ in 0..<2 {
            let spark = launchPrimitive(.pp_3dparticle)
            spark.state.longitude = Float(Int.random(in: 0..<80) + (facing - 40))
            spark.state.latitude = Float(Int.random(in: 0..<100) - 50)
            let pRotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spark.state.longitude)))
            let pRotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(spark.state.latitude)))
            spark.state.transform = pRotX * pRotY
            let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<4) + 4)), by: spark.state.transform)
            spark.state.deltaPos3 = forward
            spark.state.deltaPos2 = SIMD3<Float>(forward.x, forward.y - 10.0, forward.z)
            spark.state.speed = Float(Int.random(in: 0..<90) + 60) / 100.0
            spark.state.duration = Int.random(in: 0..<24) + 6
            spark.state.accel = -(spark.state.speed / Float(spark.state.duration)) * 0.5
            spark.state.size = Float(Int.random(in: 0..<100) + 60) / 100.0
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
            let pRotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spark.state.longitude)))
            let pRotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(spark.state.latitude)))
            spark.state.transform = pRotX * pRotY
            let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<4) + 4)), by: spark.state.transform)
            spark.state.deltaPos3 = forward
            spark.state.deltaPos2 = SIMD3<Float>(forward.x, forward.y - 10.0, forward.z)
            spark.state.transform = pRotY
            spark.state.duration = Int.random(in: 0..<24) + 6
            spark.state.speed = Float(Int.random(in: 0..<90) + 60) / 100.0
            spark.state.accel = -(spark.state.speed / Float(spark.state.duration)) * 0.5
            spark.state.gravSpeed = -Float(Int.random(in: 0..<90) + 30) / 100.0
            spark.state.gravAccel = -(spark.state.gravSpeed / Float(spark.state.duration) * 2.0)
            spark.state.size = Float(Int.random(in: 0..<100) + 60) / 100.0
            spark.state.fadeOutCnt = 0
            spark.state.spritePath = spritePath
            spark.state.actionPath = actionPath
            spark.state.numSegment = 3
            spark.initSegment()
        }
    }

    // MARK: - EF_HIT2 (1)

    func hit2(option: Int, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_hit2.wav",
            atWorldPosition: worldPosition,
            delay: 0
        )

        let lens1 = "effect\\lens1.tga"
        let lens2 = "effect\\lens2.tga"
        _ = context.assets?.texture(atPath: lens1)
        _ = context.assets?.texture(atPath: lens2)

        for index in 0..<8 {
            let degree = Float(index) * 45.0
            let primitive = launchPrimitive(.pp_2dtexture)
            primitive.state.pattern = 1
            primitive.state.duration = Int.random(in: 0..<20) + 10
            let heading = (degree - 15.0) + Float(Int.random(in: 0..<30))
            primitive.state.roll = heading
            primitive.state.longitude = heading
            primitive.state.speed = Float(Int.random(in: 0..<45) + 5) / 10.0
            primitive.state.accel = -(primitive.state.speed / Float(primitive.state.duration)) * 0.5
            primitive.state.widthSize = Float(Int.random(in: 0..<15) + 5)
            primitive.state.heightSize = Float(Int.random(in: 0..<20) + 20)
            primitive.state.widthSpeed = -(primitive.state.widthSize / Float(primitive.state.duration))
            primitive.state.heightSpeed = 1.5
            primitive.state.heightAccel = 0.25

            let spread = Float(Int.random(in: 0..<5))
            primitive.state.deltaPos2.x = EffectSpace.sine(degrees: Int(degree)) * spread
            primitive.state.deltaPos2.y = EffectSpace.cosine(degrees: Int(degree)) * -spread - 20.0

            if option != 0 {
                primitive.state.red = 120
                primitive.state.green = 120
            }

            primitive.state.alpha = 0
            primitive.state.alphaSpeed = primitive.state.maxAlpha * 0.125
            primitive.state.slots[0].life = 0
            primitive.state.texturePaths = [(index & 1) == 0 ? lens1 : lens2]
        }
    }

    // MARK: - EF_HIT3 (2)

    func hit3(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_hit3.wav",
            atWorldPosition: worldPosition,
            delay: 0
        )

        var facing = Int(180.0 - longitude)
        if facing < 0 {
            facing += 360
        }

        let texturePath = "effect\\lens2.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let smallRing = launchPrimitive(.pp_3dcylinder)
        smallRing.state.duration = 15
        smallRing.state.longitude = Float(facing)
        smallRing.state.latitude = -90.0
        let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(smallRing.state.latitude)))
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(smallRing.state.longitude)))
        smallRing.state.transform = rotY * rotX
        smallRing.state.deltaPos2 = SIMD3<Float>(0, -10.0, 0)
        smallRing.state.speed = 0.7
        smallRing.state.accel = -(smallRing.state.speed / Float(smallRing.state.duration)) * 0.5
        smallRing.state.outerSize = 1.5
        smallRing.state.innerSize = 1.5
        smallRing.state.heightSpeed = 0.5
        smallRing.state.heightAccel = 0.2
        smallRing.state.fadeOutCnt = smallRing.state.duration - smallRing.state.duration / 3
        smallRing.state.texturePaths = [texturePath]

        let wideRing = launchPrimitive(.pp_3dcylinder)
        wideRing.state.duration = 15
        wideRing.state.longitude = Float(facing)
        wideRing.state.latitude = -90.0
        wideRing.state.transform = rotY * rotX
        wideRing.state.deltaPos2 = SIMD3<Float>(0, -10.0, 0)
        wideRing.state.speed = 0.7
        wideRing.state.accel = -(wideRing.state.speed / Float(wideRing.state.duration)) * 0.5
        wideRing.state.outerSize = 4.0
        wideRing.state.innerSize = 1.5
        wideRing.state.heightSpeed = 0.25
        wideRing.state.heightAccel = 0.2
        wideRing.state.fadeOutCnt = wideRing.state.duration - wideRing.state.duration / 3
        wideRing.state.texturePaths = [texturePath]

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        for _ in 0..<8 {
            let spark = launchPrimitive(.pp_3dparticle)
            spark.state.longitude = Float(Int.random(in: 0..<80) + (facing - 40))
            spark.state.latitude = Float(Int.random(in: 0..<100) - 50)
            let pRotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spark.state.longitude)))
            let pRotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(spark.state.latitude)))
            spark.state.transform = pRotX * pRotY
            let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<4) + 4)), by: spark.state.transform)
            spark.state.deltaPos3 = forward
            spark.state.deltaPos2 = SIMD3<Float>(forward.x, forward.y - 10.0, forward.z)
            spark.state.speed = Float(Int.random(in: 0..<120) + 80) / 100.0
            spark.state.duration = Int.random(in: 0..<24) + 6
            spark.state.accel = -(spark.state.speed / Float(spark.state.duration)) * 0.5
            spark.state.size = Float(Int.random(in: 0..<100) + 60) / 100.0
            spark.state.sizeSpeed = -(spark.state.size / Float(spark.state.duration))
            spark.state.fadeOutCnt = 0
            spark.state.spritePath = spritePath
            spark.state.actionPath = actionPath
            spark.state.numSegment = 3
            spark.initSegment()
        }
    }

    // MARK: - EF_HIT4 (3)

    func hit4(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_hit4.wav",
            atWorldPosition: worldPosition,
            delay: 0
        )

        var direction = Int(180.0 - longitude)
        if direction < 0 {
            direction += 360
        }

        let texturePath = "effect\\lens2.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let ring = launchPrimitive(.pp_3dcylinder)
        ring.state.duration = 15
        ring.state.longitude = Float(direction)
        ring.state.latitude = -90.0
        let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(ring.state.latitude)))
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(ring.state.longitude)))
        ring.state.transform = rotY * rotX
        ring.state.deltaPos2 = SIMD3<Float>(0, -10.0, 0)
        ring.state.speed = 0.7
        ring.state.accel = -(ring.state.speed / Float(ring.state.duration)) * 0.5
        ring.state.outerSize = 4.0
        ring.state.innerSize = 0.5
        ring.state.heightSpeed = 0.25
        ring.state.heightAccel = 0.15
        ring.state.fadeOutCnt = ring.state.duration - ring.state.duration / 3
        ring.state.texturePaths = [texturePath]

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        for _ in 0..<5 {
            let spark = launchPrimitive(.pp_3dparticle)
            spark.state.longitude = Float(direction - 40 + Int.random(in: 0..<80))
            spark.state.latitude = Float(Int.random(in: 0..<100) - 50)
            let pRotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spark.state.longitude)))
            let pRotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(spark.state.latitude)))
            spark.state.transform = pRotX * pRotY
            let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<4) + 4)), by: spark.state.transform)
            spark.state.deltaPos3 = forward
            spark.state.deltaPos2 = SIMD3<Float>(forward.x, forward.y - 10.0, forward.z)
            spark.state.speed = Float(Int.random(in: 0..<90) + 60) / 100.0
            spark.state.duration = Int.random(in: 0..<24) + 6
            spark.state.accel = -(spark.state.speed / Float(spark.state.duration)) * 0.5
            spark.state.size = Float(Int.random(in: 0..<100) + 60) / 100.0
            spark.state.sizeSpeed = -(spark.state.size / Float(spark.state.duration))
            spark.state.fadeOutCnt = 0
            spark.state.spritePath = spritePath
            spark.state.actionPath = actionPath
            spark.state.numSegment = 3
            spark.initSegment()
        }
    }

    // MARK: - EF_HIT5 (4)

    func hit5(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_hit5.wav",
            atWorldPosition: worldPosition,
            delay: 0
        )

        let texturePath = "effect\\lens2.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let baseAngle = Int.random(in: 0..<360)
        for angle in [baseAngle, baseAngle + 90] {
            let primitive = launchPrimitive(.pp_2dtexture)
            primitive.state.duration = 17
            primitive.state.deltaPos2.y = -20.0
            primitive.state.roll = Float(angle)
            primitive.state.rollSpeed = -5.0
            primitive.state.rollAccel = -(primitive.state.rollSpeed / Float(primitive.state.duration)) / 1.5
            primitive.state.widthSize = Float(Int.random(in: 0..<5) + 20)
            primitive.state.heightSize = Float(Int.random(in: 0..<10) + 30)
            primitive.state.widthSpeed = -(primitive.state.widthSize / Float(primitive.state.duration))
            primitive.state.heightSpeed = 2.5
            primitive.state.heightAccel = 0.5
            primitive.state.fadeOutCnt = primitive.state.duration - primitive.state.duration / 2
            primitive.state.texturePaths = [texturePath]
            primitive.state.slots[0].life = 0
        }
    }

    // MARK: - EF_HIT6 (5)

    func hit6(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_hit6.wav",
            atWorldPosition: worldPosition,
            delay: 0
        )

        let texturePath = "effect\\lens2.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let baseAngle = Int.random(in: 0..<360)
        for angle in [baseAngle, baseAngle + 90] {
            let primitive = launchPrimitive(.pp_2dtexture)
            primitive.state.duration = 17
            primitive.state.deltaPos2.y = -20.0
            primitive.state.roll = Float(angle)
            primitive.state.rollSpeed = -5.0
            primitive.state.rollAccel = -(primitive.state.rollSpeed / Float(primitive.state.duration)) / 1.5
            primitive.state.widthSize = Float(Int.random(in: 0..<5) + 10)
            primitive.state.heightSize = Float(Int.random(in: 0..<5) + 15)
            primitive.state.widthSpeed = -(primitive.state.widthSize / Float(primitive.state.duration))
            primitive.state.heightSpeed = 1.7
            primitive.state.heightAccel = 0.5
            primitive.state.fadeOutCnt = primitive.state.duration - primitive.state.duration / 2
            primitive.state.texturePaths = [texturePath]
            primitive.state.slots[0].life = 0
        }
    }

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

    /// Spawns rising fade cylinder (`PP_3DCYLINDER` (13)) and orbiting sparks (`PP_3DPARTICLEORBIT` (7)) for `EF_EXIT` (7).
    func exit(context: EffectTickContext) {
        if stateCnt == 0 {
            let cylinderTex = "effect\\alpha_down.tga"
            _ = context.assets?.texture(atPath: cylinderTex)

            duration = 100
            let cylinder = launchPrimitive(.pp_3dcylinder)
            cylinder.state.duration = 100
            cylinder.state.outerSize = 4.5
            cylinder.state.innerSize = 4.5
            cylinder.state.heightSize = 35.0
            cylinder.state.alpha = 0
            cylinder.state.maxAlpha = 90.0
            cylinder.state.alphaSpeed = cylinder.state.maxAlpha / 30.0
            cylinder.state.fadeOutCnt = cylinder.state.duration - 20
            cylinder.state.texturePaths = [cylinderTex]

            context.world.playSound(
                named: "_heal_effect.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        guard !context.usesMinimalEffects else {
            return
        }

        if stateCnt % 9 == 0 {
            let spritePath = K2L("이팩트\\particle1.spr")
            let actionPath = K2L("이팩트\\particle1.act")
            _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

            let particle = launchPrimitive(.pp_3dparticleorbit)
            particle.state.radius = 3.0
            particle.state.duration = 50
            particle.state.longitude = Float(Int.random(in: 0..<360))
            particle.state.gravSpeed = -1.2
            particle.state.gravAccel = -(particle.state.gravSpeed / Float(particle.state.duration)) / 1.5
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(particle.state.longitude)))
            particle.state.transform = rotY
            particle.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, particle.state.radius), by: rotY)
            particle.state.size = 0.55
            particle.state.fadeOutCnt = particle.state.duration - particle.state.duration / 3
            particle.state.spritePath = spritePath
            particle.state.actionPath = actionPath
            particle.initSegment()
        }
    }

    // MARK: - EF_WARP (8)

    /// Spawns rising warp ring (`PP_3DCIRCLE` (12)) and orbiting sparkles (`PP_3DPARTICLEORBIT` (7)) for `EF_WARP` (8).
    func warp(context: EffectTickContext) {
        if stateCnt % 20 == 0 {
            let texturePath = "EFFECT\\RING_YELLOW.TGA"
            _ = context.assets?.texture(atPath: texturePath)

            let ring = launchPrimitive(.pp_3dcircle)
            ring.state.duration = duration
            ring.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
            ring.state.radius = 2.0
            ring.state.arcAngle = 22.5
            ring.state.innerSize = 10.0
            ring.state.latitude = 90.0
            ring.state.transform = EffectSpace.rotationX(radians: ring.state.latitude / 180.0 * .pi)
            ring.state.radiusSpeed = 1.25
            ring.state.radiusAccel = -(ring.state.radiusSpeed / Float(ring.state.duration)) * 0.5
            ring.state.alpha = 200.0
            ring.state.fadeOutCnt = ring.state.duration - ring.state.duration / 2
            ring.initSegment()
            ring.state.texturePaths = [texturePath]
        }

        if (stateCnt & 1) == 0 {
            let spritePath = K2L("이팩트\\particle1.spr")
            let actionPath = K2L("이팩트\\particle1.act")
            _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

            let particle = launchPrimitive(.pp_3dparticleorbit)
            let band = Int.random(in: 0..<200) / 100
            particle.state.radius = Float(band) * 0.7 + 1.0
            particle.state.duration = 40
            let lon = Int.random(in: 0..<360)
            let spin = Float(band) * 3.0 + 3.0
            particle.state.longitude = Float(lon)
            particle.state.longSpeed = spin
            particle.state.gravSpeed = Float(60 - Int.random(in: 0..<240)) / 100.0
            particle.state.gravAccel = -(particle.state.gravSpeed / Float(particle.state.duration)) * 0.5
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(particle.state.longitude)))
            particle.state.transform = rotY
            particle.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, particle.state.radius), by: rotY)
            particle.state.size = 0.2
            particle.state.fadeOutCnt = particle.state.duration - particle.state.duration / 3
            particle.state.spritePath = spritePath
            particle.state.actionPath = actionPath
            particle.initSegment()
        }
    }

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

    // MARK: - EF_COIN (10)

    /// Spawns bouncing coin particles (`PP_3DPARTICLEGRAVITY` (6)) and advances `Maemor.str`/`memor_min.str` for `EF_COIN` (10).
    func coin(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: context.usesMinimalEffects ? "memor_min.str" : "Maemor.str")
        }

        if !context.usesMinimalEffects && stateCnt == 20 {
            let spritePath = K2L("이팩트\\동전.spr")
            let actionPath = K2L("이팩트\\동전.act")
            _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

            for _ in 0..<5 {
                let coin = launchPrimitive(.pp_3dparticlegravity)
                coin.state.duration = Int.random(in: 0..<30) + 40
                coin.state.longitude = Float(Int.random(in: 0..<12) * 30)
                let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(coin.state.longitude)))
                let distance = Float(Int.random(in: 0..<2) + 2)
                let offset = EffectSpace.transformVector(SIMD3<Float>(0, 0, distance), by: rotY)
                coin.state.deltaPos2 = SIMD3<Float>(offset.x, offset.y - 10.0, offset.z)
                coin.state.transform = rotY
                coin.state.speed = Float(Int.random(in: 0..<50) + 50) / 100.0
                coin.state.accel = -(coin.state.speed / Float(coin.state.duration)) / 3.5
                coin.state.gravSpeed = -Float(Int.random(in: 0..<100) + 50) / 25.0
                coin.state.gravAccel = -(coin.state.gravSpeed / Float(coin.state.duration) * 4.0)
                coin.state.size = 2.0
                coin.state.fadeOutCnt = coin.state.duration - coin.state.duration / 3
                coin.state.playWaveType = 1
                coin.state.animSpeed = 1
                coin.state.spritePath = spritePath
                coin.state.actionPath = actionPath
                coin.state.numSegment = 2
                coin.initSegment()
            }
        }

        _ = processEZ2STRRaised(context: context)
        return stateCnt < 100
    }

    // MARK: - EF_ENDURE (11)

    /// Spawns endure crest (`PP_2DTEXTURE` (0)) and converging 2D energy streaks for `EF_ENDURE` (11).
    func endure(context: EffectTickContext) {
        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\EF_Endure.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )

            let bannerTex = "effect\\endure.tga"
            _ = context.assets?.texture(atPath: bannerTex)

            let banner = launchPrimitive(.pp_2dtexture)
            banner.state.duration = duration
            banner.state.pattern |= 2
            banner.state.deltaPos2.y = -20.0
            banner.state.widthSize = 150.0
            banner.state.heightSize = 150.0
            banner.state.widthSpeed = -5.0
            banner.state.heightSpeed = -5.0
            banner.state.chCnt = UInt32(max(1, banner.state.duration - 35))
            banner.state.widthAccel = -banner.state.widthSpeed / Float(Int(banner.state.chCnt))
            banner.state.heightAccel = -banner.state.heightSpeed / Float(Int(banner.state.chCnt))
            banner.state.alpha = 0
            banner.state.alphaSpeed = banner.state.maxAlpha / 20.0
            banner.state.fadeOutCnt = banner.state.duration - banner.state.duration / 3
            banner.state.texturePaths = [bannerTex]
            banner.state.slots[0].life = 0
        }

        guard stateCnt < 50 else {
            return
        }

        let streakTex = "effect\\alpha_down.tga"
        _ = context.assets?.texture(atPath: streakTex)

        let streak = launchPrimitive(.pp_2dtexture)
        streak.state.duration = 40
        let heading = Float(Int.random(in: 0..<360))
        streak.state.roll = heading
        streak.state.longitude = heading
        streak.state.speed = -4.0
        streak.state.accel = -(streak.state.speed / Float(streak.state.duration))
        streak.state.widthSize = Float(Int.random(in: 0..<100) + 60) / 100.0
        streak.state.heightSize = Float(Int.random(in: 0..<20) + 30)
        streak.state.alpha = 0
        streak.state.alphaSpeed = streak.state.maxAlpha / 20.0
        streak.state.fadeOutCnt = streak.state.duration - streak.state.duration / 3
        let radius = Float(Int.random(in: 0..<40) + 100)
        streak.state.deltaPos2.x = EffectSpace.sine(degrees: Int(heading)) * radius
        streak.state.deltaPos2.y = EffectSpace.cosine(degrees: Int(heading)) * -radius - 20.0
        streak.state.texturePaths = [streakTex]
        streak.state.slots[0].life = 0
    }

    // MARK: - EF_BEGINSPELL (12)

    /// Spawns four orbiting casting arc slots (`30`) for `EF_BEGINSPELL` (12).
    func texturedQuadRingSized(baseAlpha: Int16, texturePath: String, kind: Int, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        if duration < 56 {
            duration = 56
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(30)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]

        let sizeByKind: [Int: Float] = [
            1: 8.0, 2: 5.0, 3: 10.0, 4: 11.0, 5: 4.0, 6: 12.0, 15: 7.0,
            20: 24.0, 21: 25.0, 22: 26.0, 23: 27.0, 31: 31.0,
            42: 42.0, 43: 43.0, 44: 44.0, 45: 45.0, 46: 46.0, 47: 47.0, 48: 48.0, 49: 49.0, 50: 50.0,
        ]
        primitive.state.size = sizeByKind[kind] ?? 5.0

        let baseMaxHeight: Float = switch kind {
        case 2: 25.0
        case 22: 15.0
        default: 20.0
        }
        let rotStarts: [Int16] = [180, 270, 0, 90]
        let alphaOffsets: [Int16] = [135, 90, 45, 0]

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = duration <= 60 ? index * -5 : 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = baseMaxHeight - Float(index)
            primitive.state.slots[index].rotStart = rotStarts[index]
            primitive.state.slots[index].alphaB = duration <= 60 ? 0 : baseAlpha + alphaOffsets[index]
            primitive.state.slots[index].distance = 4.1
            primitive.state.slots[index].riseAngle = 80
            primitive.state.slots[index].alphaT = Int16(truncatingIfNeeded: kind)
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
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

    // MARK: - EF_HEALSP (14)

    /// Spawns layered blue SP cylinders (`PP_3DCYLINDER` (13)) and orbiting particles (`PP_3DPARTICLEORBIT` (7)) for `EF_HEALSP` (14).
    func healSP(context: EffectTickContext) {
        if stateCnt == 0 {
            let cylinderTex = "effect\\alpha_down.tga"
            _ = context.assets?.texture(atPath: cylinderTex)

            duration = 100
            let layers: [(size: Float, height: Float, maxAlpha: Float)] = [
                (2.5, 15.0, 16.0),
                (3.5, 25.0, 32.0),
                (4.5, 35.0, 64.0),
            ]
            for layer in layers {
                let cylinder = launchPrimitive(.pp_3dcylinder)
                cylinder.state.duration = duration
                cylinder.state.longSpeed = 5.0
                cylinder.state.outerSize = layer.size
                cylinder.state.innerSize = layer.size
                cylinder.state.heightSize = layer.height
                cylinder.state.red = 0x20
                cylinder.state.green = 0xB0
                cylinder.state.blue = 0xE8
                cylinder.state.alpha = 0
                cylinder.state.maxAlpha = layer.maxAlpha
                cylinder.state.alphaSpeed = layer.maxAlpha / 30.0
                cylinder.state.fadeOutCnt = cylinder.state.duration - 20
                cylinder.state.texturePaths = [cylinderTex]
            }

            context.world.playSound(
                named: "_heal_effect.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        if (stateCnt & 1) == 0 {
            let spritePath = K2L("이팩트\\particle2.spr")
            let actionPath = K2L("이팩트\\particle2.act")
            _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

            let particle = launchPrimitive(.pp_3dparticleorbit)
            particle.state.radius = 3.0
            particle.state.duration = 30
            particle.state.longitude = Float(Int.random(in: 0..<360))
            particle.state.gravSpeed = -1.2
            particle.state.gravAccel = -(particle.state.gravSpeed / Float(particle.state.duration)) / 1.5
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(particle.state.longitude)))
            particle.state.transform = rotY
            particle.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, particle.state.radius), by: rotY)
            particle.state.size = 0.55
            particle.state.fadeOutCnt = particle.state.duration - particle.state.duration / 3
            particle.state.spritePath = spritePath
            particle.state.actionPath = actionPath
            particle.initSegment()
        }
    }

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

    /// Spawns shockwave rings (`PP_3DCIRCLE` (12)) and central explosion sphere (`PP_3DSPHERE` (14)) for `EF_MAGNUMBREAK` (17).
    func magnumBreak(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_MagnumBreak.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let ringTex = "effect\\ring_yellow.tga"
        let blastTex = K2L("effect\\대폭발.tga")
        _ = context.assets?.texture(atPath: ringTex)
        _ = context.assets?.texture(atPath: blastTex)

        for ringDuration in [duration, 30] {
            let ring = launchPrimitive(.pp_3dcircle)
            ring.state.duration = ringDuration
            ring.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
            ring.state.latitude = 90.0
            ring.state.radiusSpeed = 1.75
            ring.state.radiusAccel = -(ring.state.radiusSpeed / Float(ring.state.duration)) * 0.5
            ring.state.innerSize = 12.0
            ring.state.alpha = 0
            ring.state.alphaSpeed = ring.state.maxAlpha / 15.0
            ring.state.fadeOutCnt = ring.state.duration - 15
            ring.initSegment()
            ring.state.texturePaths = [ringTex]
        }

        let blast = launchPrimitive(.pp_3dsphere)
        blast.state.duration = duration
        blast.state.radiusSpeed = 1.15
        blast.state.radiusAccel = -(blast.state.radiusSpeed / Float(blast.state.duration)) * 0.5
        blast.state.longSpeed = 3.0
        blast.state.alpha = 0
        blast.state.alphaSpeed = blast.state.maxAlpha / 15.0
        blast.state.fadeOutCnt = blast.state.duration - 15
        blast.state.texturePaths = [blastTex]
    }

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

    /// Spawns rising venom clouds (`PP_3DPARTICLE` (5)) and audio for `EF_PATTACK` (20) / `EF_ENCHANTPOISON` (125).
    func poisonAttack(flag: Int8, context: EffectTickContext) {
        if stateCnt == 0 && flag == 0 {
            context.world.playSound(
                named: "effect\\assasin_enchantpoison.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
            context.world.playSound(
                named: "effect\\EF_PoisonAttack.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        } else if flag == 1 {
            guard stateCnt % 9 == 0 else {
                return
            }

            let spritePath = K2L("이팩트\\particle3.spr")
            let actionPath = K2L("이팩트\\particle3.act")
            _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

            let particle = launchPrimitive(.pp_3dparticle)
            particle.state.duration = 40
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
            particle.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<6) + 2)), by: rotY)
            particle.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: 90))
            particle.state.speed = Float(Int.random(in: 0..<30) + 30) / 100.0
            particle.state.accel = -(particle.state.speed / Float(particle.state.duration)) * 0.5
            particle.state.size = Float(Int.random(in: 0..<50) + 40) / 170.0
            particle.state.rollSpeed = 3.0
            particle.state.alpha = 0
            particle.state.alphaSpeed = particle.state.maxAlpha / 10.0
            particle.state.fadeOutCnt = particle.state.duration - particle.state.duration / 5
            particle.state.spritePath = spritePath
            particle.state.actionPath = actionPath
            particle.initSegment()
            return
        }

        guard stateCnt % 5 == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle3.spr")
        let actionPath = K2L("이팩트\\particle3.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let particle = launchPrimitive(.pp_3dparticle)
        particle.state.duration = 40
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
        particle.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<6) + 2)), by: rotY)
        particle.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: 90))
        particle.state.speed = Float(Int.random(in: 0..<30) + 30) / 100.0
        particle.state.accel = -(particle.state.speed / Float(particle.state.duration)) * 0.5
        particle.state.size = Float(Int.random(in: 0..<50) + 40) / 100.0
        particle.state.rollSpeed = 3.0
        particle.state.alpha = 0
        particle.state.alphaSpeed = particle.state.maxAlpha / 10.0
        particle.state.fadeOutCnt = particle.state.duration - particle.state.duration / 5
        particle.state.spritePath = spritePath
        particle.state.actionPath = actionPath
        particle.initSegment()
    }

    // MARK: - EF_DETOXICATION (21)

    /// Spawns rising detoxifying mist (`PP_3DPARTICLE` (5)) for `EF_DETOXICATION` (21).
    func detoxication(context: EffectTickContext) {
        let interval = context.usesMinimalEffects ? 15 : 5
        guard stateCnt % interval == 0 else {
            return
        }

        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\EF_Detoxication.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        let spritePath = K2L("이팩트\\particle2.spr")
        let actionPath = K2L("이팩트\\particle2.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let particle = launchPrimitive(.pp_3dparticle)
        particle.state.alpha = 0
        particle.state.duration = 40
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
        particle.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<6) + 2)), by: rotY)
        particle.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: 90))
        particle.state.speed = Float(Int.random(in: 0..<30) + 30) / 100.0
        particle.state.accel = -(particle.state.speed / Float(particle.state.duration)) * 0.5
        particle.state.size = Float(Int.random(in: 0..<50) + 40) / 100.0
        particle.state.rollSpeed = 3.0
        particle.state.alphaSpeed = particle.state.maxAlpha / 10.0
        particle.state.fadeOutCnt = particle.state.duration - particle.state.duration / 5
        particle.state.spritePath = spritePath
        particle.state.actionPath = actionPath
        particle.initSegment()
    }

    // MARK: - EF_SIGHT (22)

    /// Spawns orbiting Sight flames and ground shadows (`PP_3DPARTICLE` (5)) for `EF_SIGHT` (22).
    func sight(context: EffectTickContext) {
        guard (stateCnt & 1) == 0 else {
            return
        }

        let sightSprite = K2L("이팩트\\Sight.spr")
        let sightAction = K2L("이팩트\\Sight.act")
        let shadowSprite = "Shadow.spr"
        let shadowAction = "Shadow.act"
        _ = context.assets?.spriteAsset(spritePath: sightSprite, actionPath: sightAction)
        _ = context.assets?.spriteAsset(spritePath: shadowSprite, actionPath: shadowAction)

        let angle = Int(Float(stateCnt) * -5.0)
        let sine = EffectSpace.sine(degrees: angle)
        let cosine = EffectSpace.cosine(degrees: angle)
        let radius: Float = 15.0

        let flame = launchPrimitive(.pp_3dparticle)
        flame.state.duration = 20
        flame.state.deltaPos2 = SIMD3<Float>(radius * sine, -20.0, -radius * cosine)
        flame.state.deltaPosAccel.y = 0.1
        flame.state.animSpeed = 3
        flame.state.size = 2.5
        flame.state.sizeSpeed = -0.1
        flame.state.alpha = 150.0
        flame.state.alphaSpeed = -3.0
        flame.state.spritePath = sightSprite
        flame.state.actionPath = sightAction
        flame.initSegment()

        let shadow = launchPrimitive(.pp_3dparticle)
        shadow.state.duration = 20
        shadow.state.deltaPos2 = SIMD3<Float>(radius * sine, 0, -radius * cosine)
        shadow.state.animSpeed = 2
        shadow.state.size = 1.5
        shadow.state.sizeSpeed = -0.06
        shadow.state.alpha = 120.0
        shadow.state.alphaSpeed = -1.0
        shadow.state.spritePath = shadowSprite
        shadow.state.actionPath = shadowAction
        shadow.initSegment()
    }

    // MARK: - EF_FIREBALL (24)

    /// Spawns four staggered fireballs (`PP_3DPARTICLE` (5)) toward the target for `EF_FIREBALL` (24).
    func fireBall(context: EffectTickContext) {
        guard stateCnt == 20 || stateCnt == 24 || stateCnt == 28 || stateCnt == 32 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_FireBall.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let spritePath = K2L("이팩트\\fireball.spr")
        let actionPath = K2L("이팩트\\fireball.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let (origin, destination) = directionalLaunchEndpoints()
        let faceAngle = Self.effectHeading(fromX: origin.x, fromZ: origin.z, toX: destination.x, toZ: destination.z)

        let primitive = launchPrimitive(.pp_3dparticle)
        primitive.state.duration = 20
        primitive.state.pattern |= 0x120
        primitive.state.deltaPos2 = SIMD3<Float>(0, -15.0, 0)
        primitive.state.longitude = -faceAngle
        primitive.state.speed = -(Self.effectDistanceXZ(from: origin, to: destination) / Float(primitive.state.duration))
        primitive.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(primitive.state.longitude)))
        primitive.state.size = 1.3
        primitive.state.animSpeed = 1

        if stateCnt != 20 {
            primitive.state.red = 246
            primitive.state.green = 199
            primitive.state.blue = 76
            if stateCnt == 24 {
                primitive.state.alpha = 180.0
            } else if stateCnt == 28 {
                primitive.state.alpha = 130.0
            } else {
                primitive.state.alpha = 80.0
            }
        }

        primitive.state.spritePath = spritePath
        primitive.state.actionPath = actionPath
        primitive.initSegment()
    }

    // MARK: - EF_ICEARROW (26)

    /// Spawns falling ice bolts (`PP_3DCROSSTEXTURE` (16)) and impact rings (`PP_3DCIRCLE` (12)) for `EF_ICEARROW` (26).
    func iceArrow(context: EffectTickContext) {
        if stateCnt == 12 {
            let variant = Int.random(in: 0..<3) + 1
            context.world.playSound(
                named: "effect\\EF_IceArrow\(variant).wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
            count *= 10
        }

        if stateCnt >= 12 {
            let frameOffset = stateCnt - 12
            let interval = 10
            if frameOffset % interval == 0 && frameOffset < count {
                let texturePath = "effect\\icearrow.tga"
                _ = context.assets?.texture(atPath: texturePath)

                let arrow = launchPrimitive(.pp_3dcrosstexture)
                arrow.state.duration = 70
                arrow.state.pattern = 20
                let spreadZ = Int.random(in: 0..<interval)
                let spreadX = Int.random(in: 0..<interval)
                arrow.state.deltaPos2 = SIMD3<Float>(
                    Float(spreadX + 25),
                    -60.0,
                    Float(spreadZ + 15)
                )

                let angleY = -Self.effectHeading(
                    fromX: arrow.state.deltaPos2.x,
                    fromZ: arrow.state.deltaPos2.z,
                    toX: Float(Int.random(in: 0..<4) - 2),
                    toZ: Float(Int.random(in: 0..<4) - 2)
                )
                arrow.state.longitude = angleY
                longitude = angleY

                let dx = fabsf(arrow.state.deltaPos2.x)
                let dz = fabsf(arrow.state.deltaPos2.z)
                let distXZ = sqrtf(dx * dx + dz * dz)
                let angleX = Self.effectHeading(fromX: -fabsf(arrow.state.deltaPos2.y), fromZ: distXZ, toX: 0, toZ: 0)
                arrow.state.latitude = angleX
                latitude = angleX

                let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(arrow.state.latitude)))
                let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(arrow.state.longitude)))
                arrow.state.transform = rotY * rotX

                arrow.state.speed = -2.75
                arrow.state.widthSize = 11.5
                arrow.state.heightSize = 3.8
                arrow.state.fadeOutCnt = arrow.state.duration - 20
                arrow.state.texturePaths = [texturePath]
                arrow.state.slots[0].life = 0
            }
        }

        if flag != 0 {
            flag = 0
            let ringTex = "effect\\ring_blue.tga"
            _ = context.assets?.texture(atPath: ringTex)

            let ring = launchPrimitive(.pp_3dcircle)
            ring.state.duration = 30
            ring.state.latitude = 90.0
            ring.state.radiusSpeed = 1.2
            let accel = -(ring.state.radiusSpeed / Float(ring.state.duration + 40))
            ring.state.radiusAccel = accel + accel
            ring.state.innerSize = 10.0
            ring.state.alpha = 0
            ring.state.alphaSpeed = ring.state.maxAlpha / 10.0
            ring.state.fadeOutCnt = ring.state.duration - 10
            ring.initSegment()
            ring.state.texturePaths = [ringTex]
        }
    }

    // MARK: - EF_FROSTDIVER (27)

    /// Spawns a traveling trail of ice horns (`PP_3DQUADHORN` (9)) toward the target for `EF_FROSTDIVER` (27).
    func frostDiver(type: Int8, context: EffectTickContext) {
        guard !context.usesMinimalEffects else {
            return
        }

        let (origin, destination) = directionalLaunchEndpoints()

        if stateCnt == 0 {
            let faceAngle = Self.effectHeading(fromX: origin.x, fromZ: origin.z, toX: destination.x, toZ: destination.z)
            longitude = faceAngle
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(-faceAngle)))
            let reach = EffectSpace.transformVector(SIMD3<Float>(0, 0, 5.0), by: rotY)
            deltaPos3 = (origin - position) - reach
            deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, 2.0), by: rotY)
        }

        guard flag == 0 else {
            return
        }

        if Self.effectDistanceXZ(from: position + deltaPos3, to: destination) <= 2.5 {
            flag = 1
        }

        let texturePath = "effect\\ice.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_3dquadhorn)
        primitive.state.duration = 40
        primitive.state.pattern |= 1
        primitive.state.slots[0].flag1[0] = type == 3 ? 3 : 0
        let angle = Int.random(in: 0..<360)
        let distance = Float(Int.random(in: 0..<10) + 5) / 10.0
        primitive.state.deltaPos2 = SIMD3<Float>(
            EffectSpace.sine(degrees: angle) * distance,
            30.0,
            -distance * EffectSpace.cosine(degrees: angle)
        ) + deltaPos3
        primitive.state.size = Float(Int.random(in: 0..<40) + 60) / 100.0
        primitive.state.heightSize = Float(Int.random(in: 0..<30) + 150) / 10.0
        primitive.state.longitude = Float(Int.random(in: 0..<360))
        primitive.state.latitude = Float(Int.random(in: 0..<30) + 75)
        let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(primitive.state.latitude)))
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(primitive.state.longitude)))
        primitive.state.transform = rotY * rotX
        primitive.state.rotTransform = primitive.state.transform
        primitive.state.speed = 3.0
        let decay = -(primitive.state.speed / Float(primitive.state.duration))
        primitive.state.accel = decay + decay
        primitive.state.chCnt = 20
        primitive.state.fadeOutCnt = primitive.state.duration - 10
        primitive.state.texturePaths = [texturePath]

        deltaPos3 -= deltaPos2
    }

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

    /// Spawns falling flame arrows (`PP_3DCROSSTEXTURE` (16)), ember trails (`PP_3DPARTICLE` (5)), and impact rings for `EF_FIREARROW` (31).
    func fireArrow(context: EffectTickContext) {
        if stateCnt == 12 {
            let variant = Int.random(in: 0..<3) + 1
            context.world.playSound(
                named: "effect\\EF_FireArrow\(variant).wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
            count *= 10
        }

        if stateCnt >= 12 {
            let frameOffset = stateCnt - 12
            if frameOffset % 10 == 0 && frameOffset < count {
                let arrowTextures = (1...6).map { K2L("effect\\불화살\($0).tga") }
                for path in arrowTextures {
                    _ = context.assets?.texture(atPath: path)
                }

                let arrow = launchPrimitive(.pp_3dcrosstexture)
                arrow.state.duration = 70
                arrow.state.pattern = 0x14
                let spreadZ = Int.random(in: 0..<10)
                let spreadX = Int.random(in: 0..<10)
                arrow.state.deltaPos2 = SIMD3<Float>(
                    Float(spreadX + 25),
                    -60.0,
                    Float(spreadZ + 15)
                )
                let heading = Self.effectHeading(
                    fromX: arrow.state.deltaPos2.x,
                    fromZ: arrow.state.deltaPos2.z,
                    toX: Float(Int.random(in: 0..<4) - 2),
                    toZ: Float(Int.random(in: 0..<4) - 2)
                )
                arrow.state.longitude = -heading
                longitude = -heading
                let dx = fabsf(arrow.state.deltaPos2.x)
                let dz = fabsf(arrow.state.deltaPos2.z)
                let run = sqrtf(dx * dx + dz * dz)
                let pitch = Self.effectHeading(fromX: -fabsf(arrow.state.deltaPos2.y), fromZ: run, toX: 0, toZ: 0)
                arrow.state.latitude = pitch
                latitude = pitch

                let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(arrow.state.latitude)))
                let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(arrow.state.longitude)))
                arrow.state.transform = rotY * rotX
                arrow.state.speed = -2.75
                arrow.state.widthSize = 14.0
                arrow.state.heightSize = 3.5
                arrow.state.fadeOutCnt = arrow.state.duration - 20
                arrow.state.totalTexture = 6
                arrow.state.animSpeed = 1
                arrow.state.texturePaths = arrowTextures
                arrow.state.slots[0].life = 0
            }
        }

        if stateCnt > 0 && stateCnt % 4 == 0 {
            let spritePath = K2L("이팩트\\particle4.spr")
            let actionPath = K2L("이팩트\\particle4.act")
            _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

            let ember = launchPrimitive(.pp_3dparticle)
            ember.state.duration = Int.random(in: 0..<24) + 6
            ember.state.longitude = Float(Int.random(in: 0..<40)) + (longitude - 20.0)
            ember.state.latitude = Float(Int.random(in: 0..<20)) + (latitude - 10.0)
            let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(ember.state.latitude)))
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(ember.state.longitude)))
            ember.state.transform = rotY * rotX
            ember.state.deltaPos2 = deltaPos
            ember.state.speed = Float(Int.random(in: 0..<90) + 60) / 100.0
            ember.state.accel = -(ember.state.speed / Float(ember.state.duration)) / 1.5
            ember.state.size = Float(Int.random(in: 0..<30) + 20) / 100.0
            ember.state.sizeSpeed = -(ember.state.size / Float(ember.state.duration))
            ember.state.fadeOutCnt = 0
            ember.state.spritePath = spritePath
            ember.state.actionPath = actionPath
            ember.initSegment()
        }

        if flag != 0 {
            flag = 0
            let ringTex = "effect\\ring_yellow.tga"
            _ = context.assets?.texture(atPath: ringTex)

            let ring = launchPrimitive(.pp_3dcircle)
            ring.state.duration = 30
            ring.state.latitude = 90.0
            ring.state.radiusSpeed = 1.2
            let slowdown = -(ring.state.radiusSpeed / Float(ring.state.duration + 40))
            ring.state.radiusAccel = slowdown + slowdown
            ring.state.innerSize = 10.0
            ring.state.alpha = 0
            ring.state.alphaSpeed = ring.state.maxAlpha / 10.0
            ring.state.fadeOutCnt = ring.state.duration - 10
            ring.initSegment()
            ring.state.texturePaths = [ringTex]
        }
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

    // MARK: - EF_PORTAL (36)

    /// Spawns dual blue cylinders (`PP_3DCYLINDER` (13)) and pulsing ground rings (`PP_3DCIRCLE` (12)) for `EF_PORTAL` (36).
    func portal(context: EffectTickContext) {
        let texturePath = "effect\\ring_blue.tga"
        _ = context.assets?.texture(atPath: texturePath)

        if stateCnt == 0 {
            let specs: [(outer: Float, inner: Float, longSpeed: Float, height: Float)] = [
                (3.5, 3.5, 4.0, 40.0),
                (4.0, 4.0, 5.0, 50.0),
            ]
            for spec in specs {
                let cylinder = launchPrimitive(.pp_3dcylinder)
                cylinder.state.duration = duration
                cylinder.state.arcAngle = 36.0
                cylinder.state.outerSize = spec.outer
                cylinder.state.innerSize = spec.inner
                cylinder.state.longSpeed = spec.longSpeed
                cylinder.state.heightSize = spec.height
                cylinder.state.alpha = 0
                cylinder.state.maxAlpha = 128.0
                cylinder.state.alphaSpeed = cylinder.state.maxAlpha / 6.0
                cylinder.state.fadeOutCnt = cylinder.state.duration - 6
                cylinder.state.texturePaths = [texturePath]
            }
        }

        if stateCnt % 14 == 0 {
            let ring = launchPrimitive(.pp_3dcircle)
            ring.state.duration = 30
            ring.state.deltaPos2.y = -1.0
            ring.state.innerSize = 8.0
            ring.state.latitude = 90.0
            ring.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(ring.state.latitude)))
            ring.state.radiusSpeed = 1.0
            ring.state.radiusAccel = -(ring.state.radiusSpeed / Float(ring.state.duration)) * 0.5
            ring.state.fadeOutCnt = ring.state.duration - ring.state.duration / 2
            ring.initSegment()
            ring.state.texturePaths = [texturePath]
        }
    }

    private func spawnAgilityStreak(
        yOffset: Float,
        pitchDegrees: Int,
        speed: Float,
        accel: Float,
        life: Int8,
        context: EffectTickContext
    ) {
        let texturePath = "effect\\ac_center2.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let streak = launchPrimitive(.pp_3dcrosstexture)
        streak.state.duration = 50
        let yaw = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
        var placed = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<7) + 2)), by: yaw)
        placed.y += yOffset
        streak.state.deltaPos2 = placed
        streak.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: pitchDegrees))
        streak.state.speed = speed
        streak.state.accel = accel
        streak.state.widthSize = Float(Int.random(in: 0..<60) + 30) / 10.0
        streak.state.heightSize = 0.18
        streak.state.alpha = 0
        streak.state.maxAlpha = 200.0
        streak.state.alphaSpeed = streak.state.maxAlpha / 20.0
        streak.state.fadeOutCnt = streak.state.duration - 20
        streak.state.texturePaths = [texturePath]
        streak.state.slots[0].life = life
    }

    // MARK: - EF_INCAGILITY (37)

    /// Spawns agility buff banner (`PP_2DTEXTURE` (0)) and rising speed streaks (`PP_3DCROSSTEXTURE` (16)) for `EF_INCAGILITY` (37).
    func incAgility(context: EffectTickContext) {
        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\EF_IncAgility.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )

            let bannerTex = "effect\\agi_up.bmp"
            _ = context.assets?.texture(atPath: bannerTex)

            let banner = launchPrimitive(.pp_2dtexture)
            banner.state.duration = duration
            banner.state.longitude = 0
            banner.state.speed = 1.5
            banner.state.accel = -(banner.state.speed / Float(banner.state.duration)) * 1.2
            banner.state.widthSize = 40.0
            banner.state.heightSize = 20.0
            banner.state.alpha = 0
            banner.state.maxAlpha = 200.0
            banner.state.alphaSpeed = banner.state.maxAlpha / 15.0
            banner.state.fadeOutCnt = banner.state.duration - 15
            banner.state.texturePaths = [bannerTex]
            banner.state.slots[0].life = 99
        }

        guard (stateCnt & 1) == 0 else {
            return
        }

        spawnAgilityStreak(
            yOffset: 0,
            pitchDegrees: 90,
            speed: Float(Int.random(in: 0..<50) + 20) / 100.0,
            accel: 0,
            life: 99,
            context: context
        )
    }

    // MARK: - EF_DECAGILITY (38)

    /// Spawns slow debuff banner (`PP_2DTEXTURE` (0)) and falling speed streaks (`PP_3DCROSSTEXTURE` (16)) for `EF_DECAGILITY` (38).
    func decAgility(context: EffectTickContext) {
        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\EF_DecAgility.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )

            let bannerTex = "effect\\slow.bmp"
            _ = context.assets?.texture(atPath: bannerTex)

            let banner = launchPrimitive(.pp_2dtexture)
            banner.state.duration = duration
            banner.state.deltaPos2.y -= 80.0
            banner.state.longitude = 180.0
            banner.state.speed = 1.0
            banner.state.accel = -(banner.state.speed / Float(banner.state.duration))
            banner.state.widthSize = 40.0
            banner.state.heightSize = 10.0
            banner.state.alpha = 0
            banner.state.maxAlpha = 200.0
            banner.state.alphaSpeed = banner.state.maxAlpha / 15.0
            banner.state.fadeOutCnt = banner.state.duration - 15
            banner.state.texturePaths = [bannerTex]
            banner.state.slots[0].life = 0
        }

        guard (stateCnt & 1) == 0 else {
            return
        }

        spawnAgilityStreak(
            yOffset: -20.0,
            pitchDegrees: -90,
            speed: 0,
            accel: 0.015,
            life: 0,
            context: context
        )
    }

    // MARK: - EF_SIGNUM (40)

    /// Spawns a 2D shock burst (`PP_2DCIRCLE` (4) + `PP_2DFLASH` (3)) at tick 30 and advances `Cross.str` for `EF_SIGNUM` (40).
    func signum(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: "Cross.str")
        }

        if stateCnt == 30 {
            context.world.playSound(
                named: "effect\\EF_Signum.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
            context.world.playSound(
                named: "effect\\EF_Bash.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )

            let ringTex = "effect\\alpha_down.tga"
            let flashTex = "EFFECT\\alpha_center.tga"
            _ = context.assets?.texture(atPath: ringTex)
            _ = context.assets?.texture(atPath: flashTex)

            let ring = launchPrimitive(.pp_2dcircle)
            ring.state.duration = 40
            ring.state.pattern |= 1
            ring.state.deltaPos2.y = -40.0
            ring.state.radius = 100.0
            ring.state.alpha = 0
            ring.state.maxAlpha = 170.0
            ring.state.alphaSpeed = ring.state.maxAlpha / 6.0
            ring.state.fadeOutCnt = ring.state.duration - ring.state.duration / 3
            ring.state.texturePaths = [ringTex]

            for _ in 0..<20 {
                let flash = launchPrimitive(.pp_2dflash)
                flash.state.duration = 35
                flash.state.deltaPos2.y = -40.0
                flash.state.alpha = 0
                flash.state.longitude = Float(Int.random(in: 0..<360))
                flash.state.longSpeed = Float(Int.random(in: 0..<60) + 10) / 10.0
                flash.state.longAccel = -(flash.state.longSpeed / Float(flash.state.duration)) / 1.5
                flash.state.arcAngle = Float(Int.random(in: 0..<25) + 15) / 10.0
                flash.state.heightSize = Float(Int.random(in: 0..<60) + 30)
                flash.state.heightSpeed = Float(Int.random(in: 0..<35) + 95) / 10.0
                flash.state.maxAlpha = 200.0
                flash.state.alphaSpeed = flash.state.maxAlpha / 10.0
                flash.state.texturePaths = [flashTex]
            }
        }

        return processEZ2STRRaised(context: context)
    }

    // MARK: - EF_BLESSING (42)

    /// Spawns cyan aura ring (`PP_3DCIRCLE` (12)), crest (`축복`), and rising particles (`particle6`) for `EF_BLESSING` (42).
    func blessing(context: EffectTickContext) {
        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\EF_Blessing.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )

            let ringTex = "effect\\alpha_down.tga"
            _ = context.assets?.texture(atPath: ringTex)

            let ring = launchPrimitive(.pp_3dcircle)
            ring.state.duration = duration
            ring.state.pattern |= 1
            ring.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
            ring.state.radius = 10.0
            ring.state.latitude = 90.0
            ring.state.red = 32
            ring.state.green = 176
            ring.state.blue = 232
            ring.state.alpha = 0
            ring.state.maxAlpha = 100.0
            ring.state.alphaSpeed = ring.state.maxAlpha / 30.0
            ring.state.fadeOutCnt = ring.state.duration - 30
            ring.initSegment()
            ring.state.texturePaths = [ringTex]
        }

        if stateCnt % 3 == 0 && stateCnt < 10 {
            let blessSprite = K2L("이팩트\\축복.spr")
            let blessAction = K2L("이팩트\\축복.act")
            _ = context.assets?.spriteAsset(spritePath: blessSprite, actionPath: blessAction)

            let crest = launchPrimitive(.pp_3dparticle)
            crest.state.duration = duration
            crest.state.animSpeed = 2
            crest.state.alpha = Float(stateCnt * -6 + 200)
            crest.state.deltaPos2 = SIMD3<Float>(0, -25.0, 0)
            crest.state.spritePath = blessSprite
            crest.state.actionPath = blessAction
            crest.initSegment()
        }

        if stateCnt % 4 == 0 {
            let p6Sprite = K2L("이팩트\\particle6.spr")
            let p6Action = K2L("이팩트\\particle6.act")
            _ = context.assets?.spriteAsset(spritePath: p6Sprite, actionPath: p6Action)

            let spark = launchPrimitive(.pp_3dparticle)
            spark.state.duration = 80
            spark.state.pattern |= 0x80
            let yaw = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
            spark.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, -25.0, Float(Int.random(in: 0..<7) + 2)), by: yaw)
            spark.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: -90))
            spark.state.speed = Float(Int.random(in: 0..<20) + 20) / 100.0
            spark.state.accel = -(spark.state.speed / Float(spark.state.duration)) * 0.5
            spark.state.alpha = 0
            spark.state.size = 0.5
            spark.state.fadeOutCnt = spark.state.duration - spark.state.duration / 5
            spark.state.alphaSpeed = spark.state.maxAlpha / 10.0
            spark.state.spritePath = p6Sprite
            spark.state.actionPath = p6Action
            spark.initSegment()
        }
    }

    // MARK: - EF_INCAGIDEX (43)

    /// Spawns DEX+AGI buff banner (`PP_2DTEXTURE` (0)) and rising streaks (`PP_3DCROSSTEXTURE` (16)) for `EF_INCAGIDEX` (43).
    func incAgiDex(context: EffectTickContext) {
        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\EF_IncAgiDex.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )

            let bannerTex = "effect\\dex_agi_up.bmp"
            _ = context.assets?.texture(atPath: bannerTex)

            let banner = launchPrimitive(.pp_2dtexture)
            banner.state.duration = duration
            banner.state.longitude = 0
            banner.state.speed = 1.5
            banner.state.accel = -(banner.state.speed / Float(banner.state.duration)) * 1.2
            banner.state.widthSize = 40.0
            banner.state.heightSize = 20.0
            banner.state.alpha = 0
            banner.state.maxAlpha = 200.0
            banner.state.alphaSpeed = banner.state.maxAlpha / 15.0
            banner.state.fadeOutCnt = banner.state.duration - 15
            banner.state.texturePaths = [bannerTex]
            banner.state.slots[0].life = 0
        }

        guard (stateCnt & 1) == 0 else {
            return
        }

        spawnAgilityStreak(
            yOffset: 0,
            pitchDegrees: 90,
            speed: Float(Int.random(in: 0..<50) + 20) / 100.0,
            accel: 0,
            life: 0,
            context: context
        )
    }

    // MARK: - EF_FIREFLY (45)

    /// Spawns wandering golden spark particle (`PP_3DPARTICLE` (5)) for `EF_FIREFLY` (45).
    func fireSparks(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let primitive = launchPrimitive(.pp_3dparticle)
        primitive.state.pattern |= 4
        primitive.state.pattern |= 0x80
        primitive.state.duration = 140
        duration = 140
        primitive.state.speed = Float(Int.random(in: 0..<35) + 15) / 100.0
        primitive.state.longitude = Float(Int.random(in: 0..<360))
        primitive.state.latitude = Float(Int.random(in: 0..<360))
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(primitive.state.longitude)))
        let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(primitive.state.latitude)))
        primitive.state.transform = rotX * rotY
        let distance = Float(Int.random(in: 0..<13) + 2)
        let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, distance), by: primitive.state.transform)
        primitive.state.deltaPos2 = SIMD3<Float>(forward.x, forward.y - 10.0, forward.z)
        primitive.state.chCnt = UInt32(Int.random(in: 0..<25) + 5)
        primitive.state.size = Float(Int.random(in: 0..<70) + 30) / 100.0
        primitive.state.alpha = 0
        primitive.state.maxAlpha = 80.0
        primitive.state.alphaSpeed = primitive.state.maxAlpha / 1.5
        primitive.state.alphaCycle = 1
        primitive.state.colorCycleIndex = 0
        primitive.state.chPoint = [40.0, 100.0]
        primitive.state.chVal1 = [120.0, 0.0]
        primitive.state.chVal2 = [200.0, 80.0]
        primitive.state.spritePath = spritePath
        primitive.state.actionPath = actionPath
        primitive.initSegment()
    }

    // MARK: - EF_SANDWIND (46)

    /// Spawns sweeping 2D sand gusts (`PP_2DTEXTURE` (0)) for `EF_SANDWIND` (46).
    func sandScatter(context: EffectTickContext) {
        guard stateCnt < 60, (stateCnt & 1) == 0 else {
            return
        }

        let texturePath = "effect\\sand1.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_2dtexture)
        primitive.state.pattern = 8
        primitive.state.duration = duration - Int.random(in: 0..<100)
        primitive.state.speed = Float(Int.random(in: 0..<300) + 260) / 100.0
        primitive.state.longitude = Float(Int.random(in: 0..<15) + 130)
        primitive.state.widthSize = 30.0
        primitive.state.heightSize = 30.0
        primitive.state.deltaPos2.x = Float(Int.random(in: 0..<640) - 500)
        primitive.state.deltaPos2.y = Float(Int.random(in: 0..<50) - 240)
        primitive.state.chCnt = UInt32(Int.random(in: 0..<10) + 10)
        primitive.state.alpha = 128.0
        primitive.state.fadeOutCnt = primitive.state.duration - primitive.state.duration / 3
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.slots[0].life = 0
    }

    // MARK: - EF_SPRAYPOND (48)

    /// Spawns radial fountain water panels (`PP_3DTEXTURE` (15)) and splash rings (`PP_3DCIRCLE` (12)) for `EF_SPRAYPOND` (48).
    func sprayPond(context: EffectTickContext) {
        if stateCnt == 0 {
            let waterTex = "effect\\pond_water.bmp"
            _ = context.assets?.texture(atPath: waterTex)

            for angle in stride(from: 0, to: 360, by: 45) {
                let panel = launchPrimitive(.pp_3dtexture)
                panel.state.pattern = 2
                panel.state.duration = 130
                panel.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(Float(angle) + 22.5)))
                let edge = EffectSpace.transformVector(SIMD3<Float>(0, 0, 12.2), by: panel.state.transform)
                panel.state.deltaPos2 = SIMD3<Float>(edge.x, edge.y - 2.0, edge.z)
                panel.state.rotTransform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(Float(angle + 90) + 22.5)))
                panel.state.alpha = 120.0
                panel.state.widthSize = 5.0
                panel.state.heightSize = 2.7
                panel.state.texturePaths = [waterTex]
            }
        }

        if stateCnt % 10 == 0 {
            let sprayTex = "effect\\alpha_down.tga"
            _ = context.assets?.texture(atPath: sprayTex)

            for angle in stride(from: 0, to: 360, by: 45) {
                let spray = launchPrimitive(.pp_3dtexture)
                spray.state.duration = 30
                spray.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(Float(angle) + 22.5)))
                spray.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, 13.8), by: spray.state.transform)
                let rotZ = EffectSpace.rotationZ(radians: EffectSpace.radian(degrees: 90))
                let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(Float(angle + 90) + 22.5)))
                spray.state.rotTransform = rotY * rotZ
                spray.state.alpha = 100.0
                spray.state.fadeOutCnt = 0
                spray.state.widthSize = 5.5
                spray.state.heightSize = 1.0
                spray.state.texturePaths = [sprayTex]
            }
        }

        if stateCnt % 20 == 0 {
            let rippleTex = "effect\\alpha_center.tga"
            _ = context.assets?.texture(atPath: rippleTex)

            let ring = launchPrimitive(.pp_3dcircle)
            ring.state.duration = 25
            ring.state.radius = 13.0
            ring.state.arcAngle = 10.0
            ring.state.size = 1.25
            ring.state.latitude = 90.0
            ring.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(ring.state.latitude)))
            ring.state.radiusSpeed = 0.25
            ring.state.radiusAccel = -(ring.state.radiusSpeed / Float(ring.state.duration))
            ring.state.alpha = 100.0
            ring.state.fadeOutCnt = 0
            ring.initSegment()
            ring.state.texturePaths = [rippleTex]
        }
    }

    // MARK: - EF_COLDHIT (51)

    func coldHit(context: EffectTickContext) {
        if stateCnt == 0 {
            let iceTexture = "effect\\ice.tga"
            _ = context.assets?.texture(atPath: iceTexture)

            for index in 0..<9 {
                let degree = Float(index) * 40.0
                let shard = launchPrimitive(.pp_2dquad)
                shard.state.duration = 15
                let heading = (degree - 15.0) + Float(Int.random(in: 0..<60))
                shard.state.roll = heading
                shard.state.longitude = heading

                if index % 3 == 0 {
                    shard.state.heightSize = Float(Int.random(in: 0..<10) + 100)
                    shard.state.widthSize = 10.0
                    shard.state.speed = Float(Int.random(in: 0..<45) / 10) + 12.8
                } else {
                    shard.state.heightSize = Float(Int.random(in: 0..<5) + 45)
                    shard.state.widthSize = 4.0
                    shard.state.speed = Float(Int.random(in: 0..<45) / 10) + 4.8
                }

                shard.state.accel = -(shard.state.speed / Float(shard.state.duration)) / 1.5
                let spread = Float(Int.random(in: 0..<5))
                shard.state.deltaPos2.x = EffectSpace.sine(degrees: Int(degree)) * spread
                shard.state.deltaPos2.y = EffectSpace.cosine(degrees: Int(degree)) * -spread - 20.0
                let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(shard.state.latitude)))
                let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(shard.state.longitude)))
                shard.state.transform = rotY * rotX
                shard.state.rotTransform = shard.state.transform
                shard.state.chCnt = 20
                shard.state.alpha = 200.0
                shard.state.fadeOutCnt = shard.state.duration - 10
                shard.state.texturePaths = [iceTexture]
            }
        }

        guard stateCnt == 0 || stateCnt == 7 else {
            return
        }

        let smokeTexture = "effect\\smoke.tga"
        _ = context.assets?.texture(atPath: smokeTexture)

        let puff = launchPrimitive(.pp_2dtexture)
        puff.state.duration = 25
        puff.state.speed = 0.85
        puff.state.longitude = Float(Int.random(in: 0..<40) - 20)
        puff.state.widthSize = 1.0
        puff.state.heightSize = 1.0
        puff.state.changeWidthSpeed = 0.5
        puff.state.changeHeightSpeed = 0.5
        puff.state.heightSpeed = 6.0
        puff.state.widthSpeed = 6.0
        puff.state.changePoint = 10
        puff.state.fadeOutCnt = puff.state.duration - puff.state.duration / 3
        puff.state.texturePaths = [smokeTexture]
        puff.state.slots[0].life = 0
    }

    // MARK: - EF_BEGINSPELL2 (54)

    /// Spawns rising spiral quad casting stack (`PP_3DCASTING` (23) or `PP_3DCASTING_3` (25)) for `EF_BEGINSPELL2` (54).
    func quadRingStackSized(texturePath: String, kind: Int, context: EffectTickContext) {
        if duration < 70 {
            duration = 70
        }

        _ = context.assets?.texture(atPath: texturePath)

        var resolvedKind = kind
        let primitive: EffectPrimitive
        if resolvedKind == 33 {
            resolvedKind = 0
            primitive = launchPrimitive(.pp_3dcasting_3)
        } else {
            primitive = launchPrimitive(.pp_3dcasting)
        }

        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = Float(resolvedKind)

        struct SlotSpec {
            let distance: Float
            let riseAngle: Int16
            let fullDisplayAngle: Int16
            let maxHeight: Float
            let rotStart: Int16
            let alphaB: Int16
        }

        let specs: [SlotSpec] = [
            SlotSpec(distance: 4.5, riseAngle: 70, fullDisplayAngle: 315, maxHeight: 25.0, rotStart: 0, alphaB: 180),
            SlotSpec(distance: 5.0, riseAngle: 57, fullDisplayAngle: 315, maxHeight: 22.0, rotStart: 90, alphaB: 180),
            SlotSpec(distance: 5.5, riseAngle: 45, fullDisplayAngle: 315, maxHeight: 19.0, rotStart: 180, alphaB: 180),
            SlotSpec(distance: 4.0, riseAngle: 89, fullDisplayAngle: 360, maxHeight: 250.0, rotStart: 0, alphaB: 70),
        ]

        for (index, spec) in specs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].distance = spec.distance
            primitive.state.slots[index].riseAngle = spec.riseAngle
            primitive.state.slots[index].fullDisplayAngle = spec.fullDisplayAngle
            primitive.state.slots[index].maxHeight = spec.maxHeight
            primitive.state.slots[index].rotStart = spec.rotStart
            primitive.state.slots[index].alphaB = spec.alphaB
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
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

    // MARK: - EF_WARPZONE (61)

    /// Loops warp portal ground aura (`PP_3DCIRCLE` (12)) and rising particles (`PP_3DPARTICLEORBIT` (7)) for `EF_WARPZONE` (61).
    func warpZone(context: EffectTickContext) {
        if stateCnt == 145 {
            stateCnt = 0
        }

        if stateCnt == 0 {
            let auraTex = "effect\\alpha_down.tga"
            _ = context.assets?.texture(atPath: auraTex)

            let aura = launchPrimitive(.pp_3dcircle)
            aura.state.duration = 158
            aura.state.pattern |= 1
            aura.state.radius = 15.0
            aura.state.deltaPos2.y -= 1.0
            aura.state.latitude = 90.0
            aura.state.alpha = 0
            aura.state.maxAlpha = 128.0
            aura.state.alphaSpeed = aura.state.maxAlpha / 10.0
            aura.state.fadeOutCnt = aura.state.duration - 10
            aura.initSegment()
            aura.state.texturePaths = [auraTex]
        }

        if stateCnt % 28 == 0 && stateCnt < 117 {
            let ringTex = "effect\\ring_blue.tga"
            _ = context.assets?.texture(atPath: ringTex)

            let ring = launchPrimitive(.pp_3dcircle)
            ring.state.duration = 80
            ring.state.innerSize = 4.0
            ring.state.latitude = 90.0
            ring.state.deltaPos2.y -= 1.0
            ring.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(ring.state.latitude)))
            ring.state.radius = 14.0
            ring.state.radiusSpeed = -0.15
            ring.state.alpha = 5.0
            ring.state.maxAlpha = 200.0
            ring.state.alphaSpeed = 10.0
            ring.state.chPoint.append(20.0)
            ring.state.chVal1.append(0.0)
            ring.state.fadeOutCnt = ring.state.duration - ring.state.duration / 5
            ring.initSegment()
            ring.state.texturePaths = [ringTex]
        }

        if stateCnt % 10 == 0 {
            let spritePath = K2L("이팩트\\particle1.spr")
            let actionPath = K2L("이팩트\\particle1.act")
            _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

            let particle = launchPrimitive(.pp_3dparticleorbit)
            particle.state.radius = Float(Int.random(in: 0..<200) / 100) * 0.75 + 5.0
            particle.state.radiusSpeed = 0.0005
            particle.state.duration = 130
            particle.state.longitude = Float(Int.random(in: 0..<360))
            particle.state.longSpeed = 2.0
            particle.state.gravSpeed = -0.2
            particle.state.gravAccel = -(particle.state.gravSpeed / Float(particle.state.duration)) / 1.5
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(particle.state.longitude)))
            particle.state.transform = rotY
            particle.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, particle.state.radius), by: rotY)
            particle.state.size = Float(Int.random(in: 0..<10) / 10) + 0.7
            particle.state.fadeOutCnt = particle.state.duration - particle.state.duration / 3
            particle.state.spritePath = spritePath
            particle.state.actionPath = actionPath
            particle.initSegment()
        }
    }

    // MARK: - EF_SIGHTRASHER (62)

    /// Spawns expanding 8-way Sight projectiles and ground shadows (`PP_3DPARTICLE` (5)) and yellow burst ring (`PP_3DCIRCLE` (12)) for `EF_SIGHTRASHER` (62).
    func sightrasher(context: EffectTickContext) {
        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\wizard_sightrasher.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        if stateCnt % 5 == 0 && stateCnt < 20 {
            let sightSprite = K2L("이팩트\\Sight.spr")
            let sightAction = K2L("이팩트\\Sight.act")
            let shadowSprite = "Shadow.spr"
            let shadowAction = "Shadow.act"
            _ = context.assets?.spriteAsset(spritePath: sightSprite, actionPath: sightAction)
            _ = context.assets?.spriteAsset(spritePath: shadowSprite, actionPath: shadowAction)

            let reach = Float(stateCnt / 5) + 5.0

            for index in 0..<8 {
                let angle = Int(Float(index) * -45.0)
                let sine = EffectSpace.sine(degrees: angle)
                let cosine = EffectSpace.cosine(degrees: angle)

                let flame = launchPrimitive(.pp_3dparticle)
                flame.state.duration = 85 - stateCnt
                flame.state.pattern |= 0x400
                flame.state.deltaPos2 = SIMD3<Float>(reach * sine, Float(stateCnt / 3 - 20), -reach * cosine)
                flame.state.speed3d = SIMD3<Float>(sine, 0, -cosine)
                flame.state.animSpeed = Int.random(in: 0..<2) + 3
                flame.state.size = 2.5 - Float(stateCnt) / 10.0
                flame.state.alpha = Float((75 - stateCnt) * 2)
                flame.state.deltaPosAccel = .zero
                flame.state.changeSpeed3d = SIMD3<Float>(sine * 0.5, 0, -cosine * 0.5)
                flame.state.changePoint = 35 - stateCnt
                flame.state.changeAccel3d = SIMD3<Float>(-0.004, 0, 0.004)
                flame.state.fadeOutCnt = 65 - stateCnt
                flame.state.spritePath = sightSprite
                flame.state.actionPath = sightAction
                flame.initSegment()
            }

            for index in 0..<8 {
                let angle = Int(Float(index) * -45.0)
                let sine = EffectSpace.sine(degrees: angle)
                let cosine = EffectSpace.cosine(degrees: angle)

                let shadow = launchPrimitive(.pp_3dparticle)
                shadow.state.duration = 85 - stateCnt
                shadow.state.pattern |= 0x400
                shadow.state.deltaPos2 = SIMD3<Float>(reach * sine, 0, -reach * cosine)
                shadow.state.speed3d = SIMD3<Float>(sine, 0, -cosine)
                shadow.state.animSpeed = 3
                shadow.state.size = 1.0 - Float(stateCnt) / 30.0
                shadow.state.alpha = Float((75 - stateCnt) * 2)
                shadow.state.changeSpeed3d = SIMD3<Float>(sine * 0.5, 0, -cosine * 0.5)
                shadow.state.changePoint = 35 - stateCnt
                shadow.state.changeAccel3d = SIMD3<Float>(-0.004, 0, 0.004)
                shadow.state.fadeOutCnt = 65 - stateCnt
                shadow.state.spritePath = shadowSprite
                shadow.state.actionPath = shadowAction
                shadow.initSegment()
            }
        }

        if stateCnt == 10 {
            let ringTex = "effect\\ring_yellow.tga"
            _ = context.assets?.texture(atPath: ringTex)

            let ring = launchPrimitive(.pp_3dcircle)
            ring.state.duration = 30
            ring.state.latitude = 90.0
            ring.state.radiusSpeed = 2.5
            ring.state.radiusAccel = -(ring.state.radiusSpeed / Float(ring.state.duration)) / 1.5
            ring.state.innerSize = -10.0
            ring.state.alpha = 150.0
            ring.state.fadeOutCnt = ring.state.duration - 10
            ring.initSegment()
            ring.state.texturePaths = [ringTex]
        }
    }

    // MARK: - EF_SPHERE (72)

    /// Spawns orbiting sphere particles (`PP_3DPARTICLEORBIT` (7)) for `EF_SPHERE` (72).
    func sphere(context: EffectTickContext) {
        guard stateCnt % 10 == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        duration = 500 - stateCnt
        let particle = launchPrimitive(.pp_3dparticleorbit)
        particle.state.duration = 300
        particle.state.radius = 0.1
        particle.state.radiusSpeed = 0.15
        particle.state.gravSpeed = 0.15
        particle.state.longitude = 2.0
        particle.state.longSpeed = 8.0
        particle.state.longAccel = -0.01
        particle.state.size = 1.2
        particle.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(particle.state.longitude)))
        particle.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, -30.0, particle.state.radius), by: particle.state.transform)
        particle.state.chRadiSpeed = 1
        particle.state.colorCycleIndex = 0
        particle.state.chPoint.append(95.0)
        particle.state.chVal1.append(-0.15)
        particle.state.chVal2.append(particle.state.radiusAccel)
        particle.state.spritePath = spritePath
        particle.state.actionPath = actionPath
        particle.initSegment()
    }

    // MARK: - EF_BOWLINGBASH (73)

    /// Spawns slashing cylinders (`PP_3DCYLINDER` (13)) and ground shockwave (`PP_3DCIRCLE` (12)) for `EF_BOWLINGBASH` (73).
    func bowlingBash(context: EffectTickContext) {
        guard stateCnt == 0 || stateCnt == 5 else {
            return
        }

        let facing = Int(180.0 - longitude)
        let angle = facing < 0 ? facing + 360 : facing

        let blueTex = "effect\\ring_blue.tga"
        _ = context.assets?.texture(atPath: blueTex)

        let cylinder = launchPrimitive(.pp_3dcylinder)
        cylinder.state.duration = 20 - stateCnt
        cylinder.state.longitude = Float(angle + stateCnt * 20)
        let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(cylinder.state.latitude)))
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(cylinder.state.longitude)))
        cylinder.state.transform = rotY * rotX
        cylinder.state.outerSize = 8.0
        cylinder.state.outerSpeed = 0.5
        cylinder.state.outerAccel = -0.03
        cylinder.state.innerSize = 3.0
        cylinder.state.innerSpeed = 0.5
        cylinder.state.innerAccel = -0.03
        cylinder.state.heightSize = 3.5
        cylinder.state.alpha = Float(stateCnt * -7 + 240)
        cylinder.state.fadeOutCnt = cylinder.state.duration - cylinder.state.duration / 2
        cylinder.state.texturePaths = [blueTex]

        if stateCnt == 0 {
            let yellowTex = "effect\\ring_yellow.tga"
            _ = context.assets?.texture(atPath: yellowTex)

            let ring = launchPrimitive(.pp_3dcircle)
            ring.state.duration = 50
            ring.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
            ring.state.latitude = 90.0
            ring.state.radius = 8.0
            ring.state.radiusSpeed = 0.7
            ring.state.radiusAccel = -(ring.state.radiusSpeed / 30.0)
            ring.state.innerSize = 5.0
            ring.state.changePoint = 20
            ring.state.changeAccel = 0
            ring.state.changeSpeed = 0.08
            ring.state.alpha = 45.0
            ring.state.fadeOutCnt = 35
            ring.initSegment()
            ring.state.texturePaths = [yellowTex]
        }
    }

    // MARK: - EF_ICEWALL (74)

    /// Spawns a row of three persistent ice pillars (`PP_3DQUADHORN` (9)) for `EF_ICEWALL` (74).
    func iceWall(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\wizard_icewall.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
        duration = 9999

        let texturePath = "effect\\ice.tga"
        _ = context.assets?.texture(atPath: texturePath)

        for offset in stride(from: -2, to: 4, by: 2) {
            let pillar = launchPrimitive(.pp_3dquadhorn)
            pillar.state.duration = duration
            pillar.state.pattern |= 1
            let angle = Int.random(in: 0..<360)
            let cosine = EffectSpace.cosine(degrees: angle)
            pillar.state.deltaPos2 = SIMD3<Float>(0, 30.0, -Float(offset) * cosine)
            pillar.state.size = Float(Int.random(in: 0..<40) / 100) + 2.5
            pillar.state.heightSize = Float(Int.random(in: 0..<100) + 300) / 10.0
            pillar.state.longitude = Float(Int.random(in: 0..<360))
            pillar.state.latitude = Float(Int.random(in: 0..<6) + 87)
            pillar.state.chCnt = 20
            pillar.state.alpha = 200.0
            let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(pillar.state.latitude)))
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(pillar.state.longitude)))
            pillar.state.transform = rotY * rotX
            pillar.state.rotTransform = pillar.state.transform
            pillar.state.speed = 3.0
            let decay = -(pillar.state.speed / 40.0)
            pillar.state.accel = decay + decay
            pillar.state.fadeOutCnt = pillar.state.duration - 10
            pillar.state.texturePaths = [texturePath]
        }
    }

    // MARK: - EF_EARTHSPIKE (79)

    /// Spawns ground spikes (`PP_3DQUADHORN` (9)) and camera quake for `EF_EARTHSPIKE` (79).
    func earthSpike(type: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath: String
        if type == 0 {
            context.world.playSound(
                named: "effect\\wizard_earthspike.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
            texturePath = "effect\\stone.bmp"
        } else if type == 2 {
            let variant = Int.random(in: 0..<3) + 1
            context.world.playSound(
                named: "effect\\EF_IceArrow\(variant).wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
            texturePath = "effect\\ice.tga"
        } else {
            texturePath = "effect\\stone.bmp"
        }

        _ = context.assets?.texture(atPath: texturePath)
        context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)

        let center = launchPrimitive(.pp_3dquadhorn)
        center.state.duration = 240
        center.state.pattern = 1 | 2
        center.state.deltaPos2 = SIMD3<Float>(0, 10.0, 0)
        center.state.size = Float(Int.random(in: 0..<50) + 300) / 100.0
        center.state.heightSize = 18.0
        center.state.longitude = Float(Int.random(in: 0..<360))
        center.state.latitude = Float(Int.random(in: 0..<20) + 80)
        let cRotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(center.state.latitude)))
        let cRotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(center.state.longitude)))
        center.state.transform = cRotY * cRotX
        center.state.rotTransform = center.state.transform
        center.state.speed = 1.0
        center.state.accel = 0.01
        center.state.alpha = 250.0
        center.state.chCnt = 15
        center.state.changePoint = 12
        center.state.changeSpeed = -1.2
        center.state.changeAccel = 0
        center.state.fadeOutCnt = center.state.duration - 10
        center.state.texturePaths = [texturePath]

        for step in stride(from: 60, to: 420, by: 60) {
            let offset = step == 0 ? 0 : Int.random(in: 0..<step)
            let spike = launchPrimitive(.pp_3dquadhorn)
            spike.state.duration = 240
            spike.state.pattern |= 1
            let angle = Int.random(in: 0..<360)
            let sine = EffectSpace.sine(degrees: angle)
            let cosine = EffectSpace.cosine(degrees: angle)
            spike.state.deltaPos2 = SIMD3<Float>(sine * 3.5, 20.0, cosine * -3.5)
            spike.state.size = Float(Int.random(in: 0..<100) + 400) / 100.0
            spike.state.heightSize = 20.0
            spike.state.longitude = min(Float(offset + step - 60), 360.0)
            spike.state.latitude = 100.0
            let sRotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(spike.state.latitude)))
            let sRotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spike.state.longitude)))
            spike.state.transform = sRotY * sRotX
            spike.state.rotTransform = spike.state.transform
            spike.state.speed = 1.5
            spike.state.accel = 0
            spike.state.alpha = 250.0
            spike.state.chCnt = 2
            spike.state.fadeOutCnt = spike.state.duration - 10
            spike.state.texturePaths = [texturePath]
        }
    }

    // MARK: - EF_SPEARBMR (80)

    /// Spawns four staggered flying spear sprites (`PP_3DPARTICLE` (5)) toward the target for `EF_SPEARBMR` (80).
    func spearBmr(context: EffectTickContext) {
        guard stateCnt == 0 || stateCnt == 4 || stateCnt == 8 || stateCnt == 12 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_FireBall.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let spritePath = K2L("이팩트\\창.spr")
        let actionPath = K2L("이팩트\\창.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let (origin, destination) = directionalLaunchEndpoints()
        let faceAngle = Self.effectHeading(fromX: origin.x, fromZ: origin.z, toX: destination.x, toZ: destination.z)

        let spear = launchPrimitive(.pp_3dparticle)
        spear.state.duration = 15
        spear.state.pattern |= 0x120
        spear.state.deltaPos2 = SIMD3<Float>(0, -15.0, 0)
        spear.state.longitude = -faceAngle
        var primAngle = 180.0 - faceAngle
        if primAngle < 0 {
            primAngle += 360.0
        }
        spear.angle = primAngle
        spear.state.speed = -(Self.effectDistanceXZ(from: origin, to: destination) / Float(spear.state.duration))
        spear.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spear.state.longitude)))
        spear.state.size = 1.0
        spear.state.animSpeed = 1

        if stateCnt != 0 {
            if stateCnt == 4 {
                spear.state.alpha = 180.0
            } else if stateCnt == 8 {
                spear.state.alpha = 130.0
            } else {
                spear.state.alpha = 80.0
            }
        }

        spear.state.spritePath = spritePath
        spear.state.actionPath = actionPath
        spear.initSegment()
    }

    // MARK: - EF_PIERCE (81)

    /// Spawns directional spear ring bursts (`PP_3DCYLINDER` (13)) and spark particles (`PP_3DPARTICLE` (5), `PP_3DPARTICLEGRAVITY` (6)) for `EF_PIERCE` (81).
    func ringBurstSparks(context: EffectTickContext) {
        guard stateCnt % 20 == 0, stateCnt < level * 20 else {
            return
        }

        var facing = Int(180.0 - longitude)
        if facing < 0 {
            facing += 360
        }

        let texturePath = "effect\\ring_yellow.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let cylinder = launchPrimitive(.pp_3dcylinder)
        cylinder.state.duration = 15
        cylinder.state.longitude = Float(facing)
        cylinder.state.latitude = -90.0
        let cRotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(cylinder.state.latitude)))
        let cRotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(cylinder.state.longitude)))
        cylinder.state.transform = cRotY * cRotX
        cylinder.state.deltaPos2 = SIMD3<Float>(0, -10.0, 0)
        cylinder.state.speed = 0.7
        cylinder.state.accel = -(cylinder.state.speed / Float(cylinder.state.duration)) * 0.5
        cylinder.state.outerSize = Float(stateCnt) * 0.1 + 11.0
        cylinder.state.innerSize = Float(stateCnt) * 0.1 + 6.0
        cylinder.state.heightSize = 2.5
        cylinder.state.fadeOutCnt = cylinder.state.duration - cylinder.state.duration / 2
        cylinder.state.texturePaths = [texturePath]

        guard stateCnt > 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        for _ in 0..<4 {
            let spark = launchPrimitive(.pp_3dparticle)
            spark.state.longitude = Float(Int.random(in: 0..<80) + facing - 40)
            spark.state.latitude = Float(Int.random(in: 0..<100) - 50)
            let pRotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spark.state.longitude)))
            let pRotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(spark.state.latitude)))
            spark.state.transform = pRotX * pRotY
            let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<4) + 4)), by: spark.state.transform)
            spark.state.deltaPos3 = forward
            spark.state.deltaPos2 = SIMD3<Float>(forward.x, forward.y - 10.0, forward.z)
            spark.state.speed = Float(Int.random(in: 0..<90) + 60) / 100.0
            spark.state.duration = Int.random(in: 0..<24) + 6
            spark.state.accel = -(spark.state.speed / Float(spark.state.duration)) * 0.5
            spark.state.size = Float(Int.random(in: 0..<100) + 60) / 100.0
            spark.state.sizeSpeed = -(spark.state.size / Float(spark.state.duration))
            spark.state.fadeOutCnt = 0
            spark.state.spritePath = spritePath
            spark.state.actionPath = actionPath
            spark.state.numSegment = 3
            spark.initSegment()
        }

        for _ in 0..<4 {
            let spark = launchPrimitive(.pp_3dparticlegravity)
            spark.state.longitude = Float(Int.random(in: 0..<80) + facing + 140)
            spark.state.latitude = Float(Int.random(in: 0..<100) - 50)
            let pRotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spark.state.longitude)))
            let pRotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(spark.state.latitude)))
            let spreadTransform = pRotX * pRotY
            let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<4) + 4)), by: spreadTransform)
            spark.state.deltaPos3 = forward
            spark.state.deltaPos2 = SIMD3<Float>(forward.x, forward.y - 10.0, forward.z)
            spark.state.transform = pRotY
            spark.state.duration = Int.random(in: 0..<24) + 6
            spark.state.speed = Float(Int.random(in: 0..<90) + 60) / 100.0
            spark.state.accel = -(spark.state.speed / Float(spark.state.duration)) * 0.5
            spark.state.gravSpeed = -Float(Int.random(in: 0..<90) + 30) / 100.0
            let fall = spark.state.gravSpeed / Float(spark.state.duration)
            spark.state.gravAccel = -(fall + fall)
            spark.state.size = Float(Int.random(in: 0..<100) + 60) / 100.0
            spark.state.sizeSpeed = -(spark.state.size / Float(spark.state.duration))
            spark.state.fadeOutCnt = 0
            spark.state.spritePath = spritePath
            spark.state.actionPath = actionPath
            spark.state.numSegment = 3
            spark.initSegment()
        }
    }

    // MARK: - EF_TURNUNDEAD (82)

    /// Spawns imploding 2D light rays (`PP_2DCIRCLE` (4), `PP_2DFLASH` (3)) and a ground ring (`PP_3DTEXTURE` (15)) for `EF_TURNUNDEAD` (82).
    func turnUndead(context: EffectTickContext) {
        if stateCnt == 37 {
            context.world.playSound(
                named: "effect\\EF_Bash.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        if stateCnt == 0 {
            let circleTex = "effect\\alpha_down.tga"
            let flashTex = "EFFECT\\alpha_center.tga"
            _ = context.assets?.texture(atPath: circleTex)
            _ = context.assets?.texture(atPath: flashTex)

            let circle = launchPrimitive(.pp_2dcircle)
            circle.state.radius = 370.0
            circle.state.radiusSpeed = -(circle.state.radius / 20.0)
            circle.state.duration = 20
            circle.state.pattern |= 1
            circle.state.deltaPos2.y = -40.0
            circle.state.alpha = 0
            circle.state.maxAlpha = 130.0
            circle.state.alphaSpeed = circle.state.maxAlpha / 6.0
            circle.state.fadeOutCnt = circle.state.duration - 10
            circle.state.texturePaths = [circleTex]

            let loopCount = 5
            for _ in 0..<loopCount {
                let flash = launchPrimitive(.pp_2dflash)
                flash.state.duration = 20
                flash.state.chCnt = UInt32.max
                flash.state.speed3d.x = position.x
                flash.state.speed3d.y = position.z
                flash.state.deltaPos2.y = -40.0
                flash.state.longitude = Float(Int.random(in: 0..<360))
                flash.state.longSpeed = Float(Int.random(in: 0..<60) + 10) / 10.0
                flash.state.longAccel = -(flash.state.longSpeed / Float(flash.state.duration)) / 1.5
                flash.state.arcAngle = Float(Int.random(in: 0..<25) + 5) / 10.0
                flash.state.heightSize = Float(Int.random(in: 0..<30) + 350)
                flash.state.heightSpeed = -Float(Int.random(in: 0..<30) + 150) / 10.0
                flash.state.alpha = 0
                flash.state.maxAlpha = 150.0
                flash.state.alphaSpeed = flash.state.maxAlpha / 10.0
                flash.state.fadeOutCnt = flash.state.duration - flash.state.duration / 3
                flash.state.texturePaths = [flashTex]
            }
        }

        if stateCnt == 50 {
            let ringTex = "effect\\ring_liner.tga"
            _ = context.assets?.texture(atPath: ringTex)

            let ring = launchPrimitive(.pp_3dtexture)
            ring.state.duration = 30
            ring.state.roll = 90.0
            ring.state.widthSpeed = 1.5
            ring.state.heightSpeed = 1.5
            ring.state.deltaPos2.y = -7.0
            ring.state.widthAccel = ring.state.widthSpeed / 10.0
            ring.state.heightAccel = ring.state.heightSpeed / 10.0
            ring.state.alpha = 150.0
            ring.state.fadeOutCnt = ring.state.duration - 10
            ring.state.changePoint = 15
            ring.state.changeWidthSpeed = 0.5
            ring.state.changeWidthAccel = -0.5 / 15.0
            ring.state.changeHeightSpeed = 0.5
            ring.state.changeHeightAccel = -0.5 / 15.0
            ring.initSegment()
            ring.state.texturePaths = [ringTex]
        }
    }

    // MARK: - EF_ASPERSIO (86)

    /// Spawns holy water particles (`PP_3DPARTICLEORBIT` (7)) and advances `Aspersio.str` for `EF_ASPERSIO` (86).
    func aspersio(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: "Aspersio.str")
        }

        if stateCnt == 70 {
            context.world.playSound(
                named: "effect\\priest_aspersio.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        if stateCnt % 5 == 0 && stateCnt > 60 && stateCnt < 140 {
            let spritePath = K2L("이팩트\\particle1.spr")
            let actionPath = K2L("이팩트\\particle1.act")
            _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

            duration = 400
            let particle = launchPrimitive(.pp_3dparticleorbit)
            particle.state.duration = 40
            particle.state.radius = 1.5
            particle.state.gravSpeed = 0.19
            particle.state.gravAccel = 0.01
            particle.state.longitude = Float(Int.random(in: 0..<360))
            particle.state.size = 1.2
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(particle.state.longitude)))
            particle.state.transform = rotY
            particle.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, -30.0, particle.state.radius), by: rotY)
            particle.state.fadeOutCnt = 30
            particle.state.spritePath = spritePath
            particle.state.actionPath = actionPath
            particle.initSegment()
        }

        if stateCnt == duration {
            return false
        }

        _ = processEZ2STRRaised(context: context)
        return true
    }

    // MARK: - EF_STORMGUST (89)

    /// Plays Storm Gust audio, spawns periodic ice horns (`PP_3DQUADHORN` (9)), and advances `StormGust.str` for `EF_STORMGUST` (89).
    func stormGust(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: "StormGust.str")
            context.world.playSound(
                named: "effect\\wizard_stormgust.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        if !context.usesMinimalEffects && stateCnt % 29 == 0 && stateCnt > 30 && stateCnt <= 150 {
            let texturePath = "effect\\ice.tga"
            _ = context.assets?.texture(atPath: texturePath)

            for _ in 0..<2 {
                let degree = Float(Int.random(in: 0..<360))
                let radius = Float(Int.random(in: 0..<25) + 3)
                let horn = launchPrimitive(.pp_3dquadhorn)
                horn.state.duration = 215 - stateCnt
                horn.state.pattern |= 1

                let angle = Int.random(in: 0..<360)
                let sine = EffectSpace.sine(degrees: angle)
                let cosine = EffectSpace.cosine(degrees: angle)
                horn.state.deltaPos2 = SIMD3<Float>(radius * sine, 20.0, -radius * cosine)
                horn.state.size = Float(Int.random(in: 0..<100) + 400) / 100.0
                horn.state.heightSize = 20.0
                horn.state.longitude = degree
                horn.state.latitude = 100.0

                let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(horn.state.latitude)))
                let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(horn.state.longitude)))
                horn.state.transform = rotY * rotX
                horn.state.rotTransform = horn.state.transform

                horn.state.speed = 1.5
                horn.state.accel = 0
                horn.state.alpha = 250.0
                horn.state.chCnt = 3
                horn.state.fadeOutCnt = horn.state.duration - 10
                horn.state.texturePaths = [texturePath]
            }
        }

        return processEZ2STRRaised(context: context)
    }

    // MARK: - EF_YUFITEL (93)

    /// Spawns directional lightning/twirl orb (`PP_3DTEXTURE` (15)) toward the target for `EF_YUFITEL` (93).
    func yufitel(flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\hunter_shockwavetrap.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let (origin, destination) = directionalLaunchEndpoints()
        let faceAngle = Self.effectHeading(fromX: origin.x, fromZ: origin.z, toX: destination.x, toZ: destination.z)
        var primAngle = 180.0 - faceAngle
        if primAngle < 0 {
            primAngle += 360.0
        }
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(-faceAngle)))
        let speed = -(Self.effectDistanceXZ(from: origin, to: destination) / 20.0)

        let coreTex = flag == 0 ? "effect\\thunder_center.bmp" : "effect\\twirl_soft.bmp"
        _ = context.assets?.texture(atPath: coreTex)

        let core = launchPrimitive(.pp_3dtexture)
        core.state.duration = 20
        core.state.pattern |= 0x40 | 0x400
        core.state.renderFlag |= EffectPrimitiveState.RenderFlag.additive
        core.state.widthSize = 3.5
        core.state.heightSize = 3.5
        core.state.longitude = -faceAngle
        core.angle = primAngle
        core.state.speed = speed
        core.state.transform = rotY
        core.state.deltaPos2.y = -5.0
        core.state.alpha = 170.0
        core.state.texturePaths = [coreTex]

        let boltTextures: [String] = flag == 0
            ? [
                "effect\\thunder_ball_a.bmp",
                "effect\\thunder_ball_b.bmp",
                "effect\\thunder_ball_c.bmp",
                "effect\\thunder_ball_d.bmp",
                "effect\\thunder_ball_e.bmp",
                "effect\\thunder_ball_f.bmp",
            ]
            : [
                "effect\\twirl_soft.bmp",
                "effect\\thunder_ball_b.bmp",
                "effect\\twirl_soft.bmp",
                "effect\\thunder_ball_d.bmp",
                "effect\\twirl_soft.bmp",
                "effect\\thunder_ball_f.bmp",
            ]
        for path in boltTextures {
            _ = context.assets?.texture(atPath: path)
        }

        let bolt = launchPrimitive(.pp_3dtexture)
        bolt.state.duration = 20
        bolt.state.pattern = 0x40 | 0x400
        bolt.state.renderFlag |= EffectPrimitiveState.RenderFlag.additive
        bolt.state.repeatAnim = true
        bolt.state.widthSize = 4.5
        bolt.state.heightSize = 4.5
        bolt.state.longitude = -faceAngle
        bolt.angle = primAngle
        bolt.state.speed = speed
        bolt.state.transform = rotY
        bolt.state.deltaPos2.y = -5.0
        bolt.state.animSpeed = 1
        bolt.state.totalTexture = 6
        bolt.state.texturePaths = boltTextures
    }

    // MARK: - EF_YUFITELHIT (94)

    func yufitelHit(kind: Int8, context: EffectTickContext) {
        if stateCnt % 20 == 0 {
            let burstTexture = kind == 0 ? "effect\\thunder_pang.bmp" : "effect\\pokjuk_d.bmp"
            _ = context.assets?.texture(atPath: burstTexture)

            let burst = launchPrimitive(.pp_3dtexture)
            burst.state.duration = 10
            burst.state.pattern |= 0x40
            burst.state.renderFlag |= EffectPrimitiveState.RenderFlag.additive | EffectPrimitiveState.RenderFlag.noDepth
            burst.state.deltaPos2.y = -5.0
            burst.state.widthSpeed = 2.5
            burst.state.heightSpeed = 2.5
            burst.state.changePoint = 10
            burst.state.changeWidthSpeed = 0
            burst.state.changeHeightSpeed = 0
            burst.state.changeWidthAccel = 0
            burst.state.changeHeightAccel = 0
            burst.state.fadeOutCnt = 1
            burst.state.texturePaths = [burstTexture]
        }

        guard stateCnt == 10 else {
            return
        }

        let textures: [String] = if kind == 0 {
            [
                "effect\\thunder_plazma_blast_a.bmp",
                "effect\\thunder_plazma_blast_b.bmp",
                "effect\\thunder_ball_d.bmp",
                "effect\\thunder_ball_e.bmp",
                "effect\\thunder_ball_f.bmp",
            ]
        } else {
            [
                "effect\\twirl_soft.bmp",
                "effect\\thunder_ball_b.bmp",
                "effect\\twirl_soft.bmp",
                "effect\\thunder_ball_c.bmp",
                "effect\\twirl_soft.bmp",
            ]
        }
        for path in textures {
            _ = context.assets?.texture(atPath: path)
        }

        let ball = launchPrimitive(.pp_3dtexture)
        ball.state.duration = 300
        ball.state.pattern |= 0x40
        ball.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth | EffectPrimitiveState.RenderFlag.additive
        ball.state.deltaPos2.y = -5.0
        ball.state.repeatAnim = true
        ball.state.widthSize = 7.5
        ball.state.heightSize = 7.5
        ball.state.animSpeed = 1
        ball.state.totalTexture = textures.count
        ball.state.texturePaths = textures
    }

    // MARK: - EF_HASTEUP (98)

    /// Spawns Adrenaline Rush light rays (`PP_2DFLASH` (3)) and orbiting particles (`PP_3DPARTICLEORBIT` (7)) for `EF_HASTEUP` (98).
    func hasteUp(context: EffectTickContext) {
        if stateCnt == 0 {
            duration = 300
            context.world.playSound(
                named: "effect\\black_adrenalinerush_a.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        if stateCnt == 30 {
            context.world.playSound(
                named: "effect\\black_adrenalinerush_b.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        guard stateCnt == 0 else {
            return
        }

        let flashTex = "EFFECT\\alpha_center.tga"
        _ = context.assets?.texture(atPath: flashTex)

        for _ in 0..<20 {
            let flash = launchPrimitive(.pp_2dflash)
            flash.state.duration = 80
            flash.state.deltaPos2.y = -40.0
            flash.state.longitude = Float(Int.random(in: 0..<360))
            flash.state.longSpeed = Float(Int.random(in: 0..<60) + 10) / 10.0
            flash.state.longAccel = -(flash.state.longSpeed / Float(flash.state.duration)) / 1.5
            flash.state.arcAngle = Float(Int.random(in: 0..<25) + 5) / 10.0
            flash.state.heightSize = 0
            flash.state.heightSpeed = Float(Int.random(in: 0..<20) + 50) / 13.0
            flash.state.changePoint = 40
            flash.state.changeSpeed = Float(Int.random(in: 0..<10) + 15) / 10.0
            flash.state.changeAccel = 0
            flash.state.changeHeightSpeed = 0
            flash.state.texturePaths = [flashTex]
        }

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        for index in 0..<4 {
            let orbit = launchPrimitive(.pp_3dparticleorbit)
            orbit.state.duration = 100
            orbit.state.radius = 7.0
            orbit.state.gravSpeed = -0.1
            orbit.state.gravAccel = -0.002
            orbit.state.longitude = Float(index * 90)
            orbit.state.longAccel = 0.2
            orbit.state.longSpeed = Float(stateCnt) * orbit.state.longAccel + 0.3
            orbit.state.size = 1.2
            orbit.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(orbit.state.longitude)))
            orbit.state.fadeOutCnt = orbit.state.duration - orbit.state.duration / 10
            orbit.state.spritePath = spritePath
            orbit.state.actionPath = actionPath
            orbit.initSegment()
        }
    }

    // MARK: - EF_FLASHER (99)

    /// Spawns blinding thunder sphere flare (`PP_3DTEXTURE` (15)) and 20 rising 2D flashes (`PP_2DFLASH` (3)) for `EF_FLASHER` (99).
    func flasher(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\hunter_flasher.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let centerTex = "effect\\thunder_center.bmp"
        let flashTex = "EFFECT\\alpha_center.tga"
        _ = context.assets?.texture(atPath: centerTex)
        _ = context.assets?.texture(atPath: flashTex)

        let glow = launchPrimitive(.pp_3dtexture)
        glow.state.duration = 70
        glow.state.pattern = 65
        glow.state.renderFlag |= EffectPrimitiveState.RenderFlag.additive
        glow.state.deltaPos2.y = -10.0
        glow.state.widthSize = 20.0
        glow.state.heightSize = 20.0
        glow.state.alpha = 0
        glow.state.maxAlpha = 200.0
        glow.state.alphaSpeed = glow.state.maxAlpha / 6.0
        glow.state.alphaCycle = 1
        glow.state.chPoint = [40.0, 100.0]
        glow.state.chVal1 = [120.0, 0.0]
        glow.state.chVal2 = [200.0, 80.0]
        glow.state.fadeOutCnt = glow.state.duration - 10
        glow.state.texturePaths = [centerTex]

        for _ in 0..<20 {
            let flash = launchPrimitive(.pp_2dflash)
            flash.state.duration = 70
            flash.state.deltaPos2.y = -40.0
            flash.state.longitude = Float(Int.random(in: 0..<360))
            flash.state.longSpeed = Float(Int.random(in: 0..<60) + 10) / 10.0
            flash.state.longAccel = -(flash.state.longSpeed / Float(flash.state.duration)) / 1.5
            flash.state.arcAngle = Float(Int.random(in: 0..<25) + 5) / 10.0
            flash.state.heightSize = Float(Int.random(in: 0..<40) + 20)
            flash.state.heightSpeed = Float(Int.random(in: 0..<30) + 50) / 10.0
            flash.state.alpha = 0
            flash.state.maxAlpha = 200.0
            flash.state.alphaSpeed = flash.state.maxAlpha / 10.0
            flash.state.fadeOutCnt = flash.state.duration - flash.state.duration / 3
            flash.state.texturePaths = [flashTex]
        }
    }

    // MARK: - Inline OnProcess Cases (0...99)

    private func processBeginSpellTexturedRing(texturePath: String, kind: Int, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_BeginSpell.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
        texturedQuadRingSized(baseAlpha: 45, texturePath: texturePath, kind: kind, context: context)
        texturedQuadRingSized(baseAlpha: 25, texturePath: texturePath, kind: kind, context: context)
    }

    private func processBeginSpellQuadStack(texturePath: String, kind: Int, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_BeginSpell.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
        quadRingStackSized(texturePath: texturePath, kind: kind, context: context)
    }

    private func processRuwach(context: EffectTickContext) {
        guard stateCnt % 3 == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle2.spr")
        let actionPath = K2L("이팩트\\particle2.act")
        let shadowSprite = "Shadow.spr"
        let shadowAction = "Shadow.act"
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)
        _ = context.assets?.spriteAsset(spritePath: shadowSprite, actionPath: shadowAction)

        let angle = Int(Float(stateCnt) / 1.3 * -5.0)
        let offsetX = EffectSpace.sine(degrees: angle) * 15.0
        let offsetZ = EffectSpace.cosine(degrees: angle) * -15.0

        let particle = launchPrimitive(.pp_3dparticle)
        particle.state.duration = 25
        particle.state.deltaPos2 = SIMD3<Float>(offsetX, -10.0, offsetZ)
        particle.state.spritePath = spritePath
        particle.state.actionPath = actionPath
        particle.state.size = 3.0
        particle.state.sizeSpeed = -0.1
        particle.state.alpha = 250.0
        particle.state.alphaSpeed = -3.0
        particle.state.fadeOutCnt = particle.state.duration - 6
        particle.initSegment()

        let shadow = launchPrimitive(.pp_3dparticle)
        shadow.state.duration = 25
        shadow.state.deltaPos2 = SIMD3<Float>(offsetX, 0, offsetZ)
        shadow.state.spritePath = shadowSprite
        shadow.state.actionPath = shadowAction
        shadow.state.animSpeed = 2
        shadow.state.size = 1.5
        shadow.state.sizeSpeed = -0.06
        shadow.state.alpha = 150.0
        shadow.state.alphaSpeed = -2.5
        shadow.state.fadeOutCnt = shadow.state.duration - 6
        shadow.initSegment()
    }

    private func processTeleportation(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_Teleportation.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = "effect\\ring_blue.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let cylinder = launchPrimitive(.pp_3dcylinder)
        cylinder.state.duration = 60
        cylinder.state.pattern |= 1
        cylinder.state.outerSize = 4.0
        cylinder.state.innerSize = 4.0
        cylinder.state.heightSpeed = 5.0
        cylinder.state.heightAccel = 0.25
        cylinder.state.longSpeed = 2.0
        cylinder.state.fadeOutCnt = 0
        cylinder.state.texturePaths = [texturePath]
    }

    private func processReadyPortal(context: EffectTickContext) {
        guard stateCnt % 14 == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_ReadyPortal.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = "effect\\ring_blue.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let ring = launchPrimitive(.pp_3dcircle)
        ring.state.duration = 30
        ring.state.deltaPos2.y = -1.0
        ring.state.innerSize = 8.0
        ring.state.latitude = 90.0
        ring.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(ring.state.latitude)))
        ring.state.radiusSpeed = 1.0
        ring.state.radiusAccel = -(ring.state.radiusSpeed / Float(ring.state.duration)) * 0.5
        ring.state.fadeOutCnt = ring.state.duration - ring.state.duration / 2
        ring.initSegment()
        ring.state.texturePaths = [texturePath]
    }

    private func processAqua(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_Aqua.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let spritePath = K2L("이팩트\\성수뜨기.spr")
        let actionPath = K2L("이팩트\\성수뜨기.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let particle = launchPrimitive(.pp_3dparticle)
        particle.state.duration = duration
        particle.state.deltaPos2.y = -20.0
        particle.state.animSpeed = 2
        particle.state.repeatAnim = false
        particle.state.spritePath = spritePath
        particle.state.actionPath = actionPath
        particle.initSegment()
    }

    private func processSmoke(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\굴뚝연기.spr")
        let actionPath = K2L("이팩트\\굴뚝연기.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let puffCount = Int.random(in: 0..<4) + 1
        for _ in 0..<puffCount {
            let smoke = launchPrimitive(.pp_3dparticle)
            smoke.state.duration = duration
            let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int.random(in: 0..<30) + 75))
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
            smoke.state.transform = rotY * rotX
            smoke.state.deltaPos2.y = -9.0
            smoke.state.rollSpeed = 0.75
            smoke.state.speed = Float(Int.random(in: 0..<3) + 3) / 10.0
            smoke.state.size = 1.5
            smoke.state.fadeOutCnt = smoke.state.duration - smoke.state.duration / 3
            smoke.state.spritePath = spritePath
            smoke.state.actionPath = actionPath
            smoke.initSegment()
        }
    }

    private func processTorch(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\torch_01.spr")
        let actionPath = K2L("이팩트\\torch_01.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        if param[0] <= 0 {
            param[0] = 1.0
        }
        if param[1] < 1.0 {
            param[1] = 1.0
        }

        let torch = launchPrimitive(.pp_3dparticle)
        torch.state.pattern |= 0x200
        torch.state.duration = duration
        torch.state.deltaPos2.y = -10.0
        torch.state.size = param[0]
        torch.state.animSpeed = Int(param[1])
        torch.state.spritePath = spritePath
        torch.state.actionPath = actionPath
        torch.initSegment()
    }

    private func processFireSplashHit(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\FireRing.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let ring = launchPrimitive(.pp_2dtexture)
        ring.state.duration = 30
        ring.state.deltaPos2.y = -20.0
        ring.state.widthSize = 10.0
        ring.state.heightSize = 10.0
        ring.state.widthSpeed = 5.7
        ring.state.heightSpeed = 5.7
        ring.state.roll = Float(Int.random(in: 0..<360))
        ring.state.rollSpeed = -18.0
        ring.state.rollAccel = -(ring.state.rollSpeed / Float(ring.state.duration)) / 2.5
        ring.state.fadeOutCnt = ring.state.duration - ring.state.duration / 2
        ring.state.texturePaths = [texturePath]
        ring.state.slots[0].life = 0
    }

    private func processPoisonHit(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\PoisonHit.spr")
        let actionPath = K2L("이팩트\\PoisonHit.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let hit = launchPrimitive(.pp_3dparticle)
        hit.state.duration = duration
        hit.state.size = 1.5
        hit.state.animSpeed = 2
        hit.state.pattern |= 0x200
        hit.state.repeatAnim = false
        hit.state.spritePath = spritePath
        hit.state.actionPath = actionPath
        hit.initSegment()
    }

    private func processBarrier(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = K2L("effect\\대폭발.tga")
        _ = context.assets?.texture(atPath: texturePath)

        let sphere = launchPrimitive(.pp_3dsphere)
        sphere.state.duration = 250
        sphere.state.radius = 13.5
        sphere.state.deltaPos2.y = -10.0
        sphere.state.longitude = 2.0
        sphere.state.alpha = 100.0
        sphere.state.texturePaths = [texturePath]
    }

    private func processCone(context: EffectTickContext) {
        guard stateCnt % 130 == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        duration = 200
        let orbit = launchPrimitive(.pp_3dparticleorbit)
        orbit.state.duration = 300
        orbit.state.radius = 0.1
        orbit.state.radiusSpeed = 0.2
        orbit.state.gravSpeed = 0.1
        orbit.state.gravAccel = 0.005
        orbit.state.longitude = 2.0
        orbit.state.longSpeed = 15.0
        orbit.state.longAccel = -0.01
        orbit.state.size = 1.2
        orbit.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(orbit.state.longitude)))
        orbit.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, -30.0, orbit.state.radius), by: orbit.state.transform)
        orbit.state.spritePath = spritePath
        orbit.state.actionPath = actionPath
        orbit.initSegment()
    }
}
