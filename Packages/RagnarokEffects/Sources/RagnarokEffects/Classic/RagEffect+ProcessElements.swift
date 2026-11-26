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

    // MARK: - Shared Directional Helpers

    static func effectHeading(fromX x: Float, fromZ z: Float, toX targetX: Float, toZ targetZ: Float) -> Float {
        let deltaX = targetX - x
        let deltaZ = targetZ - z
        var angle = (atan2f(deltaX, -deltaZ) / EffectSpace.clientPi) * 180.0
        if angle >= 360.0 {
            angle -= 360.0
        }
        if angle < 0.0 {
            angle += 360.0
        }
        return angle
    }

    static func effectDistanceXZ(from: SIMD3<Float>, to: SIMD3<Float>) -> Float {
        let dx = to.x - from.x
        let dz = to.z - from.z
        return sqrtf(dz * dz + dx * dx)
    }

    func directionalLaunchEndpoints() -> (origin: SIMD3<Float>, destination: SIMD3<Float>) {
        let origin = sourcePosition ?? position
        let destination = sourcePosition != nil
            ? position
            : (deltaPos == .zero ? position + SIMD3<Float>(25, 0, 0) : deltaPos)
        return (origin, destination)
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

    // MARK: - EF_METEORSTORM (92)
    // CRagEffect::MeteorStorm()

    // MARK: - EF_FIREPILLAR (96)
    // CRagEffect::FirePillar()

    // MARK: - EF_FIREPILLARBOMB (97)
    // CRagEffect::FirePillarImpact()

    // MARK: - EF_CRASHEARTH (102)
    // CRagEffect::FirePillarBomb()

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
