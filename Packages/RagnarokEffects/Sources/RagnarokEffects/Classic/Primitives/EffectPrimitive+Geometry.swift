//
//  EffectPrimitive+Geometry.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

import Foundation
import RagnarokRendering
import simd

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

extension EffectPrimitive {
    private static func makeXYRotation(xDegrees: Int, yDegrees: Int) -> simd_float4x4 {
        let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: xDegrees))
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: yDegrees))
        return rotY * rotX
    }

    // MARK: - 3D Circle (`pp_3dcircle`)

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

        state.transform = Self.makeXYRotation(
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

    // MARK: - 3D Cylinder (`pp_3dcylinder` / `pp_3dcylinderhalf`)

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

        state.transform = Self.makeXYRotation(
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

    @discardableResult
    func prim3DCylinderHalf() -> Bool {
        let basePosition = master?.position ?? state.orgPos
        state.orgPos = basePosition + state.deltaPos2

        state.speed += state.accel
        state.outerSpeed += state.outerAccel
        state.innerSpeed += state.innerAccel
        state.heightSpeed += state.heightAccel

        state.transform = Self.makeXYRotation(
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

    // MARK: - 3D Sphere (`pp_3dsphere`)

    func prim3DSphere() {
        let basePosition = master?.position ?? state.orgPos
        state.orgPos = basePosition + state.deltaPos2
        position = state.orgPos
        state.radiusSpeed += state.radiusAccel
        state.radius += state.radiusSpeed
        state.longitude += state.longSpeed
        processAlpha()
    }

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

                let vec1 = EffectSpace.transformVector(radiusVector, by: Self.makeXYRotation(xDegrees: pitch0, yDegrees: yaw0)) + position
                let vec2 = EffectSpace.transformVector(radiusVector, by: Self.makeXYRotation(xDegrees: pitch1, yDegrees: yaw0)) + position
                let vec3 = EffectSpace.transformVector(radiusVector, by: Self.makeXYRotation(xDegrees: pitch0, yDegrees: yaw1)) + position
                let vec4 = EffectSpace.transformVector(radiusVector, by: Self.makeXYRotation(xDegrees: pitch1, yDegrees: yaw1)) + position

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

    // MARK: - Helpers

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
}
