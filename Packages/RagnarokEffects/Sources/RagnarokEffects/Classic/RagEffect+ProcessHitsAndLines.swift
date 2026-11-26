//
//  RagEffect+ProcessHitsAndLines.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {

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

    // MARK: - EF_THUNDERSTORM (30)
    // CRagEffect::Thunderstorm()

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

    // MARK: - EF_GUMGANG (203)

    /// Spawns sweeping aura fan streaks (`35`) for `EF_GUMGANG` (203).
    func superSlashFan(count: Int8, value: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePaths = (1...5).map { "effect\\super\($0).bmp" }
        for path in texturePaths {
            _ = context.assets?.texture(atPath: path)
        }

        let fan = launchPrimitive(35)
        fan.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        fan.state.duration = duration
        fan.state.totalTexture = 5
        fan.state.texturePaths = texturePaths
        for i in 0..<4 {
            fan.state.slots[i].life = 0
        }

        for i in 0..<max(0, Int(count)) where i < 4 {
            fan.state.slots[i].life = 1
            fan.state.slots[i].distance = 3.5
            fan.state.slots[i].vecBPre.y = -Float(Int.random(in: 0..<10))
            fan.state.slots[i].height[0] = 10.0
            fan.state.slots[i].height[1] = 70.0
            fan.state.slots[i].height[2] = Float(Int.random(in: 0..<5))
            fan.state.slots[i].height[3] = Float(Int.random(in: 0..<360))
            fan.state.slots[i].vecBNow.y = -Float(Int.random(in: 0..<10))
            fan.state.slots[i].height[4] = 10.0
            fan.state.slots[i].height[5] = 130.0
            fan.state.slots[i].height[6] = Float(Int.random(in: 0..<5))
            fan.state.slots[i].height[7] = Float(Int.random(in: 0..<360))
            fan.state.slots[i].vecTPre.y = -Float(Int.random(in: 0..<10))
            fan.state.slots[i].height[8] = 10.0
            fan.state.slots[i].height[9] = 190.0
            fan.state.slots[i].height[10] = Float(Int.random(in: 0..<5))
            fan.state.slots[i].height[11] = Float(Int.random(in: 0..<360))
            fan.state.slots[i].vecTNow.y = -Float(Int.random(in: 0..<10))
            fan.state.slots[i].height[12] = 10.0
            fan.state.slots[i].height[13] = 250.0
            fan.state.slots[i].height[14] = Float(Int.random(in: 0..<5))
            fan.state.slots[i].height[15] = Float(Int.random(in: 0..<360))
            fan.state.slots[i].flag1[4] = value
        }
    }

    // MARK: - EF_TEIHIT2 (264)
    // CRagEffect::TEIHIT2()

    // MARK: - EF_CHEMICAL2 (303)
    // CRagEffect::SlashFan(std::int16_t reverse)

    // MARK: - EF_SPRINKLESAND (310)
    // CRagEffect::ThunderSparks()

    // MARK: - EF_HITLINE (330)

    /// Emits `PP_HITLINE` (70) bouncing white spark trails for `EF_HITLINE` (330).
    func whiteSparks(kind: Int16, context: EffectTickContext) {
        guard stateCnt >= 0, stateCnt <= 3 else {
            return
        }

        let texturePath = "effect\\white02.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_hitline)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = -Int.random(in: 0..<26)
            primitive.state.slots[index].maxHeight = 0.1
            primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<51) + 125)
            primitive.state.slots[index].riseAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<8)) + 6.0
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].height[0] = 0
            primitive.state.slots[index].vecBNow = position
            primitive.state.slots[index].alphaT = kind
        }
    }

    // MARK: - EF_SOULBREAKER (361)
    // CRagEffect::SonicWave(char sonic)

    // MARK: - EF_ENERGYDRAIN3 (383)
    // CRagEffect::SonicSlashFan(char kind)

    // MARK: - EF_SOULBREAKER2 (409)
    // CRagEffect::PurpleSlash(int angle)

    // MARK: - EF_DOUBLEGUMGANG (418)
    // CRagEffect::SuperSlashSpread(char count, char value)

    // MARK: - EF_HITLINE3 (428)

    /// Emits `PP_HITLINE3` (100) short spark streaks for `EF_HITLINE3` (428), `EF_HITLINE6` (431), and `EF_HITLINE7` (434).
    func whiteSparkStreak(kind: Int16, context: EffectTickContext) {
        let limit = if kind == 1 { 2 } else if kind == 3 { 5 } else { 0 }
        guard stateCnt >= 0, stateCnt < limit else {
            return
        }

        let texturePath = "effect\\white02.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_hitline3)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1

            if kind == 1 {
                primitive.state.slots[index].process = -Int.random(in: 0..<11)
                primitive.state.slots[index].maxHeight = 0.1
                primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<51) + 125)
                primitive.state.slots[index].distance = Float(Int.random(in: 0..<5)) + 5.0
                primitive.state.slots[index].vecTNow.y = 3.0
            } else if kind == 3 {
                primitive.state.slots[index].process = -30 - Int.random(in: 0..<41)
                primitive.state.slots[index].maxHeight = 0.07
                primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<121) + 125)
                primitive.state.slots[index].distance = Float(Int.random(in: 0..<6)) + 6.0
                primitive.state.slots[index].vecTNow.y = 4.0
            } else {
                primitive.state.slots[index].process = -Int.random(in: 0..<26)
                primitive.state.slots[index].maxHeight = 0.1
                primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<(kind >= 3 ? 121 : 51)) + 125)
                primitive.state.slots[index].distance = Float(Int.random(in: 0..<6)) + 6.0
                primitive.state.slots[index].vecTNow.y = 5.0
            }

            primitive.state.slots[index].riseAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].height[0] = 0
            primitive.state.slots[index].vecTNow.x = Float(Int.random(in: 0..<7)) * 0.1 + 0.6
            primitive.state.slots[index].vecBNow = position
            primitive.state.slots[index].alphaT = kind

            if kind == 1 {
                let tailCount = Int(primitive.state.slots[index].vecTNow.y)
                for _ in 0..<10 {
                    primitive.state.slots[index].height[0] = min(180.0, primitive.state.slots[index].height[0] + 6.0)
                    for layer in stride(from: tailCount, through: 1, by: -1) {
                        primitive.state.slots[index].height[layer] = primitive.state.slots[index].height[layer - 1]
                    }
                }
            }
        }
    }

    // MARK: - EF_ELECTRIC2 (433)

    /// Spawns `PP_ELECTRIC2` (102) directional lightning tubes for `EF_ELECTRIC2` (433).
    func electricArc(kind: Int16, angle: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\elec1.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_electric2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let heading = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z)
        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = 0.1
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].riseAngle = heading
            primitive.state.slots[index].distance = 0
            primitive.state.slots[index].height[0] = index < 2 ? Float(index * 180) : Float(index * 180 - 360)
            primitive.state.slots[index].vecTNow.x = Float(Int.random(in: 0..<6)) * 0.01 + 0.2
            primitive.state.slots[index].vecBNow = position
            primitive.state.slots[index].vecTNow.y = 20.0
            for step in 1...20 {
                primitive.state.slots[index].height[step] = 0
            }
            primitive.state.slots[index].alphaT = kind
        }
    }

    // MARK: - EF_CHEMICAL3 (439)
    // CRagEffect::LineStreakLayered(short kind)

    // MARK: - EF_YELLOWFLY1 (713)
    // CRagEffect::WhiteLightSparkle(char kind)

    // MARK: - EF_CIRCLEPOWER (757)
    // CRagEffect::EmpShockBurst(const char* name, char flag)

    // MARK: - EF_INFRAREDSCAN (794)

    /// Spawns primitive `135` sweeping electric jitter arcs for `EF_INFRAREDSCAN` (794).
    func electricFan(fade: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\elec1.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(135)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let facingDegrees = (targetObjectID ?? ownerObjectID)
            .flatMap { context.world.targetState(for: $0)?.facingAngle } ?? 0
        var initialAngle = Int16(Int(facingDegrees) - 90)
        if initialAngle < 0 {
            initialAngle += 360
        }

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = 0.1
            primitive.state.slots[index].alphaB = index == 0 ? 250 : Int16(140 - index * 30)
            primitive.state.slots[index].riseAngle = initialAngle
            primitive.state.slots[index].distance = 20.0
            primitive.state.slots[index].height[0] = 0
            primitive.state.slots[index].vecTNow.x = Float(Int.random(in: 0..<11)) * 0.01
            primitive.state.slots[index].vecBNow = SIMD3<Float>(position.x, position.y - 10.0, position.z)
            primitive.state.slots[index].vecTNow.y = 20.0
            for step in 1...20 {
                primitive.state.slots[index].height[step] = 0
                primitive.state.slots[index].flag1[step] = 0
            }
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].alphaT = fade
            primitive.state.slots[index].fullDisplayAngle = 0
        }
    }

    // MARK: - EF_ENERVATION (813)
    // CRagEffect::TintedRisingSparkles(char)

    // MARK: - EF_CHOOKGI_N (833)
    // CRagEffect::ThunderFreeze(int)

    // MARK: - EF_CHEMICAL2DASH3 (836)
    // CRagEffect::LineStreakTextured(std::int16_t kind, const char* name)

    // MARK: - EF_DANCE1 (847)
    // CRagEffect::RisingSparkles(char colorMode)

    // MARK: - EF_CHEMICAL3S (893)
    // CRagEffect::LineStreakKind(std::int16_t kind)

    // MARK: - EF_NEW_TRIPLEATTACK (1409)
    // CRagEffect::LineStreak(std::int16_t kind)
}
