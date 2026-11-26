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

    // MARK: - EF_ANGELUS (41)
    // CRagEffect::Angelus()

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

    // MARK: - EF_GLORIA (75)
    // CRagEffect::Gloria()

    // MARK: - EF_MAGNIFICAT (76)
    // CRagEffect::Magnificat()

    // MARK: - EF_RESURRECTION (77)
    // CRagEffect::Resurrection()

    // MARK: - EF_RECOVERY (78)
    // CRagEffect::Recovery()

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

    // MARK: - EF_SANCTUARY (83)
    // CRagEffect::Sanctuary()

    // MARK: - EF_IMPOSITIO (84)
    // CRagEffect::Impositio()

    // MARK: - EF_LEXAETERNA (85)
    // CRagEffect::LexAeterna()

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

    // MARK: - EF_LEXDIVINA (87)
    // CRagEffect::LexDivina()

    // MARK: - EF_SUFFRAGIUM (88)
    // CRagEffect::Suffragium()

    // MARK: - EF_BENEDICTIO (91)
    // CRagEffect::Benedictio()

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

    // MARK: - EF_POISONREACT2 (127)
    // CRagEffect::PoisonReact2()

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

    // MARK: - EF_AUTOCOUNTER (131)
    // CRagEffect::AutoCounter()

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

    // MARK: - EF_CONCENTRATION (153)
    // CRagEffect::Concentration()

    // MARK: - EF_REFINEOK (154)
    // CRagEffect::RefineSuccess()

    // MARK: - EF_REFINEFAIL (155)
    // CRagEffect::RefineFailed()

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

    // MARK: - EF_ENERGYDRAIN (217)

    /// Spawns 3 blue parabolic drain splines (`PP_3DPARTICLESPLINE` (8)) for `EF_ENERGYDRAIN` (217).
    func bloodDrain(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let (origin, destination) = directionalLaunchEndpoints()
        let faceAngle = Self.effectHeading(fromX: origin.x, fromZ: origin.z, toX: destination.x, toZ: destination.z)
        let travelDistance = Self.effectDistanceXZ(from: origin, to: destination)

        for angle in stride(from: -90, to: 180, by: 90) {
            let spline = launchPrimitive(.pp_3dparticlespline)
            spline.state.duration = 60
            spline.state.deltaPos2 = SIMD3<Float>(0, -10.0, 0)
            spline.state.radius = travelDistance
            spline.state.longitude = -faceAngle
            let speed = spline.state.radius / Float(spline.state.duration)
            spline.state.speed = speed + speed
            spline.state.gravSpeed = 2.0
            let rise = -(spline.state.gravSpeed / Float(spline.state.duration))
            spline.state.gravAccel = rise + rise
            spline.state.latiSpeed = -2.0
            let spread = -(spline.state.latiSpeed / Float(spline.state.duration))
            spline.state.latiAccel = spread + spread
            spline.state.roll = Float(angle)
            spline.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spline.state.longitude)))
            let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, 1.0), by: spline.state.transform)
            spline.state.deltaPos3 = forward
            spline.state.rotAxis = forward
            spline.state.red = 100
            spline.state.green = 100
            spline.state.blue = 250
            spline.state.size = 1.7
            spline.state.spritePath = spritePath
            spline.state.actionPath = actionPath
            spline.state.numSegment = 7
            spline.initSegment()
        }
    }

    // MARK: - EF_POTION_CON (218)

    /// Spawns rising fade aura cylinder (`PP_3DCYLINDER` (13)) for potion buffs and `EF_POTIONPILLAR` (221).
    func potionPillar(heightSpeed: Float, pillarDuration: Int, context: EffectTickContext) {
        let texturePath = "effect\\alpha_down.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let cylinder = launchPrimitive(.pp_3dcylinder)
        cylinder.state.duration = pillarDuration
        cylinder.state.outerSize = 4.5
        cylinder.state.innerSize = 4.5
        cylinder.state.heightSize = 10.0
        cylinder.state.heightSpeed = heightSpeed
        cylinder.state.heightAccel = 0.01
        cylinder.state.alpha = 0
        cylinder.state.maxAlpha = 90.0
        cylinder.state.alphaSpeed = cylinder.state.maxAlpha / 20.0
        cylinder.state.fadeOutCnt = cylinder.state.duration - 10
        cylinder.state.texturePaths = [texturePath]
    }

    // MARK: - EF_POTION_BERSERK (220)

    /// Applies red berserk target tint, spawns rising streaks + camera quake, and advances `버서크.str` for `EF_POTION_BERSERK` (220).
    func potionBerserk(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: K2L("버서크.str"))
            potionPillar(heightSpeed: 1.0, pillarDuration: 50, context: context)
        }

        if let targetID = targetObjectID ?? ownerObjectID, stateCnt <= 150 {
            context.world.applyTargetModifier(
                .tint(color: SIMD4<Float>(250.0 / 255.0, 120.0 / 255.0, 120.0 / 255.0, 1.0), durationTicks: 2),
                to: targetID
            )
        }

        if stateCnt == 18 {
            context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
            context.world.playSound(
                named: "effect\\ac_concentration.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        if stateCnt >= 13 && stateCnt <= 109 && stateCnt % 4 == 0 {
            let streakTex = "effect\\ac_center2.tga"
            _ = context.assets?.texture(atPath: streakTex)

            let spot = launchPrimitive(.pp_3dcrosstexture)
            spot.state.duration = 40
            let yaw = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
            spot.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<7) + 2)), by: yaw)
            spot.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: 90))
            spot.state.speed = Float(Int.random(in: 0..<50) + 20) / 60.0
            spot.state.widthSize = Float(Int.random(in: 0..<60) + 30) / 10.0
            spot.state.heightSize = 0.2
            spot.state.red = 240
            spot.state.green = 0
            spot.state.blue = 0
            spot.state.alpha = 0
            spot.state.maxAlpha = 180.0
            spot.state.alphaSpeed = spot.state.maxAlpha / 20.0
            spot.state.fadeOutCnt = spot.state.duration - 20
            spot.state.texturePaths = [streakTex]
            spot.state.slots[0].life = 0
        }

        _ = processEZ2STRRaised(context: context)
        return stateCnt <= 150
    }

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
