//
//  EffectPrimitive+Geometry.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

import Foundation
import RagnarokRendering
import simd

extension EffectPrimitive {

    // MARK: - PP_3DQUADHORN (9)

    /// Motion update for `PP_3DQUADHORN` (9) advancing pyramid horn at 60Hz.
    func advanceEffectPrimitive() {
        let basePosition = master?.position ?? state.orgPos
        state.orgPos = basePosition + state.deltaPos2

        if state.stateCnt == state.changePoint {
            state.speed = state.changeSpeed
            state.accel = state.changeAccel
        }

        state.speed += state.accel
        state.speed3d = EffectSpace.transformVector(SIMD3<Float>(0, 0, state.speed), by: state.transform)
        state.deltaPos += state.speed3d
        position = state.deltaPos + state.orgPos

        if (state.pattern & 1) != 0 && state.stateCnt == Int(state.chCnt) {
            state.accel = 0
            state.speed = 0
        }

        if (state.pattern & 2) != 0 {
            if state.stateCnt == state.duration - 30 {
                state.speed = state.changeSpeed3d.y
                state.accel = state.changeAccel3d.y
            }
        } else {
            processAlpha()
        }
    }

    /// Geometry submission for `PP_3DQUADHORN` (9) and `PP_3DQUADHORN2` (117) four-sided pyramids.
    func renderPyramid(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let s = state.size
        let h = state.heightSize
        let faces: [(SIMD3<Float>, SIMD3<Float>, SIMD3<Float>)] = [
            (SIMD3<Float>(-s, -s, 0), SIMD3<Float>(0, 0, h), SIMD3<Float>(s, -s, 0)),
            (SIMD3<Float>(-s, -s, 0), SIMD3<Float>(0, 0, h), SIMD3<Float>(-s, s, 0)),
            (SIMD3<Float>(-s, s, 0), SIMD3<Float>(0, 0, h), SIMD3<Float>(s, s, 0)),
            (SIMD3<Float>(s, s, 0), SIMD3<Float>(0, 0, h), SIMD3<Float>(s, -s, 0)),
        ]

        let isSparkle = state.slots[0].flag1[0] == 3
        let argb: UInt32
        if isSparkle {
            let r = UInt32(Int.random(in: 0..<11))
            let g = UInt32(Int.random(in: 0..<11))
            argb = (((r << 8) &+ g) << 8) &- 0xD7D701
        } else {
            argb = state.argb
        }

        let color = EffectPrimitiveBatchCollector.unpackARGB(argb)
        let texture = resolveTexture(at: 0, assets: assets)
        let renderState: EffectPrimitiveRenderState = isSparkle
            ? EffectPrimitiveRenderState(srcBlend: .sourceAlpha, dstBlend: .one, depthTest: true, depthWrite: false, cullMode: .none, bucket: .translucent)
            : EffectPrimitiveRenderState(renderFlag: EffectPrimitiveState.RenderFlag.alpha)

        var uVal: Float = 0
        for face in faces {
            let p0 = EffectSpace.transformVector(face.0, by: state.rotTransform) + position
            let p1 = EffectSpace.transformVector(face.1, by: state.rotTransform) + position
            let p2 = EffectSpace.transformVector(face.2, by: state.rotTransform) + position
            let nextU = uVal + 0.2
            let center = (p0 + p1 + p2) * (1.0 / 3.0)

            collector.appendEffectTriangle(
                p0: p0,
                p1: p1,
                p2: p2,
                uv0: SIMD2<Float>(uVal, 1.0),
                uv1: SIMD2<Float>(uVal, 0.0),
                uv2: SIMD2<Float>(nextU, 1.0),
                color0: color,
                color1: color,
                color2: color,
                texture: texture,
                renderState: renderState,
                effectCenter: center
            )
            uVal = nextU
        }
    }

    // MARK: - PP_3DSPLINE (10) / PP_3DSPIRAL (11)

    /// Motion update for `PP_3DSPLINE` (10) and `PP_3DSPIRAL` (11) helical ribbon trails at 60Hz.
    func prim3DSpiral() {
        let basePosition = master?.position ?? state.orgPos
        state.orgPos = basePosition + state.deltaPos2

        let lon0 = Int(state.longitude)
        let lon1 = Int(state.longitude + state.longSpeed)
        let x0 = EffectSpace.sine(degrees: lon0) * state.radius + state.orgPos.x
        let y0 = state.orgPos.y
        let z0 = state.orgPos.z - EffectSpace.cosine(degrees: lon0) * state.radius
        let x1 = EffectSpace.sine(degrees: lon1) * state.radius + state.orgPos.x
        let y1 = state.orgPos.y
        let z1 = state.orgPos.z - EffectSpace.cosine(degrees: lon1) * state.radius

        state.segPos[0] = SIMD3<Float>(x0, y0, z0)
        state.segPos[1] = SIMD3<Float>(x1, y1 + state.heightSpeed, z1)
        state.segPos[2] = SIMD3<Float>(x0, y0 - state.size, z0)
        state.segPos[3] = SIMD3<Float>(x1, y1 + state.heightSpeed - state.size, z1)

        processAlpha()
        shiftSegment()
        state.longitude += state.longSpeed
        state.deltaPos2.y += state.heightSpeed
    }

    /// Geometry submission for `PP_3DSPLINE` (10) and `PP_3DSPIRAL` (11) recorded trail quads.
    func renderRecordQuads(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let renderState = EffectPrimitiveRenderState(renderFlag: EffectPrimitiveState.RenderFlag.alpha)
        let texture = resolveTexture(at: 0, assets: assets)
        let segmentCount = min(max(0, state.numSegment), state.records.count)

        for index in 0..<segmentCount {
            let record = state.records[index]
            let color = EffectPrimitiveBatchCollector.unpackARGB(record.color)
            let c0 = record.corners[0]
            let c1 = record.corners[1]
            let c2 = record.corners[2]
            let c3 = record.corners[3]
            let center = (c0 + c1 + c2 + c3) * 0.25

            collector.appendEffectQuad(
                p0: c0,
                p1: c1,
                p2: c3,
                p3: c2,
                uv0: SIMD2<Float>(0, 1),
                uv1: SIMD2<Float>(1, 1),
                uv2: SIMD2<Float>(1, 0),
                uv3: SIMD2<Float>(0, 0),
                color0: color,
                color1: color,
                color2: color,
                color3: color,
                texture: texture,
                renderState: renderState,
                effectCenter: center
            )
        }
    }

    // MARK: - PP_3DCIRCLE (12)

    /// Motion update for `PP_3DCIRCLE` (12) record rings at 60Hz.
    func prim3DCircle() {
        let basePosition = master?.position ?? state.orgPos
        state.orgPos = basePosition + state.deltaPos2

        if state.changePoint == state.stateCnt {
            state.radiusAccel = state.changeAccel
            state.radiusSpeed = state.changeSpeed
        }

        state.speed += state.accel
        state.longSpeed += state.longAccel
        state.radiusSpeed += state.radiusAccel
        state.innerSpeed += state.innerAccel
        state.longitude += state.longSpeed
        state.radius += state.radiusSpeed
        state.innerSize += state.innerSpeed

        state.transform = makeXYRotation(
            xDegrees: Int(state.latitude),
            yDegrees: Int(state.longitude)
        )

        state.speed3d = EffectSpace.transformVector(SIMD3<Float>(0, 0, state.speed), by: state.transform)
        state.deltaPos += state.speed3d
        position = state.orgPos + state.deltaPos

        if (state.pattern & 1) != 0 || state.radius < state.innerSize {
            state.size = state.radius
        } else {
            state.size = state.innerSize
        }

        processAlpha()
        shiftSegment()
    }

    /// Geometry submission for `PP_3DCIRCLE` (12) recorded trail rings.
    func renderRecordRings(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        guard state.arcAngle > 0 else {
            return
        }

        let renderState = EffectPrimitiveRenderState(renderFlag: state.renderFlag)
        let texture = resolveTexture(at: 0, assets: assets)
        let segmentCount = min(max(0, state.numSegment), state.records.count)
        let maxAngle = 360.0 - state.arcAngle
        var uInc: Float = 0

        for j in 0..<segmentCount {
            let record = state.records[j]
            let innerSize = record.radius - state.size
            let color = EffectPrimitiveBatchCollector.unpackARGB(record.color)

            var angle: Float = 0
            while angle <= maxAngle {
                let cs1 = EffectSpace.cosine(degrees: Int(angle))
                let sn1 = EffectSpace.sine(degrees: Int(angle))
                let cs2 = EffectSpace.cosine(degrees: Int(angle + state.arcAngle))
                let sn2 = EffectSpace.sine(degrees: Int(angle + state.arcAngle))

                let vec1 = EffectSpace.transformVector(
                    SIMD3<Float>(innerSize * cs1, innerSize * sn1, 0),
                    by: state.transform
                ) + record.position
                let vec2 = EffectSpace.transformVector(
                    SIMD3<Float>(innerSize * cs2, innerSize * sn2, 0),
                    by: state.transform
                ) + record.position
                let vec3 = EffectSpace.transformVector(
                    SIMD3<Float>(record.radius * cs1, record.radius * sn1, 0),
                    by: state.transform
                ) + record.position
                let vec4 = EffectSpace.transformVector(
                    SIMD3<Float>(record.radius * cs2, record.radius * sn2, 0),
                    by: state.transform
                ) + record.position

                let center = (vec1 + vec2 + vec3 + vec4) * 0.25
                collector.appendEffectQuad(
                    p0: vec1,
                    p1: vec2,
                    p2: vec4,
                    p3: vec3,
                    uv0: SIMD2<Float>(uInc, 1.0),
                    uv1: SIMD2<Float>(uInc + 0.25, 1.0),
                    uv2: SIMD2<Float>(uInc + 0.25, 0.0),
                    uv3: SIMD2<Float>(uInc, 0.0),
                    color0: color,
                    color1: color,
                    color2: color,
                    color3: color,
                    texture: texture,
                    renderState: renderState,
                    effectCenter: center
                )

                uInc += 0.25
                if uInc >= 1.0 {
                    uInc = 0
                }
                angle += state.arcAngle
            }
        }
    }

    // MARK: - PP_3DCYLINDER (13) / PP_3DCYLINDERHALF (18)

    /// Motion update for `PP_3DCYLINDER` (13) spinning arc bands at 60Hz.
    @discardableResult
    func prim3DCylinder() -> Bool {
        let basePosition = master?.position ?? state.orgPos
        state.orgPos = basePosition + state.deltaPos2

        state.speed += state.accel
        state.heightSpeed += state.heightAccel
        state.outerSpeed += state.outerAccel
        state.innerSpeed += state.innerAccel
        state.longSpeed += state.longAccel
        state.latiSpeed += state.latiAccel
        state.longitude += state.longSpeed
        state.latitude += state.latiSpeed

        state.transform = makeXYRotation(
            xDegrees: Int(state.latitude),
            yDegrees: Int(state.longitude)
        )

        state.speed3d = EffectSpace.transformVector(SIMD3<Float>(0, -state.speed, 0), by: state.transform)
        state.deltaPos += state.speed3d
        position = state.orgPos + state.deltaPos

        state.longitude += state.longSpeed
        state.outerSize += state.outerSpeed
        state.innerSize += state.innerSpeed
        state.heightSize += state.heightSpeed

        if state.heightSize > state.maxHeightSize {
            state.heightSize = state.maxHeightSize
        }

        if (state.pattern & 1) != 0 && state.stateCnt == state.fadeOutCnt {
            let remaining = Float(state.duration - state.stateCnt + 1)
            if remaining != 0 {
                state.outerSpeed = -(state.outerSize / remaining)
            }
        }

        processAlpha()
        return advanceTextureAnimation()
    }

    /// Motion update for `PP_3DCYLINDERHALF` (18) single-step arc bands at 60Hz.
    @discardableResult
    func prim3DCylinderHalf() -> Bool {
        let basePosition = master?.position ?? state.orgPos
        state.orgPos = basePosition + state.deltaPos2

        state.speed += state.accel
        state.outerSpeed += state.outerAccel
        state.innerSpeed += state.innerAccel
        state.heightSpeed += state.heightAccel

        state.transform = makeXYRotation(
            xDegrees: Int(state.latitude),
            yDegrees: Int(state.longitude)
        )

        state.speed3d = EffectSpace.transformVector(SIMD3<Float>(0, -state.speed, 0), by: state.transform)
        state.deltaPos += state.speed3d
        position = state.orgPos + state.deltaPos

        state.longitude += state.longSpeed
        state.outerSize += state.outerSpeed
        state.innerSize += state.innerSpeed
        state.heightSize += state.heightSpeed

        if state.heightSize > state.maxHeightSize {
            state.heightSize = state.maxHeightSize
        }

        if (state.pattern & 1) != 0 && state.stateCnt == state.fadeOutCnt {
            let remaining = Float(state.duration - state.stateCnt + 1)
            if remaining != 0 {
                state.outerSpeed = -(state.outerSize / remaining)
            }
        }

        processAlpha()
        return advanceTextureAnimation()
    }

    /// Geometry submission for `PP_3DCYLINDER` (13) extruded arc bands.
    func renderArcBand(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        guard state.arcAngle > 0 else {
            return
        }

        let renderState = EffectPrimitiveRenderState(renderFlag: EffectPrimitiveState.RenderFlag.alpha)
        let texture = resolveTexture(at: currentMotion, assets: assets)
        let color = EffectPrimitiveBatchCollector.unpackARGB(state.argb)
        let maxAngle = 360.0 - state.arcAngle
        var uInc: Float = 0

        var angle: Float = 0
        while angle <= maxAngle {
            let cs1 = EffectSpace.cosine(degrees: Int(angle))
            let sn1 = EffectSpace.sine(degrees: Int(angle))
            let cs2 = EffectSpace.cosine(degrees: Int(angle + state.arcAngle))
            let sn2 = EffectSpace.sine(degrees: Int(angle + state.arcAngle))

            let vec1 = EffectSpace.transformVector(
                SIMD3<Float>(state.innerSize * cs1, 0, state.innerSize * sn1),
                by: state.transform
            ) + position
            let vec2 = EffectSpace.transformVector(
                SIMD3<Float>(state.innerSize * cs2, 0, state.innerSize * sn2),
                by: state.transform
            ) + position
            let vec3 = EffectSpace.transformVector(
                SIMD3<Float>(state.outerSize * cs1, -state.heightSize, state.outerSize * sn1),
                by: state.transform
            ) + position
            let vec4 = EffectSpace.transformVector(
                SIMD3<Float>(state.outerSize * cs2, -state.heightSize, state.outerSize * sn2),
                by: state.transform
            ) + position

            let center = (vec1 + vec2 + vec3 + vec4) * 0.25
            collector.appendEffectQuad(
                p0: vec1,
                p1: vec2,
                p2: vec4,
                p3: vec3,
                uv0: SIMD2<Float>(uInc, 1.0),
                uv1: SIMD2<Float>(uInc + 0.25, 1.0),
                uv2: SIMD2<Float>(uInc + 0.25, 0.0),
                uv3: SIMD2<Float>(uInc, 0.0),
                color0: color,
                color1: color,
                color2: color,
                color3: color,
                texture: texture,
                renderState: renderState,
                effectCenter: center
            )

            uInc += 0.25
            if uInc >= 1.0 {
                uInc = 0
            }
            angle += state.arcAngle
        }
    }

    private func advanceTextureAnimation() -> Bool {
        let speed = max(1, state.animSpeed)
        guard state.stateCnt % speed == 0 else {
            return true
        }

        let total = max(1, state.texturePaths.isEmpty ? state.totalTexture : state.texturePaths.count)
        currentMotion += 1
        if !state.repeatAnim {
            if currentMotion == total {
                return false
            }
        } else {
            currentMotion %= total
        }
        return true
    }

    // MARK: - PP_3DSPHERE (14)

    /// Motion update for `PP_3DSPHERE` (14) expanding textured sphere at 60Hz.
    func prim3DSphere() {
        let basePosition = master?.position ?? state.orgPos
        state.orgPos = basePosition + state.deltaPos2
        position = state.orgPos
        state.radiusSpeed += state.radiusAccel
        state.radius += state.radiusSpeed
        state.longitude += state.longSpeed
        processAlpha()
    }

    /// Geometry submission for `PP_3DSPHERE` (14) latitude/longitude mesh quads.
    func renderSphere(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        guard state.arcAngle > 0 else {
            return
        }

        let renderState = EffectPrimitiveRenderState(renderFlag: EffectPrimitiveState.RenderFlag.alpha)
        let texture = resolveTexture(at: 0, assets: assets)
        let color = EffectPrimitiveBatchCollector.unpackARGB(state.argb)
        let incU = 1.0 / (360.0 / state.arcAngle)
        let incV = 1.0 / (180.0 / state.arcAngle)
        let maxLongitude = 360.0 - state.arcAngle
        let maxLatitude = 90.0 - state.arcAngle
        let radiusVector = SIMD3<Float>(0, 0, state.radius)

        var vVal: Float = 0
        var lat: Float = -90.0
        while lat <= maxLatitude {
            var uVal: Float = 0
            var lon: Float = 0
            while lon <= maxLongitude {
                let yaw0 = Int(lon + state.longitude)
                let pitch0 = Int(lat)
                let yaw1 = Int(lon + state.arcAngle + 0.25 + state.longitude)
                let pitch1 = Int(lat + state.arcAngle)

                let vec1 = EffectSpace.transformVector(radiusVector, by: makeXYRotation(xDegrees: pitch0, yDegrees: yaw0)) + position
                let vec2 = EffectSpace.transformVector(radiusVector, by: makeXYRotation(xDegrees: pitch1, yDegrees: yaw0)) + position
                let vec3 = EffectSpace.transformVector(radiusVector, by: makeXYRotation(xDegrees: pitch0, yDegrees: yaw1)) + position
                let vec4 = EffectSpace.transformVector(radiusVector, by: makeXYRotation(xDegrees: pitch1, yDegrees: yaw1)) + position

                let center = (vec1 + vec2 + vec3 + vec4) * 0.25
                collector.appendEffectQuad(
                    p0: vec1,
                    p1: vec2,
                    p2: vec4,
                    p3: vec3,
                    uv0: SIMD2<Float>(uVal, vVal),
                    uv1: SIMD2<Float>(uVal, vVal + incV),
                    uv2: SIMD2<Float>(uVal + incU, vVal + incV),
                    uv3: SIMD2<Float>(uVal + incU, vVal),
                    color0: color,
                    color1: color,
                    color2: color,
                    color3: color,
                    texture: texture,
                    renderState: renderState,
                    effectCenter: center
                )

                uVal += incU
                lon += state.arcAngle
            }

            vVal += incV
            lat += state.arcAngle
        }
    }

    // MARK: - PP_GRANDCROSS2 (37)

    /// Motion update for `PP_GRANDCROSS2` (37) cross pillars at 60Hz.
    func primGrandCross2() {
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            if process < 10 {
                state.slots[index].alphaB += 9
            } else {
                state.slots[index].alphaB -= 1
                if state.slots[index].alphaB < 1 {
                    state.slots[index].alphaB = 0
                    if process > 30 {
                        state.slots[index].life = 0
                    }
                }
            }

            state.slots[index].height[1] += 0.005
            state.slots[index].height[0] += 0.005
            state.slots[index].height[2] = EffectSpace.sine(degrees: process) * state.slots[index].maxHeight
        }
    }

    /// Geometry submission for `PP_GRANDCROSS2` (37) pillar walls and end caps.
    func renderGrandCross2(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        for ec in 0..<4 where state.slots[ec].life == 1 && state.slots[ec].alphaB > 0 {
            let cs1 = EffectSpace.cosine(degrees: Int(state.slots[ec].rotStart))
            let sn1 = EffectSpace.sine(degrees: Int(state.slots[ec].rotStart))
            let halfLength = state.slots[ec].height[0]
            let halfWidth = state.slots[ec].height[1]
            let pillarHeight = state.slots[ec].height[2]

            let bPre = SIMD3<Float>(cs1 * halfLength - sn1 * halfWidth, -1.0, sn1 * halfLength + cs1 * halfWidth)
            let bNow = SIMD3<Float>(cs1 * halfLength + sn1 * halfWidth, -1.0, sn1 * halfLength - cs1 * halfWidth)
            let tNow = SIMD3<Float>(-cs1 * halfLength + sn1 * halfWidth, -1.0, -sn1 * halfLength - cs1 * halfWidth)
            let tPre = SIMD3<Float>(-cs1 * halfLength - sn1 * halfWidth, -1.0, -sn1 * halfLength + cs1 * halfWidth)

            let vec1 = SIMD3<Float>(bPre.x, bPre.y - pillarHeight, bPre.z)
            let vec2 = SIMD3<Float>(bNow.x, bNow.y - pillarHeight, bNow.z)
            let vec3 = SIMD3<Float>(tPre.x, tPre.y - pillarHeight, tPre.z)
            let vec4 = SIMD3<Float>(tNow.x, tNow.y - pillarHeight, tNow.z)

            let alpha = state.slots[ec].alphaB
            renderTeiRect(into: &collector, assets: assets, alpha: alpha, v1: bPre, v2: bNow, v3: vec2, v4: vec1, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 255, green: 255, blue: 255)
            renderTeiRect(into: &collector, assets: assets, alpha: alpha, v1: bNow, v2: tNow, v3: vec4, v4: vec2, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 255, green: 255, blue: 255)
            renderTeiRect(into: &collector, assets: assets, alpha: alpha, v1: tNow, v2: tPre, v3: vec3, v4: vec4, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 255, green: 255, blue: 255)
            renderTeiRect(into: &collector, assets: assets, alpha: alpha, v1: tPre, v2: bPre, v3: vec1, v4: vec3, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 255, green: 255, blue: 255)

            let capAlpha = alpha / 2
            renderTeiRect(into: &collector, assets: assets, alpha: capAlpha, v1: bPre, v2: bNow, v3: tNow, v4: tPre, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: 255, green: 255, blue: 255)
            renderTeiRect(into: &collector, assets: assets, alpha: capAlpha, v1: tPre, v2: tNow, v3: bNow, v4: bPre, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: 255, green: 255, blue: 255)
        }
    }

    // MARK: - PP_GUARD (61)

    /// Motion update for `PP_GUARD` (61) multi-layer defensive sphere cage at 60Hz.
    func primGuard(context: EffectTickContext) {
        followMaster()
        let parentAngle = parentFacingAngle(world: context.world)

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            if process <= 1 {
                state.slots[index].rotStart = Int16(parentAngle + 270.0)
            } else if state.slots[index].flag1[0] == 1 {
                state.slots[index].rotStart += 10
            } else {
                state.slots[index].rotStart = Int16(parentAngle + 270.0)
            }

            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            if process < 10 {
                if state.slots[index].alphaB < 100 {
                    state.slots[index].alphaB += 20
                }
            } else if process > 26 {
                state.slots[index].height[0] += 0.1
                if state.slots[index].alphaB > 0 {
                    state.slots[index].alphaB -= 6
                }
                if state.slots[index].alphaB < 0 {
                    state.slots[index].alphaB = 0
                }
            }
        }
    }

    /// Geometry submission for `PP_GUARD` (61) concentric sphere cage panels.
    func renderSphereCage(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        for ec in 0..<4 where state.slots[ec].life == 1 {
            let alpha = state.slots[ec].alphaB
            let maxHeight = state.slots[ec].maxHeight
            let rotStart = Int(state.slots[ec].rotStart)
            let kind = state.slots[ec].flag1[0]
            let spread = state.slots[ec].height[0]

            for count2 in 0..<3 {
                for count in 0..<5 {
                    let add = count * 45 - 90
                    let add2 = count2 * 45 - 45

                    var dist = Float(count2 - 1)
                    if dist < 0 {
                        dist = -dist
                    }
                    dist = 1.5 - dist + 1.5

                    let quadSize = Int(dist)
                    let negQuadSize = Int(-dist)

                    let layers: [(radius: Float, yOffset: Float, blendSelector: Int16, textureIndex: Int, defaultColor: (UInt8, UInt8, UInt8))] = [
                        (maxHeight, -(maxHeight + 2.0), 0, 0, (205, 255, 205)),
                        (maxHeight + 0.2, -maxHeight, 0, 0, (155, 255, 155)),
                        (maxHeight + 0.4 + spread, -maxHeight, kind == 5 ? 0 : 1, kind == 5 ? 0 : 1, (225, 255, 225)),
                    ]

                    for layer in layers {
                        let latAngle = ((add2 % 360) + 360) % 360
                        let snLat = EffectSpace.sine(degrees: latAngle)
                        let csLat = EffectSpace.cosine(degrees: latAngle)

                        let lonAngle = (((rotStart + add) % 360) + 360) % 360
                        let csLon = EffectSpace.cosine(degrees: lonAngle)
                        let snLon = EffectSpace.sine(degrees: lonAngle)

                        let rz = layer.radius * csLat
                        let center = SIMD3<Float>(
                            rz * csLon,
                            layer.radius * snLat + layer.yOffset,
                            rz * snLon
                        )

                        let tangLat = (((90 + add2) % 360) + 360) % 360
                        let cs2 = EffectSpace.cosine(degrees: tangLat)
                        let sn2 = EffectSpace.sine(degrees: tangLat)

                        let tangLon = (((rotStart + add - 90) % 360) + 360) % 360
                        let cs1 = EffectSpace.cosine(degrees: tangLon)
                        let sn1 = EffectSpace.sine(degrees: tangLon)

                        let vec1 = guardPoint(rx: quadSize, ry: quadSize, sn2: sn2, cs2: cs2, sn1: sn1, cs1: cs1, center: center)
                        let vec2 = guardPoint(rx: negQuadSize, ry: quadSize, sn2: sn2, cs2: cs2, sn1: sn1, cs1: cs1, center: center)
                        let vec3 = guardPoint(rx: negQuadSize, ry: negQuadSize, sn2: sn2, cs2: cs2, sn1: sn1, cs1: cs1, center: center)
                        let vec4 = guardPoint(rx: quadSize, ry: negQuadSize, sn2: sn2, cs2: cs2, sn1: sn1, cs1: cs1, center: center)

                        let (red, green, blue): (UInt8, UInt8, UInt8) = switch kind {
                        case 3: (255, 100, 0)
                        case 2: (255, 155, 0)
                        case 4: (255, 150, 255)
                        case 5: (100, 100, 255)
                        default: layer.defaultColor
                        }

                        renderTeiRect(
                            into: &collector,
                            assets: assets,
                            alpha: alpha,
                            v1: vec1,
                            v2: vec2,
                            v3: vec3,
                            v4: vec4,
                            blendSelector: layer.blendSelector,
                            textureIndex: layer.textureIndex,
                            isWorldPosition: false,
                            red: red,
                            green: green,
                            blue: blue
                        )
                    }
                }
            }
        }
    }

    private func guardPoint(
        rx: Int,
        ry: Int,
        sn2: Float,
        cs2: Float,
        sn1: Float,
        cs1: Float,
        center: SIMD3<Float>
    ) -> SIMD3<Float> {
        let localY = Float(ry) * sn2
        let localZ = Float(ry) * cs2
        let localX = Float(rx)
        return SIMD3<Float>(
            localX * cs1 - localZ * sn1 + center.x,
            localY + center.y,
            localX * sn1 + localZ * cs1 + center.z
        )
    }

    // MARK: - PP_FOREST (66)

    /// Motion update for `PP_FOREST` (66) forest light shafts at 60Hz.
    func primForest() {
        for index in 0..<4 where state.slots[index].life > 0 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            let flag = state.slots[index].flag1[0]
            if flag == 13 {
                if process <= 40 {
                    state.slots[index].alphaB += 1
                }
                state.slots[index].alphaB = max(0, state.slots[index].alphaB)
            } else if flag >= 11 {
                if process <= 40 {
                    state.slots[index].alphaB += 1
                } else if process > 140 {
                    state.slots[index].alphaB -= 1
                }
                state.slots[index].alphaB = max(0, state.slots[index].alphaB)
            }

            if index == 1 || index == 3 {
                let phase = (process % 720) / 2
                state.slots[index].maxHeight = state.slots[index].height[0] + EffectSpace.sine(degrees: phase) * 0.5
            }
        }
    }

    /// Geometry submission for `PP_FOREST` (66) pentagonal slanted light shafts.
    func renderPentagon(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        for slot in state.slots where slot.life == 1 && slot.alphaB > 0 {
            let top = slot.vecTPre
            let base = slot.vecTNow
            let radius = slot.maxHeight
            let (red, green, blue): (UInt8, UInt8, UInt8) = slot.flag1[0] == 13 ? (80, 80, 255) : (230, 255, 230)

            var vec1 = SIMD3<Float>.zero
            var vec4 = SIMD3<Float>.zero
            for point in 0...5 {
                var angle = Int(slot.rotStart) + point * 72
                if angle >= 360 {
                    angle -= 360
                }
                let dx = radius * EffectSpace.cosine(degrees: angle)
                let dz = radius * EffectSpace.sine(degrees: angle)
                let vec2 = SIMD3<Float>(base.x + dx, base.y, base.z + dz)
                let vec3 = SIMD3<Float>(top.x + dx, top.y, top.z + dz)

                if point != 0 {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: slot.alphaB,
                        v1: vec1,
                        v2: vec2,
                        v3: vec3,
                        v4: vec4,
                        blendSelector: 0,
                        textureIndex: 0,
                        isWorldPosition: true,
                        red: red,
                        green: green,
                        blue: blue
                    )
                }
                vec1 = vec2
                vec4 = vec3
            }
        }
    }

    // MARK: - Primitive 69

    /// Motion update for primitive `69` pentagonal ring beams at 60Hz.
    func primPentaRing() {
        for index in 0..<4 where state.slots[index].life > 0 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            let style = state.slots[index].height[4]
            if style == 5.0 {
                if process > 20 {
                    state.slots[index].alphaB = max(0, state.slots[index].alphaB - 2)
                } else {
                    state.slots[index].alphaB += 8
                }
            } else if process < 6 {
                state.slots[index].alphaB += style == 2.0 ? 2 : 8
            } else {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - (style == 2.0 ? 1 : 4))
            }

            let rot = Int(state.slots[index].rotStart)
            state.slots[index].vecTNow.x = state.slots[index].distance * EffectSpace.cosine(degrees: rot) + state.slots[index].vecBNow.x
            state.slots[index].vecTNow.z = state.slots[index].distance * EffectSpace.sine(degrees: rot) + state.slots[index].vecBNow.z
        }
    }

    /// Geometry submission for primitive `69` dual-pass pentagonal ring tubes.
    func renderPentaRing(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        for slot in state.slots where slot.life == 1 && slot.alphaB > 0 {
            let direction = ((Int(slot.rotStart) + 90) % 360 + 360) % 360
            let dirCos = EffectSpace.cosine(degrees: direction)
            let dirSin = EffectSpace.sine(degrees: direction)
            let style = slot.height[4]

            for pass in 0..<2 {
                let radius: Float = if pass == 0 {
                    slot.maxHeight
                } else if style == 3.0 {
                    slot.maxHeight * 2.0
                } else {
                    slot.maxHeight + 0.25
                }

                let blendSelector: Int16 = pass == 0 ? 1 : 0
                let (red, green, blue, extra): (UInt8, UInt8, UInt8, Int8) = if style == 2.0 {
                    (255, 255, 255, 0)
                } else if style == 3.0 {
                    (255, 89, 182, 0)
                } else if style == 4.0 {
                    (55, 55, 255, 1)
                } else if style == 5.0 {
                    (55, 55, 55, 1)
                } else {
                    (255, 255, pass == 0 ? 55 : 200, 0)
                }

                var prevB = SIMD3<Float>.zero
                var prevT = SIMD3<Float>.zero
                var i = 0
                var angle = 0
                while angle <= 360 {
                    let across = radius * EffectSpace.cosine(degrees: angle)
                    let offset = SIMD3<Float>(
                        across * dirCos,
                        radius * EffectSpace.sine(degrees: angle) - slot.height[0],
                        across * dirSin
                    )
                    let curB = offset + slot.vecBNow
                    let curT = offset + slot.vecTNow

                    if i > 0 {
                        renderTeiRect(
                            into: &collector,
                            assets: assets,
                            alpha: slot.alphaB,
                            v1: prevB,
                            v2: curB,
                            v3: curT,
                            v4: prevT,
                            blendSelector: blendSelector,
                            textureIndex: 0,
                            isWorldPosition: true,
                            red: red,
                            green: green,
                            blue: blue,
                            extra: extra
                        )
                    }

                    prevB = curB
                    prevT = curT
                    i += 1
                    angle += 72
                }
            }
        }
    }

    // MARK: - Primitive 74

    /// Motion update for primitive `74` fade-in layered dome at 60Hz.
    func primHalfSphere2() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            if state.slots[index].process < 11 && state.slots[index].alphaB < 100 {
                state.slots[index].alphaB += 1
            }
        }
    }

    /// Geometry submission for primitive `74` multi-ring hemisphere mesh.
    func renderHalfSphere2(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        for ec in 0..<4 where state.slots[ec].life == 1 {
            let fullDisplayAngle = Int(state.slots[ec].fullDisplayAngle)
            let step = fullDisplayAngle / 10
            guard step > 0 else {
                continue
            }

            let riseCos = EffectSpace.cosine(degrees: Int(state.slots[ec].riseAngle))
            let riseSin = EffectSpace.sine(degrees: Int(state.slots[ec].riseAngle))
            var level = 0
            var prevB: SIMD3<Float> = .zero
            var prevT: SIMD3<Float> = .zero

            for _ in 0..<10 {
                var count = 0
                while count <= fullDisplayAngle {
                    let angle = (Int(state.slots[ec].rotStart) + count) % 360
                    let cs = EffectSpace.cosine(degrees: angle)
                    let sn = EffectSpace.sine(degrees: angle)
                    let dist = state.slots[ec].distance
                    let curB = SIMD3<Float>(dist * cs, 0, dist * sn)

                    let radius = state.slots[ec].height[level]
                    let spread = radius * riseCos
                    let curT = SIMD3<Float>(spread * cs + curB.x, -(radius * riseSin), spread * sn + curB.z)

                    if level > 0 {
                        renderTeiRect(
                            into: &collector,
                            assets: assets,
                            texPart: level - 1,
                            alphaB: state.slots[ec].alphaB,
                            alphaT: state.slots[ec].alphaB,
                            v1: prevB,
                            v2: curB,
                            v3: curT,
                            v4: prevT,
                            textureIndex: 0
                        )
                    }

                    level = min(20, level + 1)
                    prevB = curB
                    prevT = curT
                    count += step
                }
            }
        }
    }

    // MARK: - Primitive 81

    /// Motion update for primitive `81` pulsing crossed light beams at 60Hz.
    func primBeam() {
        followMaster()

        for index in 0..<4 where state.slots[index].life > 0 {
            state.slots[index].process += 1
            if state.slots[index].distance < 10.0 {
                state.slots[index].distance *= 1.02
            }
            if state.slots[index].process > 500 && state.slots[index].alphaB > 0 {
                state.slots[index].alphaB -= 1
            }
            var displayAngle = Int16(Int(Float(state.slots[index].fullDisplayAngle) + state.slots[index].maxHeight))
            if displayAngle >= 360 {
                displayAngle -= 360
            }
            state.slots[index].fullDisplayAngle = displayAngle
        }
    }

    /// Geometry submission for primitive `81` crossed tapered light beams.
    func renderBeam(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        for slot in state.slots where slot.life == 1 && slot.alphaB > 0 {
            let length = slot.distance * EffectSpace.sine(degrees: Int(slot.fullDisplayAngle)) + slot.distance
            let reach = length * EffectSpace.cosine(degrees: Int(slot.riseAngle))
            let tip = SIMD3<Float>(
                reach * EffectSpace.cosine(degrees: Int(slot.rotStart)),
                length * EffectSpace.sine(degrees: Int(slot.riseAngle)) - slot.height[3],
                reach * EffectSpace.sine(degrees: Int(slot.rotStart))
            )

            let red = UInt8(truncatingIfNeeded: Int(slot.height[0]))
            let green = UInt8(truncatingIfNeeded: Int(slot.height[1]))
            let blue = UInt8(truncatingIfNeeded: Int(slot.height[2]))
            let baseY = -slot.height[3]

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: SIMD3<Float>(0.5, baseY, 0),
                v2: tip,
                v3: tip,
                v4: SIMD3<Float>(-0.5, baseY, 0),
                blendSelector: 0,
                textureIndex: 0,
                isWorldPosition: false,
                red: red,
                green: green,
                blue: blue
            )
            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: SIMD3<Float>(0, baseY, 0.5),
                v2: tip,
                v3: tip,
                v4: SIMD3<Float>(0, baseY, -0.5),
                blendSelector: 0,
                textureIndex: 0,
                isWorldPosition: false,
                red: red,
                green: green,
                blue: blue
            )
        }
    }

    // MARK: - Primitive 98

    /// Motion update for primitive `98` expanding vertical ring quad at 60Hz.
    func primRing98() {
        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        let process = state.slots[0].process
        if process < 50 {
            state.slots[0].distance += 0.1
        }
        if process <= 5 {
            state.slots[0].alphaB += 50
        } else {
            state.slots[0].alphaB = max(0, state.slots[0].alphaB - 3)
        }
    }

    /// Geometry submission for primitive `98` vertical oriented ring quad.
    func renderRing(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let angles = [90, 180, 270, 0]
        for slot in state.slots where slot.life == 1 && slot.alphaB > 0 {
            let dist = slot.distance
            let center = slot.vecBNow
            let riseCos = EffectSpace.cosine(degrees: Int(slot.riseAngle))
            let riseSin = EffectSpace.sine(degrees: Int(slot.riseAngle))

            let corners = angles.map { angle -> SIMD3<Float> in
                let radial = dist * EffectSpace.cosine(degrees: angle)
                return SIMD3<Float>(
                    riseCos * radial + center.x,
                    dist * EffectSpace.sine(degrees: angle) + center.y,
                    riseSin * radial + center.z
                )
            }

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: corners[0],
                v2: corners[1],
                v3: corners[2],
                v4: corners[3],
                blendSelector: 0,
                textureIndex: 0,
                isWorldPosition: true,
                red: 60,
                green: 60,
                blue: 255
            )
        }
    }

    // MARK: - Primitive 103

    /// Motion update for primitive `103` spinning stacked ring layers at 60Hz.
    func primSpinFade() {
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            let turn = Int.random(in: 0..<3)
            var rot = state.slots[index].rotStart + Int16(turn + 3)
            if rot >= 360 {
                rot -= 360
            }
            state.slots[index].rotStart = rot

            let mode = state.slots[index].flag1[5]
            if mode == 1 {
                if process > 120 {
                    state.slots[index].alphaB -= 1
                }
            } else if mode != 10 && process > 60 {
                state.slots[index].alphaB -= 1
            }

            if process <= 40 {
                state.slots[index].alphaB += 1
            }
            if state.slots[index].alphaB < 0 {
                state.slots[index].alphaB = 0
            }
        }
    }

    /// Geometry submission for primitive `103` stacked concentric horizontal quads.
    func renderStackedRings(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        for slot in state.slots where slot.life == 1 && slot.alphaB > 0 {
            var y = -slot.height[0]
            var radius = slot.maxHeight
            let count = Int(slot.flag1[0])
            guard count > 0 else {
                continue
            }

            for i in 0..<count {
                if i > 0 {
                    y += slot.height[1]
                    radius -= (2.2 - Float(i) * 0.2) * slot.distance
                }

                var angle = (Int(slot.rotStart) + 45 * i) % 360
                if angle < 0 {
                    angle += 360
                }
                let vec1 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: angle), y - 1.0, radius * EffectSpace.sine(degrees: angle))
                angle = (angle + 90) % 360
                let vec2 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: angle), y - 1.0, radius * EffectSpace.sine(degrees: angle))
                angle = (angle + 90) % 360
                let vec3 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: angle), y, radius * EffectSpace.sine(degrees: angle))
                angle = (angle + 90) % 360
                let vec4 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: angle), y, radius * EffectSpace.sine(degrees: angle))

                switch slot.flag1[4] {
                case 0:
                    renderTeiRect(into: &collector, assets: assets, alpha: slot.alphaB, v1: vec1, v2: vec2, v3: vec3, v4: vec4, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: 50, green: 50, blue: 255)
                case 1:
                    renderTeiRect(into: &collector, assets: assets, alpha: slot.alphaB, v1: vec1, v2: vec2, v3: vec3, v4: vec4, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 164, green: 136, blue: 55)
                case 2:
                    renderTeiRect(into: &collector, assets: assets, alpha: slot.alphaB, v1: vec1, v2: vec2, v3: vec3, v4: vec4, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 155, green: 255, blue: 155)
                case 3:
                    renderTeiRect(into: &collector, assets: assets, alpha: slot.alphaB, v1: vec1, v2: vec2, v3: vec3, v4: vec4, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 130, green: 130, blue: 255)
                case 4:
                    renderTeiRect(into: &collector, assets: assets, alpha: slot.alphaB, v1: vec1, v2: vec2, v3: vec3, v4: vec4, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 255, green: 50, blue: 50)
                case 5:
                    renderTeiRect(into: &collector, assets: assets, alpha: slot.alphaB, v1: vec1, v2: vec2, v3: vec3, v4: vec4, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 5, green: 5, blue: 5)
                case 6:
                    renderTeiRect(into: &collector, assets: assets, alpha: slot.alphaB, v1: vec1, v2: vec2, v3: vec3, v4: vec4, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 255, green: 255, blue: 255)
                case 7:
                    renderTeiRect(into: &collector, assets: assets, alpha: slot.alphaB, v1: vec1, v2: vec2, v3: vec3, v4: vec4, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 255, green: 125, blue: 255)
                case 8:
                    renderTeiRect(into: &collector, assets: assets, alpha: slot.alphaB / 10, v1: vec1, v2: vec2, v3: vec3, v4: vec4, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 225, green: 225, blue: 255)
                case 10:
                    renderTeiRect(into: &collector, assets: assets, alpha: slot.alphaB, v1: vec1, v2: vec2, v3: vec3, v4: vec4, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: 125, green: 125, blue: 255)
                case 11:
                    renderTeiRect(into: &collector, assets: assets, alpha: slot.alphaB / 3, v1: vec1, v2: vec2, v3: vec3, v4: vec4, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 255, green: 255, blue: 255)
                    renderTeiRect(into: &collector, assets: assets, alpha: slot.alphaB, v1: vec1, v2: vec2, v3: vec3, v4: vec4, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: 255, green: 55, blue: 55)
                default:
                    break
                }
            }
        }
    }

    // MARK: - PP_HALFSPHERE (104)

    /// Motion update for `PP_HALFSPHERE` (104) forward dome facing the target at 60Hz.
    func primHalfSphere(context: EffectTickContext) {
        followMaster()
        let parentAngle = parentFacingAngle(world: context.world)

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            var rotStart = Int16(parentAngle + 180.0)
            if rotStart >= 360 {
                rotStart -= 360
            }
            state.slots[index].rotStart = rotStart

            let angle = Int(rotStart) + (rotStart < 270 ? 90 : -270)
            state.slots[index].vecTNow.x = EffectSpace.cosine(degrees: angle) * 5.0
            state.slots[index].vecTNow.z = EffectSpace.sine(degrees: angle) * 5.0

            if state.slots[index].process <= 50 && state.slots[index].alphaB < 120 {
                state.slots[index].alphaB += 5
            }
        }
    }

    /// Geometry submission for `PP_HALFSPHERE` (104) hemisphere mesh.
    func renderHalfSphere(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let basicAngle2 = 18

        for slot in state.slots where slot.life == 1 {
            let fullDisplayAngle = Int(slot.fullDisplayAngle)
            let basicAngle = fullDisplayAngle / 10
            guard basicAngle > 0 else {
                continue
            }

            var vec1 = SIMD3<Float>.zero
            var vec3 = SIMD3<Float>.zero

            var angle2 = 0
            while angle2 < 180 {
                var count = 0
                while count <= fullDisplayAngle {
                    var angle = count + Int(slot.rotStart)
                    if angle >= 360 {
                        angle -= 360
                    }
                    if fullDisplayAngle == 360 && count == fullDisplayAngle {
                        angle = Int(slot.rotStart)
                    }

                    let cs1 = EffectSpace.cosine(degrees: angle)
                    let sn1 = EffectSpace.sine(degrees: angle)

                    let cs2a = EffectSpace.cosine(degrees: angle2)
                    let sn2a = EffectSpace.sine(degrees: angle2)
                    let distA = sn2a * slot.distance
                    let vec2 = SIMD3<Float>(
                        cs1 * distA + slot.vecTNow.x,
                        cs2a * slot.distance - slot.maxHeight,
                        sn1 * distA + slot.vecTNow.z
                    )

                    let cs2b = EffectSpace.cosine(degrees: angle2 + basicAngle2)
                    let sn2b = EffectSpace.sine(degrees: angle2 + basicAngle2)
                    let distB = sn2b * slot.distance
                    let vec4 = SIMD3<Float>(
                        cs1 * distB + slot.vecTNow.x,
                        cs2b * slot.distance - slot.maxHeight,
                        sn1 * distB + slot.vecTNow.z
                    )

                    if count > 0 {
                        renderTeiRect(
                            into: &collector,
                            assets: assets,
                            alpha: slot.alphaB,
                            v1: vec1,
                            v2: vec2,
                            v3: vec4,
                            v4: vec3,
                            blendSelector: 1,
                            textureIndex: 0,
                            isWorldPosition: false,
                            red: 250,
                            green: 250,
                            blue: 255
                        )
                    }

                    vec1 = vec2
                    vec3 = vec4
                    count += basicAngle
                }

                angle2 += basicAngle2
            }
        }
    }

    // MARK: - Primitive 105

    /// Motion update for primitive `105` forward-facing spinning cone at 60Hz.
    func primCone(context: EffectTickContext) {
        followMaster()
        let parentAngle = parentFacingAngle(world: context.world)

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            guard state.slots[index].process > 0 else {
                continue
            }

            if index < 2 {
                state.slots[index].riseAngle += 1
            }
            if state.slots[index].riseAngle >= 360 {
                state.slots[index].riseAngle -= 360
            }

            var rotStart = Int16(parentAngle + 180.0)
            if rotStart >= 360 {
                rotStart -= 360
            }
            state.slots[index].rotStart = rotStart

            let angle = Int(rotStart) + (rotStart < 270 ? 90 : -270)
            state.slots[index].vecTNow.x = EffectSpace.cosine(degrees: angle) * 5.0
            state.slots[index].vecTNow.z = EffectSpace.sine(degrees: angle) * 5.0

            if state.slots[index].alphaB < 40 {
                state.slots[index].alphaB += 5
            }
        }
    }

    /// Geometry submission for primitive `105` 20-segment flared cone.
    func renderCone(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        for slot in state.slots where slot.life == 1 && slot.alphaB > 0 {
            let fullDisplayAngle = Int(slot.fullDisplayAngle)
            let step = fullDisplayAngle / 20
            guard step > 0 else {
                continue
            }

            let rotCos = EffectSpace.cosine(degrees: Int(slot.rotStart))
            let rotSin = EffectSpace.sine(degrees: Int(slot.rotStart))
            let scale = slot.height[0]
            let outerRadius = scale * slot.distance * 0.1 + slot.distance

            var texPart = 0
            var vec1 = SIMD3<Float>.zero
            var vec4 = SIMD3<Float>.zero
            var count = 0
            while count <= fullDisplayAngle {
                var angle = Int(slot.riseAngle) + count
                if angle >= 360 {
                    angle -= 360
                }
                if fullDisplayAngle == 360 && count == 360 {
                    angle = Int(slot.riseAngle)
                }

                let cs = EffectSpace.cosine(degrees: angle)
                let sn = EffectSpace.sine(degrees: angle)
                let inner = slot.distance * sn
                let outer = outerRadius * sn

                let vec2 = SIMD3<Float>(
                    slot.vecTNow.x + inner * rotCos,
                    slot.distance * cs - slot.maxHeight,
                    slot.vecTNow.z + inner * rotSin
                )
                let vec3 = SIMD3<Float>(
                    outer * rotCos - slot.vecTNow.x * scale,
                    outerRadius * cs - slot.maxHeight,
                    outer * rotSin - slot.vecTNow.z * scale
                )

                if count > 0 {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        texPart: texPart - 1,
                        alphaB: slot.alphaB,
                        alphaT: slot.alphaB,
                        v1: vec1,
                        v2: vec2,
                        v3: vec3,
                        v4: vec4,
                        textureIndex: 0
                    )
                }

                texPart = min(20, texPart + 1)
                vec1 = vec2
                vec4 = vec3
                count += step
            }
        }
    }

    // MARK: - PP_HERMODE (114)

    /// Motion update for `PP_HERMODE` (114) rotating ground cube at 60Hz.
    func primHermode() {
        followMaster()

        if state.slots[0].alphaB < 140 {
            state.slots[0].alphaB += 2
        }

        state.slots[0].riseAngle += 1
        if state.slots[0].riseAngle > 359 {
            state.slots[0].riseAngle -= 360
        }

        state.slots[0].rotStart += 1
        if state.slots[0].rotStart > 359 {
            state.slots[0].rotStart -= 360
        }
    }

    /// Geometry submission for `PP_HERMODE` (114) extruded cube faces.
    func renderHermode(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        for ec in 0..<4 where state.slots[ec].life == 1 {
            var angle = Int(state.slots[ec].rotStart)
            let snA = EffectSpace.sine(degrees: angle) * 2.0
            let rx = state.slots[ec].distance * 0.1 * (EffectSpace.sine(degrees: Int(state.slots[ec].riseAngle)) + 1.0)
            let radius = state.slots[ec].distance * 0.8 + rx
            let y = state.slots[ec].height[0] + snA

            let bPre = SIMD3<Float>(EffectSpace.cosine(degrees: angle) * radius, y, EffectSpace.sine(degrees: angle) * radius)
            angle += angle >= 270 ? -270 : 90
            let bNow = SIMD3<Float>(EffectSpace.cosine(degrees: angle) * radius, y, EffectSpace.sine(degrees: angle) * radius)
            angle += angle + 90 >= 360 ? -270 : 90
            let tNow = SIMD3<Float>(EffectSpace.cosine(degrees: angle) * radius, y, EffectSpace.sine(degrees: angle) * radius)
            angle += angle + 90 >= 360 ? -270 : 90
            let tPre = SIMD3<Float>(EffectSpace.cosine(degrees: angle) * radius, y, EffectSpace.sine(degrees: angle) * radius)

            let height = state.slots[ec].distance
            let vec1 = SIMD3<Float>(bPre.x, bPre.y - height, bPre.z)
            let vec2 = SIMD3<Float>(bNow.x, bNow.y - height, bNow.z)
            let vec3 = SIMD3<Float>(tPre.x, tPre.y - height, tPre.z)
            let vec4 = SIMD3<Float>(tNow.x, tNow.y - height, tNow.z)

            let alpha = state.slots[ec].alphaB
            let rg = UInt8(truncatingIfNeeded: state.slots[ec].flag1[0])

            renderTeiRect(into: &collector, assets: assets, alpha: alpha, v1: bPre, v2: bNow, v3: tNow, v4: tPre, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: rg, green: rg, blue: 250)
            renderTeiRect(into: &collector, assets: assets, alpha: alpha, v1: bPre, v2: bNow, v3: vec2, v4: vec1, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: rg, green: rg, blue: 220)
            renderTeiRect(into: &collector, assets: assets, alpha: alpha, v1: bNow, v2: tNow, v3: vec4, v4: vec2, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: rg, green: rg, blue: 190)
            renderTeiRect(into: &collector, assets: assets, alpha: alpha, v1: tNow, v2: tPre, v3: vec3, v4: vec4, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: rg, green: rg, blue: 130)
            renderTeiRect(into: &collector, assets: assets, alpha: alpha, v1: tPre, v2: bPre, v3: vec1, v4: vec3, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: rg, green: rg, blue: 160)
            renderTeiRect(into: &collector, assets: assets, alpha: alpha, v1: vec1, v2: vec2, v3: vec4, v4: vec3, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: rg, green: rg, blue: 250)
        }
    }

    // MARK: - PP_3DQUADHORN2 (117)

    /// Motion update for `PP_3DQUADHORN2` (117) pulsing pyramid horn at 60Hz.
    func prim3DQuadHorn2() {
        let basePosition = master?.position ?? state.orgPos
        state.orgPos = basePosition + state.deltaPos2

        let frame = state.stateCnt
        if frame < 550 {
            if frame % 6 == 2 {
                state.speed = state.changeSpeed
                state.accel = state.changeAccel
            } else if frame % 6 == 5 {
                state.speed = 1.18
                state.accel = 0.01
            }
        } else if frame == 550 {
            state.speed = state.changeSpeed
            state.accel = state.changeAccel
        }

        state.speed += state.accel
        state.speed3d = EffectSpace.transformVector(SIMD3<Float>(0, 0, state.speed), by: state.transform)
        state.deltaPos += state.speed3d
        position = state.orgPos + state.deltaPos
        processAlpha()
    }

    // MARK: - Primitive 126

    /// Motion update for primitive `126` trailing rotated ring projectile at 60Hz.
    func primRotatedRing() {
        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        let process = state.slots[0].process
        guard process > 0 else {
            return
        }

        state.slots[0].riseAngle += 30
        if state.slots[0].riseAngle > 359 {
            state.slots[0].riseAngle -= 360
        }

        if process == 1 {
            state.slots[0].rotStart = Self.angle(
                dx: state.deltaPos.x - position.x,
                dy: state.deltaPos.z - position.z
            )
        } else if process < 11 {
            state.slots[0].alphaB = min(60, state.slots[0].alphaB + 6)
            state.slots[0].height[1] *= 1.02
        } else {
            state.slots[0].alphaB -= 3
            state.slots[0].height[1] *= 1.04
            if state.slots[0].alphaB < 0 {
                state.slots[0].alphaB = 0
                state.slots[0].life = 0
            }
        }

        let rot = Int(state.slots[0].rotStart)
        state.slots[0].vecBNow.x += state.slots[0].height[1] * EffectSpace.cosine(degrees: rot)
        state.slots[0].vecBNow.z += state.slots[0].height[1] * EffectSpace.sine(degrees: rot)

        if process % 3 == 0 {
            for index in stride(from: 3, through: 1, by: -1) {
                state.slots[index].vecBNow = state.slots[index - 1].vecBNow
                state.slots[index].alphaB = Int16(Float(state.slots[index - 1].alphaB) * 0.8)
                state.slots[index].riseAngle = state.slots[index - 1].riseAngle
            }
        }
    }

    /// Geometry submission for primitive `126` rotated ring trail quads.
    func renderRotatedRing(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        for slot in state.slots where slot.life == 1 && slot.alphaB > 0 {
            let cs = EffectSpace.cosine(degrees: Int(slot.rotStart))
            let sn = EffectSpace.sine(degrees: Int(slot.rotStart))
            let dist = slot.distance
            let center = slot.vecBNow
            var angle = Int(slot.riseAngle)

            var corners = [SIMD3<Float>]()
            corners.reserveCapacity(4)
            for _ in 0..<4 {
                angle += angle + 90 < 360 ? 90 : -270
                let radial = dist * EffectSpace.cosine(degrees: angle)
                corners.append(SIMD3<Float>(
                    cs * radial + center.x,
                    dist * EffectSpace.sine(degrees: angle) + center.y,
                    radial * sn + center.z
                ))
            }

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: corners[0],
                v2: corners[1],
                v3: corners[2],
                v4: corners[3],
                blendSelector: 0,
                textureIndex: 0,
                isWorldPosition: true,
                red: 80,
                green: 255,
                blue: 80
            )
        }
    }

    // MARK: - Shared Helpers

    private func makeXYRotation(xDegrees: Int, yDegrees: Int) -> simd_float4x4 {
        let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: xDegrees))
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: yDegrees))
        return rotY * rotX
    }

    private func parentFacingAngle(world: any EffectWorldContext) -> Float {
        guard let targetID = master?.targetObjectID,
              let targetState = world.targetState(for: targetID) else {
            return 0
        }
        return targetState.facingAngle
    }
}

extension EffectPrimitiveRenderState {
    init(renderFlag: UInt32) {
        let isAdditive = (renderFlag & EffectPrimitiveState.RenderFlag.additive) != 0
        let depthTest = (renderFlag & EffectPrimitiveState.RenderFlag.noDepth) == 0

        self.init(
            srcBlend: .sourceAlpha,
            dstBlend: isAdditive ? .one : .oneMinusSourceAlpha,
            depthTest: depthTest,
            depthWrite: false,
            cullMode: .none,
            bucket: .translucent
        )
    }
}
