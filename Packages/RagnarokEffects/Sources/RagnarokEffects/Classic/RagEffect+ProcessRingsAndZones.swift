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

    // MARK: - EF_LEVEL99 (200)

    /// Spawns 3-layer Level 99 aura ribbons (`PP_3DCASTING` (23)) for `EF_LEVEL99` (200).
    func tripleRingStack(texturePath: String, large: Int8, context: EffectTickContext) {
        if stateCnt == 99_999_998 {
            stateCnt = 0
            duration = 99_999_999
        } else if stateCnt != 0 {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_3dcasting)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = large == 1 ? 7.0 : 4.0

        let configs: [(maxHeight: Float, rotStart: Int16, distance: Float, riseAngle: Int16)] = [
            (15.0, 0, 3.9, 55),
            (13.0, 90, 4.1, 50),
            (11.0, 180, 4.3, 45),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 315
            primitive.state.slots[index].maxHeight = config.maxHeight
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = 120
            primitive.state.slots[index].distance = config.distance
            primitive.state.slots[index].riseAngle = config.riseAngle
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
        primitive.state.slots[3].life = 0
    }

    // MARK: - EF_LEVEL99_3 (202)

    /// Spawns multi-slot orbital Level 99 mist ribbons (`29`) for `EF_LEVEL99_3` (202).
    func freezingCircle(kind: Int8, context: EffectTickContext) {
        if stateCnt == 99_999_998 {
            stateCnt = 0
            duration = 99_999_999
        } else if stateCnt != 0 {
            return
        }

        let texturePath: String
        let size: Float
        if kind == 3 {
            texturePath = "effect\\ghost.bmp"
            size = 0
        } else if kind >= 1 {
            texturePath = "effect\\whitelight.tga"
            size = kind == 2 ? 7.0 : 0
        } else {
            texturePath = "effect\\freezing_circle.bmp"
            size = 0
        }
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(29)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = size

        for i in 0..<4 {
            if kind == 3 && i >= 1 {
                primitive.state.slots[i].life = 0
            } else if (kind == 7 || kind == 8) && i >= 2 {
                primitive.state.slots[i].life = 0
            } else {
                primitive.state.slots[i].life = 1
            }

            primitive.state.slots[i].maxHeight = 0.15
            if kind == 1 || kind == 4 || kind == 5 || kind == 6 || kind >= 8 {
                primitive.state.slots[i].distance = 2.4
            } else if kind == 3 {
                primitive.state.slots[i].distance = 3.2
                primitive.state.slots[i].maxHeight = 0.6
            } else {
                primitive.state.slots[i].distance = 0.8
            }

            func randomAnchorXZ() -> (x: Float, z: Float) {
                if kind == 3 {
                    return (Float(Int.random(in: 0..<15) - 8), Float(Int.random(in: 0..<15) - 8))
                } else if kind == 6 {
                    return (Float(Int.random(in: 0..<35) - 17), 0)
                }
                return (0, 0)
            }

            let bPre = randomAnchorXZ()
            primitive.state.slots[i].vecBPre = SIMD3<Float>(bPre.x, Float(Int.random(in: 0..<100)), bPre.z)
            let bNow = randomAnchorXZ()
            primitive.state.slots[i].vecBNow = SIMD3<Float>(bNow.x, Float(Int.random(in: 0..<100)), bNow.z)
            let tPre = randomAnchorXZ()
            primitive.state.slots[i].vecTPre = SIMD3<Float>(tPre.x, Float(Int.random(in: 0..<100)), tPre.z)
            let tNow = randomAnchorXZ()
            primitive.state.slots[i].vecTNow = SIMD3<Float>(tNow.x, Float(Int.random(in: 0..<100)), tNow.z)

            for h in 0..<16 {
                primitive.state.slots[i].height[h] = Float(Int.random(in: 0..<360))
            }

            if kind == 4 {
                primitive.state.slots[i].vecBPre.y = -40.0
                primitive.state.slots[i].vecBNow.y = -50.0
                primitive.state.slots[i].vecTPre.y = -60.0
                primitive.state.slots[i].vecTNow.y = -70.0
            } else if kind == 5 || kind == 7 {
                primitive.state.slots[i].vecBPre.y = 0
                primitive.state.slots[i].vecBNow.y = 0
                primitive.state.slots[i].vecTPre.y = 0
                primitive.state.slots[i].vecTNow.y = 0
            } else if kind == 6 {
                primitive.state.slots[i].vecBPre.y = Float(-40 - Int.random(in: 0..<40))
                primitive.state.slots[i].vecBNow.y = Float(-40 - Int.random(in: 0..<40))
                primitive.state.slots[i].vecTPre.y = Float(-40 - Int.random(in: 0..<40))
                primitive.state.slots[i].vecTNow.y = Float(-40 - Int.random(in: 0..<40))
            }

            if kind == 1 {
                primitive.state.slots[i].flag1[0] = kind
            } else if kind == 3 {
                primitive.state.slots[i].flag1[0] = 11
            } else if kind == 4 {
                primitive.state.slots[i].flag1[0] = 14
            } else if kind == 5 || kind == 7 || kind == 8 {
                primitive.state.slots[i].flag1[0] = 15
                primitive.state.slots[i].flag1[1] = 0
                primitive.state.slots[i].flag1[2] = 0
                primitive.state.slots[i].flag1[3] = 0
                primitive.state.slots[i].flag1[4] = 0
                primitive.state.slots[i].flag1[5] = kind
            } else if kind == 6 {
                primitive.state.slots[i].flag1[0] = 16
            } else {
                primitive.state.slots[i].flag1[0] = 0
            }
        }
    }

    // MARK: - EF_DEFENDER (222)

    /// Spawns 4-layer Defender casting shroud (`PP_3DCASTING_2` (24)) for `EF_DEFENDER` (222).
    func quadRingStack(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_3dcasting_2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let rotStarts: [Int16] = [180, 270, 0, 90]
        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = 40.0 - Float(index)
            primitive.state.slots[index].rotStart = rotStarts[index]
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = 8.0 - Float(index) * 0.1
            primitive.state.slots[index].riseAngle = 90
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
    }

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

    /// Spawns orbiting Monk spirit spheres or elemental/coin orbs (`32`) for `EF_CHOOKGI` (228).
    func elementalOrbit(kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let requestedCount = Int(deltaPos.x)
        guard requestedCount > 0 else {
            return
        }
        let sphereCount = min(requestedCount, 5)

        let texturePath: String = switch kind {
        case 10: "effect\\fire-1.bmp"
        case 11: "effect\\lightning-1.bmp"
        case 12: "effect\\water-1.bmp"
        case 13: "effect\\stone-1.bmp"
        case 4: "effect\\RL_richs_coin_B\\rcoin1.bmp"
        default: "effect\\thunder_center.bmp"
        }
        _ = context.assets?.texture(atPath: texturePath)

        for index in 0..<sphereCount {
            let sphere = launchPrimitive(32)
            sphere.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            sphere.state.duration = duration
            sphere.state.slots[0].life = 1
            for h in 0..<6 {
                sphere.state.slots[0].height[h] = Float(Int.random(in: 0..<360))
            }

            if kind == 1 {
                sphere.state.slots[0].height[6] = Float(index * 72)
                sphere.state.slots[0].height[7] = -14.0
                sphere.state.slots[0].distance = 1.3
                sphere.state.slots[0].height[10] = 1.0
                sphere.state.slots[0].flag1[0] = 0
            } else if kind == 3 || kind == 4 {
                if deltaPos.x <= 5.0 {
                    sphere.state.slots[0].height[6] = Float(index * 360) / deltaPos.x
                } else {
                    sphere.state.slots[0].height[6] = Float(index * 72)
                }
                sphere.state.slots[0].height[7] = -15.0
                sphere.state.slots[0].distance = 1.0
                if deltaPos.x > 5.0 && deltaPos.x - Float(index) >= 6.0 {
                    sphere.state.slots[0].distance = 2.0
                }
                sphere.state.slots[0].height[10] = 0
                sphere.state.slots[0].flag1[0] = 1
            } else {
                sphere.state.slots[0].height[6] = Float(index * 72)
                sphere.state.slots[0].height[7] = -15.0
                sphere.state.slots[0].distance = 2.0
                sphere.state.slots[0].height[10] = 0
                sphere.state.slots[0].flag1[0] = 0

                let total = deltaPos.x
                if total > 10.0 {
                    sphere.state.slots[0].flag1[0] = (total - Float(index) >= 11.0) ? 21 : 20
                } else if total > 5.0 && (total - Float(index) >= 6.0) {
                    sphere.state.slots[0].flag1[0] = 20
                }

                if kind >= 10 {
                    var startAngle = sphere.state.slots[0].height[6] + Float(Int.random(in: 0..<360))
                    if startAngle >= 360.0 {
                        startAngle -= 360.0
                    }
                    sphere.state.slots[0].height[6] = startAngle
                    sphere.state.slots[0].flag1[0] = kind
                    sphere.state.slots[0].distance = 6.0
                    sphere.state.totalTexture = 1
                }
            }

            sphere.state.slots[0].height[8] = Float(Int.random(in: 0..<360))
            sphere.state.slots[0].alphaB = 0
            sphere.state.slots[0].process = 0
            sphere.state.texturePaths = [texturePath]
        }
    }

    // MARK: - EF_MAGICROD (244)

    /// Plays Magic Rod absorption audio on frame 0 for `EF_MAGICROD` (244).
    func sageMagicRod(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\sage_magic rod.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
    }

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
