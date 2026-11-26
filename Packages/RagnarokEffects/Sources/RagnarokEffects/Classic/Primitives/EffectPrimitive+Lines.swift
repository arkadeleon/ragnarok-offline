//
//  EffectPrimitive+Lines.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/25.
//

import simd

extension EffectPrimitive {

    // MARK: - PP_3DFLASH (19)

    /// Motion update for `PP_3DFLASH` (19) radial flash wedge at 60Hz.
    func prim3DFlash() {
        position.x = state.deltaPos2.x
        position.y = state.deltaPos2.y

        if (state.pattern & 1) != 0 && state.heightSize <= 0 {
            state.heightSpeed = 0
            state.heightAccel = 0
        }

        if state.stateCnt == state.changePoint {
            state.heightSpeed = state.changeHeightSpeed
            state.longSpeed = state.changeSpeed
            state.longAccel = state.changeAccel
        }

        if state.heightSize < 0 {
            state.heightSpeed = -state.heightSpeed
            state.heightSize = 0
        }

        state.longSpeed += state.longAccel
        state.heightSpeed += state.heightAccel
        state.arcAngle += state.widthSpeed
        state.longitude += state.longSpeed
        state.heightSize += state.heightSpeed
        processAlpha()
    }

    /// Geometry submission for `PP_3DFLASH` (19) single radial flash triangle.
    func render3DFlash(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        render2DFlash(into: &collector, assets: assets)
    }

    // MARK: - PP_3DLINE (20)

    /// Motion update for `PP_3DLINE` (20) falling vertical streak at 60Hz.
    func prim3DLine() {
        position.y += 5.0
    }

    /// Geometry submission for `PP_3DLINE` (20) untextured vertical streak triangle.
    func render3DLine(into collector: inout EffectPrimitiveBatchCollector) {
        let top = position
        let topSide = SIMD3<Float>(position.x + 0.25, position.y, position.z)
        let bottom = SIMD3<Float>(position.x, position.y - 10.0, position.z)
        let topColor = EffectPrimitiveBatchCollector.unpackARGB(0x9CFFFFFF)
        let tailColor = EffectPrimitiveBatchCollector.unpackARGB(0x9BFFFFFF)
        let renderState = EffectPrimitiveRenderState(
            srcBlend: .sourceAlpha,
            dstBlend: .one,
            depthTest: true,
            depthWrite: false,
            cullMode: .none,
            bucket: .translucent
        )
        let center = (top + topSide + bottom) / 3.0

        collector.appendEffectTriangle(
            p0: top,
            p1: topSide,
            p2: bottom,
            uv0: .zero,
            uv1: .zero,
            uv2: .zero,
            color0: topColor,
            color1: tailColor,
            color2: tailColor,
            texture: nil,
            renderState: renderState,
            effectCenter: center
        )
    }

    // MARK: - PP_LINELINK (38)

    /// Motion update for `PP_LINELINK` (38), mirroring `CEffectPrim::PrimLineLink` at 60Hz.
    func primLineLink(context: EffectTickContext) {
        followMaster()
        state.slots[0].process += 1

        state.slots[0].vecTNow = SIMD3<Float>(position.x, position.y - 8.0, position.z)

        let process = state.slots[0].process
        let kind = state.slots[0].height[4]
        if kind == 2.0 {
            if process > 40 {
                state.slots[0].alphaB = max(0, state.slots[0].alphaB - 3)
            } else if process < 20 {
                state.slots[0].alphaB += 6
            }
        } else if kind == 3.0 {
            let phase = process % 360
            if process <= 80 {
                state.slots[0].alphaB += 1
            }
            state.slots[0].maxHeight += EffectSpace.sine(degrees: phase) * 0.005
        } else if process % 10 < 5 {
            state.slots[0].alphaB += 2
        } else {
            state.slots[0].alphaB -= 2
        }

        let targetPosition: SIMD3<Float>?
        if let targetObjectID = state.slots[0].targetObjectID {
            targetPosition = context.world.targetState(for: targetObjectID)?.effectPosition
        } else {
            targetPosition = master?.sourcePosition
        }
        if let targetPosition {
            state.slots[0].vecTPre = SIMD3<Float>(targetPosition.x, targetPosition.y - 8.0, targetPosition.z)
        } else {
            state.slots[0].life = 0
            state.slots[0].alphaB = 0
        }
    }

    /// Geometry submission for `PP_LINELINK` (38), mirroring `CEffectPrim::RenderTube`.
    func renderTube(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let slot = state.slots[0]
        guard slot.life == 1, slot.alphaB > 0 else {
            return
        }

        let deltaZ = slot.vecTNow.z - slot.vecTPre.z
        let deltaX = slot.vecTNow.x - slot.vecTPre.x
        let heading = Self.angle(dx: deltaX, dy: deltaZ)
        let side = Int((heading + 90) % 360)

        let end: SIMD3<Float>
        if slot.process < 15 {
            let t = EffectSpace.sine(degrees: 6 * slot.process)
            end = (slot.vecTPre - slot.vecTNow) * t + slot.vecTNow
        } else {
            end = slot.vecTPre
        }

        var prevStart = SIMD3<Float>.zero
        var prevEnd = SIMD3<Float>.zero

        for pass in 0..<2 {
            let radius = pass == 0 ? slot.maxHeight : slot.maxHeight * 2.0
            for step in 0...10 {
                let ringAngle = step * 36
                let across = radius * EffectSpace.cosine(degrees: ringAngle)
                let up = radius * EffectSpace.sine(degrees: ringAngle)
                let offsetX = across * EffectSpace.cosine(degrees: side)
                let offsetZ = across * EffectSpace.sine(degrees: side)

                let start = SIMD3<Float>(offsetX + slot.vecTNow.x, up + slot.vecTNow.y, offsetZ + slot.vecTNow.z)
                let finish = SIMD3<Float>(end.x + offsetX, end.y + up, end.z + offsetZ)

                if step > 0 {
                    let (alpha, blendSelector, red, green, blue) = tubeStyle(
                        pass: pass,
                        kind: slot.height[4],
                        alphaB: slot.alphaB
                    )
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: alpha,
                        v1: prevStart,
                        v2: start,
                        v3: finish,
                        v4: prevEnd,
                        blendSelector: blendSelector,
                        textureIndex: 0,
                        isWorldPosition: true,
                        red: red,
                        green: green,
                        blue: blue
                    )
                }

                prevStart = start
                prevEnd = finish
            }
        }
    }

    private func tubeStyle(
        pass: Int,
        kind: Float,
        alphaB: Int16
    ) -> (alpha: Int16, blendSelector: Int16, red: UInt8, green: UInt8, blue: UInt8) {
        if pass == 0 {
            switch kind {
            case 2.0:
                return (alphaB, 0, 0, 100, 150)
            case 3.0:
                return (alphaB, 0, 255, 89, 182)
            case 4.0:
                return (alphaB / 2, 1, 50, 50, 50)
            default:
                return (alphaB, 0, 255, 255, 0)
            }
        }

        switch kind {
        case 2.0:
            return (Int16(truncatingIfNeeded: Int(alphaB) * 2), 0, 255, 50, 0)
        case 3.0:
            return (Int16(truncatingIfNeeded: Int(alphaB) * 2), 0, 255, 89, 182)
        case 4.0:
            return (alphaB, 1, 50, 50, 50)
        default:
            return (Int16(truncatingIfNeeded: Int(alphaB) * 2), 0, 0, 0, 255)
        }
    }

    // MARK: - PP_HITLINE (70)

    /// Motion update for `PP_HITLINE` (70) multi-bounce spark streaks at 60Hz.
    func primHitLine() {
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            if process > 35 {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 5)
            }

            state.slots[index].height[0] += 8.0
            if state.slots[index].height[0] > 180.0 {
                state.slots[index].height[0] -= 180.0
                state.slots[index].flag1[0] += 1
            }

            for value in stride(from: 20, through: 1, by: -1) {
                state.slots[index].height[value] = state.slots[index].height[value - 1]
                state.slots[index].flag1[value] = state.slots[index].flag1[value - 1]
            }
        }
    }

    /// Geometry submission for `PP_HITLINE` (70), mirroring `CEffectPrim::RenderHitLine`.
    func renderHitLine(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0, slot.process > 0 else {
                continue
            }

            for segment in 0..<20 {
                let pointA = hitLinePoint(slot: slot, index: segment)
                let pointB = hitLinePoint(slot: slot, index: segment + 1)

                let angle = (Self.angle(dx: pointA.x - pointB.x, dy: pointA.z - pointB.z) + 90) % 360
                let worldA = pointA + slot.vecBNow
                let worldB = pointB + slot.vecBNow

                let alpha = Int(slot.alphaB) - segment * 5
                let colors: (UInt8, UInt8, UInt8)
                if slot.alphaT == 2 {
                    let shade = UInt8(clamping: 200 - (20 - segment) * 7)
                    colors = (255, shade, shade)
                } else if slot.alphaT == 8 {
                    let shade = UInt8(clamping: 150 - (20 - segment) * 7)
                    colors = (shade, shade, 255)
                } else {
                    colors = (255, 200, UInt8(clamping: 150 - (20 - segment) * 7))
                }

                emitTriangularPrism(
                    into: &collector,
                    assets: assets,
                    worldA: worldA,
                    worldB: worldB,
                    angle: Int(angle),
                    radius: slot.maxHeight,
                    yBias: 0.0,
                    alpha: alpha,
                    red: colors.0,
                    green: colors.1,
                    blue: colors.2,
                    reverseWinding: false
                )
            }
        }
    }

    private func hitLinePoint(slot: EffectPrimitiveSlot, index: Int) -> SIMD3<Float> {
        var speed: Float = 0.0
        var radius: Float = 1.0
        let bounces = max(0, Int(slot.flag1[index]))

        for _ in 0..<bounces {
            speed += slot.distance * 2.0 * radius
            radius *= 0.7
        }

        let phase = slot.height[index]
        if phase > 0.0 {
            speed += (phase / 90.0) * slot.distance * radius
        }

        let riseAngle = Int(slot.riseAngle)
        var y = -slot.distance * EffectSpace.sine(degrees: Int(phase)) * 1.5
        y *= radius

        return SIMD3<Float>(
            speed * EffectSpace.cosine(degrees: riseAngle),
            y,
            speed * EffectSpace.sine(degrees: riseAngle)
        )
    }

    // MARK: - PP_SLASH1 (75)

    /// Motion update for `PP_SLASH1` (75) four-way slash blades at 60Hz.
    func primSlash1() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            state.slots[index].height[0] += 1.0

            if state.slots[index].height[0] > 10.0 {
                state.slots[index].alphaB -= 2
                if state.slots[index].alphaB < 0 {
                    state.slots[index].alphaB = 0
                    state.slots[index].life = 0
                }
            }

            if state.slots[index].flag1[0] == 1 {
                state.slots[index].distance += 1.0
                if state.slots[index].maxHeight < 2.0 {
                    state.slots[index].maxHeight += 0.2
                }
                if state.slots[index].process <= 5 {
                    state.slots[index].alphaB += 5
                }
            } else {
                state.slots[index].distance += 2.0
                if state.slots[index].maxHeight < 4.0 {
                    state.slots[index].maxHeight += 0.4
                }
                if state.slots[index].process <= 7 {
                    state.slots[index].alphaB += 5
                }
            }
        }
    }

    /// Geometry submission for `PP_SLASH1` (75), mirroring `CEffectPrim::RenderSlash1`.
    func renderSlash1(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            for step in 0...2 {
                var angle = Int(slot.rotStart) - 1 + step
                if angle < 0 {
                    angle += 360
                } else if angle >= 360 {
                    angle -= 360
                }

                let cs1 = EffectSpace.cosine(degrees: angle)
                let sn1 = EffectSpace.sine(degrees: angle)

                let innerRadius = slot.height[0]
                let outerRadius = slot.height[0] + slot.distance

                let vec1 = SIMD3<Float>(cs1 * innerRadius, 0, sn1 * innerRadius)
                let innerHeight = step == 1 ? slot.maxHeight * 0.2 : slot.maxHeight * 0.1
                let vec2 = SIMD3<Float>(vec1.x, -innerHeight, vec1.z)

                let vec3 = SIMD3<Float>(cs1 * outerRadius, 0, sn1 * outerRadius)
                let outerHeight = step == 1 ? slot.maxHeight : slot.maxHeight * 0.4
                let vec4 = SIMD3<Float>(vec3.x, -outerHeight, vec3.z)

                let alpha = step == 1 ? slot.alphaB : slot.alphaB / 3
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: alpha,
                    v1: vec1,
                    v2: vec3,
                    v3: vec4,
                    v4: vec2,
                    blendSelector: 0,
                    textureIndex: 0,
                    isWorldPosition: false,
                    red: 255,
                    green: 255,
                    blue: 255
                )
            }
        }
    }

    // MARK: - PP_HITLINE3 (100)

    /// Motion update for `PP_HITLINE3` (100) short spark streaks at 60Hz.
    func primHitLine3() {
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            if process > 35 {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 5)
            }

            state.slots[index].height[0] = min(180.0, state.slots[index].height[0] + 6.0)

            let tailCount = min(20, max(0, Int(state.slots[index].vecTNow.y)))
            if tailCount >= 1 {
                for value in stride(from: tailCount, through: 1, by: -1) {
                    state.slots[index].height[value] = state.slots[index].height[value - 1]
                    state.slots[index].flag1[value] = state.slots[index].flag1[value - 1]
                }
            }

            if let master {
                state.slots[index].vecBNow = master.position
            }
        }
    }

    /// Geometry submission for `PP_HITLINE3` (100), mirroring `CEffectPrim::RenderHitLine3`.
    func renderHitLine3(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0, slot.process > 0 else {
                continue
            }

            let tailLimit = min(20, max(0, Int(slot.vecTNow.y)))
            for segment in 0..<tailLimit where Float(segment) < slot.vecTNow.y {
                let pointA = hitLine3Point(slot: slot, index: segment)
                let pointB = hitLine3Point(slot: slot, index: segment + 1)

                let angle = (Self.angle(dx: pointA.x - pointB.x, dy: pointA.z - pointB.z) + 90) % 360
                let worldA = pointA + slot.vecBNow
                let worldB = pointB + slot.vecBNow

                let alpha = Int(slot.alphaB) - segment * 10
                let colors: (UInt8, UInt8, UInt8)
                switch slot.alphaT {
                case 0:
                    colors = (255, 200, UInt8(clamping: 150 - (5 - segment) * 30))
                case 1:
                    let rg = UInt8(clamping: 120 - (5 - segment) * 22)
                    colors = (rg, rg, 255)
                case 2:
                    colors = (255, 200, UInt8(clamping: 150 - (3 - segment) * 50))
                default:
                    let grey = UInt8(clamping: 255 - (5 - segment) * 30)
                    colors = (grey, grey, grey)
                }

                emitTriangularPrism(
                    into: &collector,
                    assets: assets,
                    worldA: worldA,
                    worldB: worldB,
                    angle: Int(angle),
                    radius: slot.maxHeight,
                    yBias: -5.0,
                    alpha: alpha,
                    red: colors.0,
                    green: colors.1,
                    blue: colors.2,
                    reverseWinding: true
                )

                if slot.alphaT >= 3 {
                    let outerAlpha = Int(Float(Int(slot.alphaB) - segment * 10) * 0.5)
                    emitTriangularPrism(
                        into: &collector,
                        assets: assets,
                        worldA: worldA,
                        worldB: worldB,
                        angle: Int(angle),
                        radius: slot.maxHeight * 4.0,
                        yBias: -5.0,
                        alpha: outerAlpha,
                        red: 0,
                        green: 0,
                        blue: 255,
                        reverseWinding: true,
                        emitQuads: slot.alphaT == 3
                    )
                }
            }
        }
    }

    private func hitLine3Point(slot: EffectPrimitiveSlot, index: Int) -> SIMD3<Float> {
        let phase = slot.height[index]
        let speed = phase > 0.0 ? (phase / 90.0) * slot.distance : 0.0
        let riseAngle = Int(slot.riseAngle)
        let y = -slot.distance * EffectSpace.sine(degrees: Int(phase)) * slot.vecTNow.x
        return SIMD3<Float>(
            speed * EffectSpace.cosine(degrees: riseAngle),
            y,
            speed * EffectSpace.sine(degrees: riseAngle)
        )
    }

    // MARK: - PP_ELECTRIC (101)

    /// Motion update for `PP_ELECTRIC` (101) radial lightning arcs at 60Hz.
    func primElectric() {
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            state.slots[index].distance += 0.4
            if state.slots[index].distance > 15.0 {
                state.slots[index].alphaB -= 2
            }

            if process <= 25 {
                state.slots[index].alphaB += Int16(Int.random(in: 0..<4) + 5)
            }

            if state.slots[index].alphaB < 0 {
                state.slots[index].alphaB = 0
            }

            if process == 1 {
                let tailCount = min(20, max(0, Int(state.slots[index].vecTNow.y)))
                for _ in 0..<21 {
                    state.slots[index].height[0] += 9.0
                    if state.slots[index].height[0] > 180.0 {
                        state.slots[index].height[0] = 180.0
                    } else if tailCount >= 1 {
                        for value in stride(from: tailCount, through: 1, by: -1) {
                            state.slots[index].height[value] = state.slots[index].height[value - 1]
                            state.slots[index].flag1[value] = state.slots[index].flag1[value - 1]
                        }
                    }
                }
            }
        }
    }

    /// Geometry submission for `PP_ELECTRIC` (101), rendering jittered triangular-prism lightning arcs.
    func renderLightningArc(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0, slot.process > 0, slot.vecTNow.y > 0 else {
                continue
            }

            let segmentCount = min(20, max(0, Int(slot.vecTNow.y)))
            var jitterX = [Float](repeating: 0, count: 21)
            var jitterY = [Float](repeating: 0, count: 21)
            var jitterZ = [Float](repeating: 0, count: 21)
            for i in 0..<min(21, segmentCount + 1) {
                jitterY[i] = Float(Int.random(in: 0..<7)) * 0.1 - 0.3
                jitterX[i] = Float(Int.random(in: 0..<7)) * 0.1 - 0.3
                jitterZ[i] = Float(Int.random(in: 0..<7)) * 0.1 - 0.3
            }

            let riseAngle = ((Int(slot.riseAngle) % 360) + 360) % 360
            let cs = EffectSpace.cosine(degrees: riseAngle)
            let sn = EffectSpace.sine(degrees: riseAngle)

            var fade = 0
            for segment in 0..<segmentCount {
                let a0 = slot.height[segment]
                let r0 = a0 > 0 ? (a0 / 90.0) * slot.distance : 0
                let c0 = cs * r0 + jitterX[segment]
                let y0 = -slot.distance * EffectSpace.sine(degrees: Int(a0)) * slot.vecTNow.x + (jitterY[segment] - 2.0)
                let s0 = sn * r0 + jitterZ[segment]

                let a1 = slot.height[segment + 1]
                let r1 = a1 > 0 ? (a1 / 90.0) * slot.distance : 0
                let c1 = cs * r1 + jitterX[segment + 1]
                let y1 = -slot.distance * EffectSpace.sine(degrees: Int(a1)) * slot.vecTNow.x + (jitterY[segment + 1] - 2.0)
                let s1 = sn * r1 + jitterZ[segment + 1]

                let heading = Self.angle(dx: c0 - c1, dy: s0 - s1)
                let side = (Int(heading) + 90) % 360

                let start = SIMD3<Float>(slot.vecBNow.x + c0, y0 + slot.vecBNow.y, s0 + slot.vecBNow.z)
                let end = SIMD3<Float>(slot.vecBNow.x + c1, y1 + slot.vecBNow.y, s1 + slot.vecBNow.z)

                if segment > 0 && segment < 19 {
                    let alpha = Int(slot.alphaB) - fade
                    if alpha > 0 {
                        let red: UInt8
                        let green: UInt8
                        if slot.fullDisplayAngle == 3 {
                            green = UInt8(clamping: Int.random(in: 0..<100))
                            red = UInt8(truncatingIfNeeded: Int.random(in: 0..<50) - 56)
                        } else {
                            let shade = UInt8(truncatingIfNeeded: 6 * segment)
                            red = shade
                            green = shade
                        }
                        emitTriangularPrism(
                            into: &collector,
                            assets: assets,
                            worldA: start,
                            worldB: end,
                            angle: side,
                            radius: slot.maxHeight,
                            yBias: 0,
                            alpha: alpha,
                            red: red,
                            green: green,
                            blue: 255,
                            reverseWinding: true
                        )
                    }
                }

                fade += 5
            }
        }
    }

    // MARK: - PP_ELECTRIC2 (102)

    /// Motion update for `PP_ELECTRIC2` (102) wave-animated lightning tubes at 60Hz.
    func primElectric2() {
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            state.slots[index].distance += 0.6

            if process <= 10 {
                state.slots[index].alphaB += Int16(Int.random(in: 0..<6) + 15)
            }
            if process > 20 {
                state.slots[index].alphaB -= 5
            }
            if state.slots[index].alphaB < 0 {
                state.slots[index].alphaB = 0
            }

            let tailCount = min(20, max(0, Int(state.slots[index].vecTNow.y)))
            if process == 1 {
                for _ in 0..<21 {
                    state.slots[index].height[0] += 18.0
                    if state.slots[index].height[0] >= 360.0 {
                        state.slots[index].height[0] -= 360.0
                        continue
                    }
                    if tailCount >= 1 {
                        for value in stride(from: tailCount, through: 1, by: -1) {
                            state.slots[index].height[value] = state.slots[index].height[value - 1]
                        }
                    }
                }
            } else {
                for value in 0...tailCount {
                    state.slots[index].height[value] += 8.0
                    if state.slots[index].height[value] >= 360.0 {
                        state.slots[index].height[value] -= 360.0
                    }
                    if state.slots[index].height[value] < 0 {
                        state.slots[index].height[value] += 360.0
                    }
                }
            }
        }
    }

    /// Geometry submission for `PP_ELECTRIC2` (102), rendering oscillating lightning tubes.
    func renderLightningTube(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0, slot.process > 0, slot.vecTNow.y > 0 else {
                continue
            }

            let segmentCount = min(20, max(0, Int(slot.vecTNow.y)))
            var jitterX = [Float](repeating: 0, count: 21)
            var jitterY = [Float](repeating: 0, count: 21)
            var jitterZ = [Float](repeating: 0, count: 21)
            for i in 0..<min(21, segmentCount + 1) {
                jitterY[i] = Float(Int.random(in: 0..<11)) * 0.1 - 0.5
                jitterX[i] = Float(Int.random(in: 0..<11)) * 0.1 - 0.5
                jitterZ[i] = Float(Int.random(in: 0..<11)) * 0.1 - 0.5
            }

            let riseAngle = ((Int(slot.riseAngle) % 360) + 360) % 360
            let cs = EffectSpace.cosine(degrees: riseAngle)
            let sn = EffectSpace.sine(degrees: riseAngle)

            var fade = 150
            var rise = 0
            for segment in 0..<segmentCount {
                let next = segment + 1
                let t0 = segment > 0 ? Float(segment) / 5.0 * slot.distance : 0
                let c0 = cs * t0 + jitterX[segment]
                let s0 = sn * t0 + jitterZ[segment]
                let y0 = jitterY[segment] - 8.0 - EffectSpace.sine(degrees: Int(slot.height[segment])) * 15.0 * slot.vecTNow.x

                let t1 = Float(next) / 5.0 * slot.distance
                let c1 = cs * t1 + jitterX[next]
                let s1 = sn * t1 + jitterZ[next]
                let y1 = jitterY[next] - 8.0 - EffectSpace.sine(degrees: Int(slot.height[next])) * 15.0 * slot.vecTNow.x

                let heading = Self.angle(dx: c0 - c1, dy: s0 - s1)
                let side = (Int(heading) + 90) % 360

                let start = SIMD3<Float>(slot.vecBNow.x + c0, slot.vecBNow.y + y0, slot.vecBNow.z + s0)
                let end = SIMD3<Float>(slot.vecBNow.x + c1, slot.vecBNow.y + y1, slot.vecBNow.z + s1)

                if next > 1 && next < 20 {
                    let alpha = (fade > 0 ? rise - 135 : fade) + Int(slot.alphaB)
                    if alpha > 0 {
                        let red = UInt8(clamping: Int.random(in: 0..<121))
                        let green = UInt8(clamping: Int.random(in: 0..<121))
                        emitTriangularPrism(
                            into: &collector,
                            assets: assets,
                            worldA: start,
                            worldB: end,
                            angle: side,
                            radius: slot.maxHeight,
                            yBias: 0,
                            alpha: alpha,
                            red: red,
                            green: green,
                            blue: 255,
                            reverseWinding: true
                        )
                    }
                }

                fade -= 15
                rise += 15
            }
        }
    }

    // MARK: - Primitive 171

    /// Motion update for primitive `171` orbiting breathing glow disc at 60Hz.
    func primGlowDisc(context: EffectTickContext) {
        guard state.slots[0].life == 1 else {
            return
        }

        faceCamera(world: context.world)
        followMaster()
        state.slots[0].process += 1

        if state.slots[0].height[9] == 0 {
            state.slots[0].alphaB += 4
            if state.slots[0].alphaB > 255 {
                state.slots[0].alphaB = 255
                state.slots[0].height[9] = 1.0
            }
        } else {
            state.slots[0].alphaB -= 2
            if state.slots[0].alphaB < 0 {
                state.slots[0].alphaB = 0
                state.slots[0].height[9] = 0
            }
        }

        let orbitAngle = Int(state.slots[0].height[6])
        state.slots[0].vecBNow = SIMD3<Float>(
            EffectSpace.sine(degrees: Int(state.slots[0].height[0])) + EffectSpace.sine(degrees: orbitAngle) * 15.0,
            EffectSpace.sine(degrees: Int(state.slots[0].height[4])),
            EffectSpace.sine(degrees: Int(state.slots[0].height[2])) + EffectSpace.cosine(degrees: orbitAngle) * 15.0
        )
    }

    /// Geometry submission for primitive `171`, rendering a two-layer pulsing glow disc.
    func renderGlowDisc(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let slot = state.slots[0]
        guard slot.life == 1 else {
            return
        }

        let rot0 = slot.alphaT
        let rot1 = state.slots[1].alphaT
        let wobble = slot.distance * EffectSpace.sine(degrees: Int(slot.height[8])) * 0.05

        let outerRadius = (Float(slot.alphaB) / 255.0 * 0.2 + 1.0) * slot.distance + wobble
        let outerCorners = Self.facingSquareCorners(radius: outerRadius, rot0: rot0, rot1: rot1)
        renderTeiRect(
            into: &collector,
            assets: assets,
            alpha: slot.alphaB,
            v1: slot.vecBNow + outerCorners.0,
            v2: slot.vecBNow + outerCorners.1,
            v3: slot.vecBNow + outerCorners.2,
            v4: slot.vecBNow + outerCorners.3,
            blendSelector: 0,
            textureIndex: 0,
            isWorldPosition: false,
            red: 180,
            green: 180,
            blue: 180,
            extra: 2
        )

        let innerRadius = slot.distance + wobble
        let innerCorners = Self.facingSquareCorners(radius: innerRadius, rot0: rot0, rot1: rot1)
        renderTeiRect(
            into: &collector,
            assets: assets,
            alpha: 255,
            v1: slot.vecBNow + innerCorners.0,
            v2: slot.vecBNow + innerCorners.1,
            v3: slot.vecBNow + innerCorners.2,
            v4: slot.vecBNow + innerCorners.3,
            blendSelector: 0,
            textureIndex: 0,
            isWorldPosition: false,
            red: 255,
            green: 255,
            blue: 255
        )
    }

    // MARK: - Shared Helpers

    private func emitTriangularPrism(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?,
        worldA: SIMD3<Float>,
        worldB: SIMD3<Float>,
        angle: Int,
        radius: Float,
        yBias: Float,
        alpha: Int,
        red: UInt8,
        green: UInt8,
        blue: UInt8,
        reverseWinding: Bool,
        emitQuads: Bool = true
    ) {
        var vec1 = SIMD3<Float>.zero
        var vec3 = SIMD3<Float>.zero
        let cosAngle = EffectSpace.cosine(degrees: angle)
        let sinAngle = EffectSpace.sine(degrees: angle)

        for vertex in 0...3 {
            let cornerAngle = vertex * 120
            let tx = radius * EffectSpace.cosine(degrees: cornerAngle)
            let ry = radius * EffectSpace.sine(degrees: cornerAngle) + yBias
            let rx = tx * cosAngle
            let rz = tx * sinAngle
            let vec2 = SIMD3<Float>(worldA.x + rx, worldA.y + ry, worldA.z + rz)
            let vec4 = SIMD3<Float>(worldB.x + rx, worldB.y + ry, worldB.z + rz)

            if vertex > 0, emitQuads, alpha > 0 {
                let clampedAlpha = Int16(min(255, alpha))
                let (v1, v2, v3, v4) = reverseWinding
                    ? (vec2, vec4, vec3, vec1)
                    : (vec1, vec2, vec4, vec3)
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: clampedAlpha,
                    v1: v1,
                    v2: v2,
                    v3: v3,
                    v4: v4,
                    blendSelector: 0,
                    textureIndex: 0,
                    isWorldPosition: true,
                    red: red,
                    green: green,
                    blue: blue
                )
            }

            vec1 = vec2
            vec3 = vec4
        }
    }
}
