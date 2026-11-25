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

    // MARK: - Half Sphere (`pp_halfsphere`)

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

    // MARK: - Guard Sphere Cage (`pp_guard`)

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
                    state.slots[ec].distance = dist

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

                        let vec1 = Self.guardPoint(rx: quadSize, ry: quadSize, sn2: sn2, cs2: cs2, sn1: sn1, cs1: cs1, center: center)
                        let vec2 = Self.guardPoint(rx: negQuadSize, ry: quadSize, sn2: sn2, cs2: cs2, sn1: sn1, cs1: cs1, center: center)
                        let vec3 = Self.guardPoint(rx: negQuadSize, ry: negQuadSize, sn2: sn2, cs2: cs2, sn1: sn1, cs1: cs1, center: center)
                        let vec4 = Self.guardPoint(rx: quadSize, ry: negQuadSize, sn2: sn2, cs2: cs2, sn1: sn1, cs1: cs1, center: center)

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

    // MARK: - Grand Cross Pillars (`pp_grandcross2`)

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

            state.slots[ec].vecBPre = bPre
            state.slots[ec].vecBNow = bNow
            state.slots[ec].vecTNow = tNow
            state.slots[ec].vecTPre = tPre

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

    // MARK: - Hermode Rotating Cube (`pp_hermode`)

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

            state.slots[ec].vecBPre = bPre
            state.slots[ec].vecBNow = bNow
            state.slots[ec].vecTNow = tNow
            state.slots[ec].vecTPre = tPre

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

    // MARK: - Helpers

    private static func guardPoint(
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

    private func parentFacingAngle(world: any EffectWorldContext) -> Float {
        guard let targetID = master?.targetObjectID,
              let targetState = world.targetState(for: targetID) else {
            return 0
        }
        return targetState.facingAngle
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
}
