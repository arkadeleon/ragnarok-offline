//
//  EffectPrimitive+Ground.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/25.
//

import simd

extension EffectPrimitive {

    // MARK: - PP_MAPPARTICLE (27)
    // PrimMapParticle / RenderGroundBubbles

    // MARK: - Primitive 29
    // PrimFloatingMotes / RenderGroundFog

    // MARK: - Primitive 44
    // PrimExpandPulse / RenderRotatedPlate

    // MARK: - PP_BOTTOM (47)

    /// Motion update for `PP_BOTTOM` (47), mirroring `CEffectPrim::PrimBottom` at 60Hz.
    func primBottom(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1

        if state.slots[0].process % 6 == 0 {
            for index in stride(from: 3, through: 1, by: -1) where state.slots[index].life > 0 {
                let previous = state.slots[index - 1]
                state.slots[index].fullDisplayAngle = previous.fullDisplayAngle
                state.slots[index].distance = previous.distance + 0.5
                state.slots[index].height[8] = previous.height[8]
                state.slots[index].alphaB = max(0, previous.alphaB - 50)
                state.slots[index].vecBNow = previous.vecBNow
                state.slots[index].flag1[0] = previous.flag1[0]
                state.slots[index].flag1[2] = 2
                state.slots[index].height[7] = 0
            }
        }

        state.slots[0].height[8] += 5.0
        if state.slots[0].height[8] >= 360.0 {
            state.slots[0].height[8] -= 360.0
        }

        state.slots[0].rotStart += 1
        if state.slots[0].rotStart >= 360 {
            state.slots[0].rotStart -= 360
        }

        state.slots[0].vecBNow.x = position.x
        state.slots[0].vecBNow.z = position.z
        state.slots[0].vecBPre.y = position.y - 6.0
        let bob = EffectSpace.sine(degrees: Int(state.slots[0].rotStart))
        state.slots[0].vecBNow.y = state.slots[0].vecBPre.y + 3.0 * bob

        if state.slots[0].flag1[2] == 7 {
            state.slots[0].fullDisplayAngle += 10
            if state.slots[0].fullDisplayAngle >= 360 {
                state.slots[0].fullDisplayAngle -= 360
            }
        }
    }

    // MARK: - PP_BOTTOM2 (48)

    /// Motion update for `PP_BOTTOM2` (48), mirroring `CEffectPrim::PrimBottom2` at 60Hz.
    func primBottom2() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1

            let speed: Int16 = state.slots[index].height[0] == 1.0 ? 4 : 2
            state.slots[index].fullDisplayAngle += speed
            if state.slots[index].fullDisplayAngle >= 360 {
                state.slots[index].fullDisplayAngle -= 360
            }

            let angle = Int(state.slots[index].fullDisplayAngle)
            state.slots[index].maxHeight = 20.0 + 10.0 * EffectSpace.sine(degrees: angle)
        }
    }

    /// Geometry submission for `PP_BOTTOM2` (48), mirroring `CEffectPrim::RenderColorPlane`.
    func renderColorPlane(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let height = -slot.maxHeight
            let v1 = SIMD3<Float>(slot.vecBNow.x, 0, slot.vecBNow.z)
            let v2 = SIMD3<Float>(slot.vecBPre.x, 0, slot.vecBPre.z)
            let v3 = SIMD3<Float>(slot.vecBPre.x, height, slot.vecBPre.z)
            let v4 = SIMD3<Float>(slot.vecBNow.x, height, slot.vecBNow.z)

            let blendSelector: Int16
            let red: UInt8
            let green: UInt8
            let blue: UInt8
            switch slot.height[0] {
            case 1.0:
                blendSelector = 1
                (red, green, blue) = (255, 155, 155)
            case 2.0:
                blendSelector = 1
                (red, green, blue) = (155, 255, 155)
            case 3.0:
                blendSelector = 0
                (red, green, blue) = (255, 255, 100)
            case 4.0:
                blendSelector = 0
                (red, green, blue) = (255, 150, 150)
            default:
                blendSelector = 0
                (red, green, blue) = (255, 255, 255)
            }

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: v1,
                v2: v2,
                v3: v3,
                v4: v4,
                blendSelector: blendSelector,
                textureIndex: 0,
                isWorldPosition: false,
                red: red,
                green: green,
                blue: blue
            )
        }
    }

    // MARK: - PP_BOTTOMOUT (49)

    /// Motion update for `PP_BOTTOMOUT` (49), mirroring `CEffectPrim::PrimBottomOut` at 60Hz.
    func primBottomOut(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1

            if state.slots[index].process <= 10 {
                state.slots[index].alphaB += 25
            } else {
                state.slots[index].alphaB -= 5
                if state.slots[index].alphaB <= 0 {
                    state.slots[index].alphaB = 0
                    state.slots[index].process = 0
                    if state.slots[index].flag1[1] == 0 {
                        state.slots[index].vecBNow.y = position.y
                    } else {
                        state.slots[index].vecBNow.y = position.y - 5.0
                    }
                }
                state.slots[index].vecBNow.y -= 0.2
            }

            state.slots[index].height[8] += 5.0
            if state.slots[index].height[8] >= 360.0 {
                state.slots[index].height[8] -= 360.0
            }

            if state.slots[index].flag1[1] == 1 {
                state.slots[index].fullDisplayAngle += 5
                if state.slots[index].fullDisplayAngle >= 360 {
                    state.slots[index].fullDisplayAngle -= 360
                }
            }
        }
    }

    // MARK: - PP_CHEMICAL2 (55)
    // PrimChemical2 / RenderFloorRect

    // MARK: - PP_CHEMICAL3 (56)
    // PrimChemical3 / RenderGroundBar

    // MARK: - PP_RECT_UP (64)

    /// Motion update for `PP_RECT_UP` (64), mirroring `CEffectPrim::PrimPulseRing` at 60Hz.
    func primPulseRing() {
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            let mode = state.slots[index].height[3]
            var displayAngle = state.slots[index].fullDisplayAngle + 1
            if displayAngle >= 360 {
                displayAngle -= 360
            }
            state.slots[index].fullDisplayAngle = displayAngle

            if process > Int(state.slots[index].alphaT) {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 2)
            }

            let maxHeight = state.slots[index].maxHeight
            var pulseHeight = maxHeight * EffectSpace.sine(degrees: Int(displayAngle)) * 0.35 + maxHeight * 0.65
            if process < 90 {
                pulseHeight *= EffectSpace.sine(degrees: process)
            }
            state.slots[index].height[2] = pulseHeight

            if mode == 4.0 {
                if state.slots[index].height[6] == 0.0 {
                    state.slots[index].height[5] += 1.0
                    if state.slots[index].height[5] > 200.0 {
                        state.slots[index].height[6] = 1.0
                        state.slots[index].height[5] = 200.0
                    }
                } else if state.slots[index].height[6] == 1.0 {
                    state.slots[index].height[5] -= 1.0
                    if state.slots[index].height[5] < 0.0 {
                        state.slots[index].height[6] = 0.0
                        state.slots[index].height[5] = 0.0
                    }
                }
            }
        }
    }

    /// Geometry submission for `PP_RECT_UP` (64), mirroring `CEffectPrim::RenderRectUp`.
    func renderRectUp(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let cs1 = EffectSpace.cosine(degrees: Int(slot.rotStart))
            let sn1 = EffectSpace.sine(degrees: Int(slot.rotStart))
            let halfWidth = slot.height[0]
            let halfDepth = slot.height[1]

            let bPre = SIMD3<Float>(cs1 * halfWidth - sn1 * halfDepth, -1.0, sn1 * halfWidth + cs1 * halfDepth)
            let bNow = SIMD3<Float>(cs1 * halfWidth - sn1 * (-halfDepth), -1.0, sn1 * halfWidth + cs1 * (-halfDepth))
            let tNow = SIMD3<Float>(cs1 * (-halfWidth) - sn1 * (-halfDepth), -1.0, sn1 * (-halfWidth) + cs1 * (-halfDepth))
            let tPre = SIMD3<Float>(cs1 * (-halfWidth) - sn1 * halfDepth, -1.0, sn1 * (-halfWidth) + cs1 * halfDepth)
            state.slots[index].vecBPre = bPre
            state.slots[index].vecBNow = bNow
            state.slots[index].vecTNow = tNow
            state.slots[index].vecTPre = tPre

            let red: UInt8
            let green: UInt8
            let blue: UInt8
            let blendSelector: Int16
            switch slot.height[3] {
            case 1.0:
                (red, green, blue, blendSelector) = (235, 255, 235, 1)
            case 2.0:
                (red, green, blue, blendSelector) = (80, 80, 80, 1)
            case 4.0:
                let blueValue = UInt8(clamping: Int(slot.height[4] + slot.height[5]))
                (red, green, blue, blendSelector) = (255, 255, blueValue, 1)
            default:
                (red, green, blue, blendSelector) = (255, 255, 255, 0)
            }

            let topY = -1.0 - slot.height[2]
            emitFourColumnWalls(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                bottomCorners: (bPre, bNow, tNow, tPre),
                topY: topY,
                blendSelector: blendSelector,
                red: red,
                green: green,
                blue: blue
            )

            if slot.height[3] == 2.0 {
                let crossAlpha = Int16(min(255, Int(slot.alphaB) * 2))
                let vec1 = SIMD3<Float>(bPre.x, topY, bPre.z)
                let vec2 = SIMD3<Float>(bNow.x, topY, bNow.z)
                let vec3 = SIMD3<Float>(tPre.x, topY, tPre.z)
                let vec4 = SIMD3<Float>(tNow.x, topY, tNow.z)

                for (p1, p2, p3, p4) in [(bPre, tNow, vec4, vec1), (bNow, tPre, vec3, vec2)] {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: crossAlpha,
                        v1: p1,
                        v2: p2,
                        v3: p3,
                        v4: p4,
                        blendSelector: blendSelector,
                        textureIndex: 0,
                        isWorldPosition: false,
                        red: red,
                        green: green,
                        blue: blue
                    )
                }
            }
        }
    }

    // MARK: - Primitive 72
    // PrimPoison / RenderGrid

    // MARK: - PP_MAGNUM2 (73)

    /// Motion update for `PP_MAGNUM2` (73) radial shockwave cone at 60Hz.
    func primMagnum2() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1

            if state.slots[index].riseAngle < 0 {
                state.slots[index].riseAngle = 0
            }
            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            if state.slots[index].process < 9 {
                if state.slots[index].alphaT == 0 {
                    state.slots[index].alphaB = min(80, state.slots[index].alphaB + 10)
                } else {
                    state.slots[index].alphaB = min(40, state.slots[index].alphaB + 5)
                }
            } else {
                state.slots[index].alphaB -= 30
                if state.slots[index].alphaB < 0 {
                    state.slots[index].alphaB = 0
                    state.slots[index].life = 0
                }
            }
        }
    }

    /// Geometry submission for `PP_MAGNUM2` (73), mirroring `CEffectPrim::RenderMagnum2`.
    func renderMagnum2(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 where state.slots[index].life == 1 {
            let fullAngle = Int(state.slots[index].fullDisplayAngle)
            let step = fullAngle / 20
            guard step > 0 else {
                continue
            }

            var order = 0
            var count = 0
            while count <= fullAngle {
                var angle = Int(state.slots[index].rotStart) + count
                if angle >= 360 {
                    angle -= 360
                }
                if fullAngle == 360 && order == 20 {
                    angle = Int(state.slots[index].rotStart)
                }

                let cs1 = EffectSpace.cosine(degrees: angle)
                let sn1 = EffectSpace.sine(degrees: angle)
                let distance = state.slots[index].distance
                let base = SIMD3<Float>(cs1 * distance, -3.0, sn1 * distance)
                state.slots[index].vecBNow = base

                let riseAngle = Int(state.slots[index].riseAngle)
                let rx = EffectSpace.cosine(degrees: riseAngle) * state.slots[index].maxHeight
                let ry = EffectSpace.sine(degrees: riseAngle) * state.slots[index].maxHeight
                let top = SIMD3<Float>(cs1 * rx + base.x, -(ry + 3.0), sn1 * rx + base.z)
                state.slots[index].vecTNow = top

                if order > 0 && state.slots[index].alphaB > 0 {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        texPart: order - 1,
                        alphaB: state.slots[index].alphaB,
                        alphaT: state.slots[index].alphaB,
                        v1: state.slots[index].vecBPre,
                        v2: base,
                        v3: top,
                        v4: state.slots[index].vecTPre,
                        textureIndex: 0
                    )
                }

                order += 1
                if order >= 21 {
                    order = 20
                }

                state.slots[index].vecBPre = base
                state.slots[index].vecTPre = top
                count += step
            }
        }
    }

    // MARK: - Primitive 80
    // PrimFallingPetals / RenderGroundFog

    // MARK: - Primitive 86

    /// Motion update for primitive `86` directional floor squares at 60Hz.
    func primFloorSquare86() {
        updateFloorSquare(recomputeInitialAngle: true)
    }

    // MARK: - PP_RECT_UP2 (90)

    /// Motion update for `PP_RECT_UP2` (90), mirroring `CEffectPrim::PrimFadingColumns` at 60Hz.
    func primFadingColumns() {
        let groundOffset: Float = 20.0
        let projectionDepthOffset: Float = 10.0
        let depthAverageHalf: Float = 0.5

        for index in 0..<2 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            if state.slots[index].process > 29000 {
                state.slots[index].process = 29000
            } else if state.slots[index].process <= 0 {
                continue
            }

            fadeColumnHeight(at: index, groundOffset: groundOffset, projectionDepthOffset: projectionDepthOffset)
        }

        for index in 2..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            if state.slots[index].process > 29000 {
                state.slots[index].process = 29000
            } else if state.slots[index].process <= 0 {
                continue
            }

            state.slots[index].distance += depthAverageHalf
            let perimeterLimit = state.slots[index].height[0] * 8.0
            if state.slots[index].distance > perimeterLimit {
                state.slots[index].distance -= perimeterLimit
            }

            fadeColumnHeight(at: index, groundOffset: groundOffset, projectionDepthOffset: projectionDepthOffset)
        }

        followMaster()
    }

    /// Geometry submission for `PP_RECT_UP2` (90), mirroring `CEffectPrim::RenderRectUp2`.
    func renderRectUp2(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<2 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let (red, green, blue): (UInt8, UInt8, UInt8) = slot.height[4] < 10.0 ? (200, 250, 200) : (100, 100, 250)
            let halfX = slot.height[0]
            let halfZ = slot.height[1]
            let bPre = SIMD3<Float>(halfX, -1.0, halfZ)
            let bNow = SIMD3<Float>(halfX, -1.0, -halfZ)
            let tNow = SIMD3<Float>(-halfX, -1.0, -halfZ)
            let tPre = SIMD3<Float>(-halfX, -1.0, halfZ)
            state.slots[index].vecBPre = bPre
            state.slots[index].vecBNow = bNow
            state.slots[index].vecTNow = tNow
            state.slots[index].vecTPre = tPre

            emitFourColumnWalls(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                bottomCorners: (bPre, bNow, tNow, tPre),
                topY: -1.0 - slot.height[2],
                blendSelector: 0,
                red: red,
                green: green,
                blue: blue
            )
        }

        let projectionDepthOffset: Float = 10.0
        for index in 2..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let (red, green, blue): (UInt8, UInt8, UInt8) = projectionDepthOffset <= slot.height[4]
                ? (50, 50, 250)
                : (150, 250, 150)

            let halfX = slot.height[0]
            let halfZ = slot.height[1]
            let segLength = slot.height[3]
            let dist = slot.distance
            var bPre = SIMD3<Float>(halfX, -1.0, halfZ)
            var bNow = SIMD3<Float>(halfX, -1.0, -halfZ)
            var tNow = SIMD3<Float>(-halfX, -1.0, -halfZ)
            var tPre = SIMD3<Float>(-halfX, -1.0, halfZ)
            var left: Float = 0

            if dist < halfX * 2.0 {
                bPre.z = halfZ - dist
                bNow.z = bPre.z - segLength
                if bNow.z < -halfZ {
                    left = -halfZ - bNow.z
                    bNow.z = -halfZ
                    tNow.x = bNow.x - left
                }
            } else if dist < halfX * 4.0 {
                bNow.x = halfX - (dist - halfX * 2.0)
                tNow.x = bNow.x - segLength
                if tNow.x < -halfX {
                    left = -halfX - tNow.x
                    tNow.x = -halfX
                    tPre.z = tNow.z + left
                }
            } else if dist < halfX * 6.0 {
                tNow.z = dist - halfX * 4.0 - halfZ
                tPre.z = tNow.z + segLength
                if tPre.z > halfZ {
                    left = tPre.z - halfZ
                    tPre.z = halfZ
                    bPre.x = tPre.x + left
                }
            } else {
                tPre.x = dist - halfX * 6.0 - halfX
                bPre.x = tPre.x + segLength
                if bPre.x > halfX {
                    left = bPre.x - halfX
                    bPre.x = halfX
                    bNow.z = bPre.z - left
                }
            }

            state.slots[index].vecBPre = bPre
            state.slots[index].vecBNow = bNow
            state.slots[index].vecTNow = tNow
            state.slots[index].vecTPre = tPre

            let topY = -1.0 - slot.height[2]
            let vec1 = SIMD3<Float>(bPre.x, topY, bPre.z)
            let vec2 = SIMD3<Float>(bNow.x, topY, bNow.z)
            let vec3 = SIMD3<Float>(tPre.x, topY, tPre.z)
            let vec4 = SIMD3<Float>(tNow.x, topY, tNow.z)

            let primaryQuad: (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>)
            let wrapQuad: (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>)
            if dist < halfX * 2.0 {
                primaryQuad = (bPre, bNow, vec2, vec1)
                wrapQuad = (bNow, tNow, vec4, vec2)
            } else if dist < halfX * 4.0 {
                primaryQuad = (bNow, tNow, vec4, vec2)
                wrapQuad = (tNow, tPre, vec3, vec4)
            } else if dist < halfX * 6.0 {
                primaryQuad = (tNow, tPre, vec3, vec4)
                wrapQuad = (tPre, bPre, vec1, vec3)
            } else {
                primaryQuad = (tPre, bPre, vec1, vec3)
                wrapQuad = (bPre, bNow, vec2, vec1)
            }

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: primaryQuad.0,
                v2: primaryQuad.1,
                v3: primaryQuad.2,
                v4: primaryQuad.3,
                blendSelector: 0,
                textureIndex: 0,
                isWorldPosition: false,
                red: red,
                green: green,
                blue: blue
            )

            if left > 0.0 {
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: slot.alphaB,
                    v1: wrapQuad.0,
                    v2: wrapQuad.1,
                    v3: wrapQuad.2,
                    v4: wrapQuad.3,
                    blendSelector: 0,
                    textureIndex: 0,
                    isWorldPosition: false,
                    red: red,
                    green: green,
                    blue: blue
                )
            }
        }
    }

    private func fadeColumnHeight(at index: Int, groundOffset: Float, projectionDepthOffset: Float) {
        let kind = state.slots[index].height[4]
        let process = state.slots[index].process

        if kind >= groundOffset,
           process > 200,
           let master,
           position.x != master.position.x || position.z != master.position.z,
           state.slots[index].alphaT > 2000 {
            state.slots[index].alphaT = Int16(truncatingIfNeeded: process)
        }

        let alphaT = Int(state.slots[index].alphaT)
        let maxHeight = state.slots[index].maxHeight
        if process > alphaT {
            var angle: Int
            if kind >= groundOffset {
                angle = (alphaT - process + 18) * 5
            } else if kind >= projectionDepthOffset {
                angle = alphaT - process + 90
            } else if kind == 0.0 {
                angle = 2505 - process
            } else {
                angle = 2475 - process
            }
            angle = min(90, max(0, angle))
            state.slots[index].height[2] = EffectSpace.sine(degrees: angle) * maxHeight
        } else if process < 90 {
            state.slots[index].height[2] = EffectSpace.sine(degrees: process) * maxHeight
        } else {
            state.slots[index].height[2] = maxHeight
        }
    }

    // MARK: - Primitive 92

    /// Motion update for primitive `92` directional floor squares at 60Hz.
    func primFloorSquare92() {
        updateFloorSquare(recomputeInitialAngle: false)
    }

    /// Geometry submission for primitives `86` and `92`, rendering world-space rotated floor squares.
    func renderFloorSquare(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let dist = slot.distance
            let center = slot.vecBNow
            var angle = (Int(slot.rotStart) + 45) % 360
            if angle < 0 {
                angle += 360
            }

            var corners: [SIMD3<Float>] = []
            corners.reserveCapacity(4)
            for _ in 0..<4 {
                corners.append(
                    SIMD3<Float>(
                        dist * EffectSpace.cosine(degrees: angle) + center.x,
                        center.y,
                        dist * EffectSpace.sine(degrees: angle) + center.z
                    )
                )
                angle = (angle + 90) % 360
            }

            let textureIndex: Int
            let red: UInt8
            let green: UInt8
            let blue: UInt8
            if slot.flag1[1] == 1 {
                textureIndex = slot.process > 0 ? (slot.process / 6) % 4 : 0
                (red, green, blue) = (205, 205, 255)
            } else if slot.flag1[1] == 2 {
                textureIndex = 0
                (red, green, blue) = (0, 255, 0)
            } else {
                textureIndex = 0
                (red, green, blue) = (200, 200, 255)
            }

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: corners[0],
                v2: corners[1],
                v3: corners[2],
                v4: corners[3],
                blendSelector: 1,
                textureIndex: textureIndex,
                isWorldPosition: true,
                red: red,
                green: green,
                blue: blue
            )
        }
    }

    // MARK: - Primitive 112
    // RenderMagicTarget

    // MARK: - Primitive 119

    /// Motion update for primitive `119` spinning floor slash wave with 3 trailing afterimages at 60Hz.
    func primFloorSquare119() {
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
            state.slots[0].alphaB = min(250, state.slots[0].alphaB + 25)
            state.slots[0].height[1] *= 1.02
        } else {
            state.slots[0].alphaB -= 5
            state.slots[0].height[1] *= 1.04
            if state.slots[0].alphaB < 0 {
                state.slots[0].alphaB = 0
                state.slots[0].life = 0
            }
        }

        let heading = Int(state.slots[0].rotStart)
        state.slots[0].vecBNow.x += state.slots[0].height[1] * EffectSpace.cosine(degrees: heading)
        state.slots[0].vecBNow.z += state.slots[0].height[1] * EffectSpace.sine(degrees: heading)

        shiftFloorSquareTrailIfNeeded(process: process)
    }

    // MARK: - Primitive 122

    /// Motion update for primitive `122` homing floor slash (`PrimSTIN3`) at 60Hz.
    func primSTIN3(context: EffectTickContext) {
        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        let process = state.slots[0].process
        guard process > 0 else {
            return
        }

        let targetPosition = resolvedHomingTargetPosition(world: context.world)
        if targetPosition == nil && state.slots[0].flag1[1] < 10 {
            state.slots[0].flag1[1] = 20
            if process == 1 {
                return
            }
        }

        state.slots[0].riseAngle += 30
        if state.slots[0].riseAngle >= 360 {
            state.slots[0].riseAngle -= 360
        }

        if process == 1, let targetPosition {
            var rotStart = Self.angle(
                dx: targetPosition.x - position.x,
                dy: targetPosition.z - position.z
            )
            if state.slots[0].flag1[2] == 0 {
                rotStart += 90
                if rotStart >= 360 {
                    rotStart -= 360
                }
            } else {
                rotStart -= 90
                if rotStart < 0 {
                    rotStart += 360
                }
            }
            state.slots[0].rotStart = rotStart
        } else if process <= 20 {
            state.slots[0].alphaB = min(250, state.slots[0].alphaB + 15)
        } else if process > 140 || (process > 90 && state.slots[0].flag1[4] == 1) {
            state.slots[0].flag1[1] = 10
        }

        if process > 5 {
            if state.slots[0].flag1[1] == 0 {
                if let targetPosition {
                    let heading = Self.angle(
                        dx: targetPosition.x - state.slots[0].vecBNow.x,
                        dy: targetPosition.z - state.slots[0].vecBNow.z
                    )
                    if state.slots[0].rotStart < heading - 3 || state.slots[0].rotStart > heading + 3 {
                        turnSlot0Heading(step: 5)
                    }
                }
            } else if state.slots[0].flag1[1] == 10 {
                for fade in 0..<4 {
                    state.slots[fade].alphaB -= 5
                    if state.slots[fade].alphaB < 0 {
                        state.slots[fade].alphaB = 0
                        state.slots[fade].life = 0
                    }
                }
                turnSlot0Heading(step: 1)
            } else if state.slots[0].flag1[1] == 20 {
                let heading = Self.angle(
                    dx: position.x - state.slots[0].vecBNow.x,
                    dy: position.z - state.slots[0].vecBNow.z
                )
                if state.slots[0].rotStart < heading - 3 || state.slots[0].rotStart > heading + 3 {
                    turnSlot0Heading(step: 5)
                }
                if process > 50 {
                    state.slots[0].flag1[1] = 10
                }
            }
        }

        let heading = Int(state.slots[0].rotStart)
        state.slots[0].vecBNow.x += state.slots[0].height[1] * EffectSpace.cosine(degrees: heading)
        state.slots[0].vecBNow.z += state.slots[0].height[1] * EffectSpace.sine(degrees: heading)

        shiftFloorSquareTrailIfNeeded(process: process)
    }

    // MARK: - PP_STIN4 (125)

    /// Motion update for `PP_STIN4` (125) curving floor slash wave at 60Hz.
    func primSTIN4(context: EffectTickContext) {
        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        let process = state.slots[0].process
        guard process > 0 else {
            return
        }

        let targetPosition = resolvedHomingTargetPosition(world: context.world)
        if targetPosition == nil {
            state.slots[0].flag1[1] = 10
            if process == 1 {
                return
            }
        }

        state.slots[0].riseAngle += 30
        if state.slots[0].riseAngle >= 360 {
            state.slots[0].riseAngle -= 360
        }

        if process == 1, let targetPosition {
            var rotStart = Self.angle(
                dx: targetPosition.x - position.x,
                dy: targetPosition.z - position.z
            )
            let spread = Int16(Int.random(in: 0..<21) + 25)
            if state.slots[0].flag1[2] == 0 {
                rotStart += spread
                if rotStart >= 360 {
                    rotStart -= 360
                }
            } else {
                rotStart -= spread
                if rotStart < 0 {
                    rotStart += 360
                }
            }
            state.slots[0].rotStart = rotStart
        } else if process <= 20 {
            state.slots[0].alphaB = min(120, state.slots[0].alphaB + 8)
        } else {
            state.slots[0].flag1[1] = 10
        }

        if process > 5 {
            if state.slots[0].flag1[1] == 0, let targetPosition {
                let heading = Self.angle(
                    dx: targetPosition.x - state.slots[0].vecBNow.x,
                    dy: targetPosition.z - state.slots[0].vecBNow.z
                )
                if state.slots[0].rotStart >= heading - 3 && state.slots[0].rotStart <= heading + 3 {
                    state.slots[0].flag1[1] = 10
                } else {
                    turnSlot0Heading(step: 5)
                }
            } else if state.slots[0].flag1[1] == 10 {
                for fade in 0..<4 {
                    state.slots[fade].alphaB -= 5
                    if state.slots[fade].alphaB < 0 {
                        state.slots[fade].alphaB = 0
                        state.slots[fade].life = 0
                    }
                }
                turnSlot0Heading(step: 1)
            }
        }

        let heading = Int(state.slots[0].rotStart)
        state.slots[0].vecBNow.x += state.slots[0].height[1] * EffectSpace.cosine(degrees: heading)
        state.slots[0].vecBNow.z += state.slots[0].height[1] * EffectSpace.sine(degrees: heading)

        shiftFloorSquareTrailIfNeeded(process: process)
    }

    /// Geometry submission for primitives `119`, `122`, and `PP_STIN4` (125).
    func renderFloorSquare2(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let dist = slot.distance
            let center = slot.vecBNow
            var angle = (Int(slot.riseAngle) + 90) % 360
            if angle < 0 {
                angle += 360
            }

            var corners: [SIMD3<Float>] = []
            corners.reserveCapacity(4)
            for _ in 0..<4 {
                corners.append(
                    SIMD3<Float>(
                        dist * EffectSpace.cosine(degrees: angle) + center.x,
                        center.y,
                        dist * EffectSpace.sine(degrees: angle) + center.z
                    )
                )
                angle = (angle + 90) % 360
            }

            let blendSelector: Int16
            let red: UInt8
            let green: UInt8
            let blue: UInt8
            switch slot.flag1[3] {
            case 0:
                (blendSelector, red, green, blue) = (0, 80, 80, 255)
            case 1:
                (blendSelector, red, green, blue) = (0, 80, 255, 80)
            case 2:
                (blendSelector, red, green, blue) = (1, 255, 255, 255)
            case 3:
                (blendSelector, red, green, blue) = (1, 70, 70, 70)
            default:
                continue
            }

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: corners[0],
                v2: corners[1],
                v3: corners[2],
                v4: corners[3],
                blendSelector: blendSelector,
                textureIndex: 0,
                isWorldPosition: true,
                red: red,
                green: green,
                blue: blue
            )
        }
    }

    // MARK: - Primitive 131

    /// Motion update for primitive `131` rising ripple rings at 60Hz.
    func primRisingFan2(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        let caps: [Float] = [70, 90, 110, 130, 150, 170, 190, 210, 230, 250]

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            if process < 20 {
                for ring in 1...10 {
                    state.slots[index].height[ring] = min(caps[ring - 1], state.slots[index].height[ring] + 13.0)
                }
            } else {
                for ring in 1..<10 {
                    state.slots[index].height[ring] = max(0, state.slots[index].height[ring] - 5.0)
                }

                if process > 100 {
                    state.slots[index].height[10] -= 5.0
                    if state.slots[index].height[10] > 0 {
                        state.slots[index].distance *= 1.01
                    }
                    if state.slots[index].height[10] < 0 {
                        state.slots[index].height[10] = 0
                    }
                }
            }

            state.slots[index].distance *= 1.01
        }
    }

    /// Geometry submission for primitive `131`, rendering concentric camera-facing ripple layers.
    func renderRipple(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for index in 0..<4 where state.slots[index].life == 1 {
            let kind = state.slots[index].flag1[4]
            let textureIndex = Int(UInt8(bitPattern: state.slots[index].flag1[0]))
            let base = state.slots[index].height[0]
            let drop: Float = kind == 2 ? 40.0 : 30.0

            for ring in stride(from: 10, through: 1, by: -1) {
                let spread = (10 - ring) * (kind == 2 ? 1 : 3)
                let rx = Float(spread) + state.slots[index].distance

                let bPre = SIMD3<Float>(rx * EffectSpace.cosine(degrees: 45), 0, rx * EffectSpace.sine(degrees: 45))
                let bNow = SIMD3<Float>(rx * EffectSpace.cosine(degrees: 135), 0, rx * EffectSpace.sine(degrees: 135))
                let tNow = SIMD3<Float>(rx * EffectSpace.cosine(degrees: 225), 0, rx * EffectSpace.sine(degrees: 225))
                let tPre = SIMD3<Float>(rx * EffectSpace.cosine(degrees: 315), 0, rx * EffectSpace.sine(degrees: 315))
                state.slots[index].vecBPre = bPre
                state.slots[index].vecBNow = bNow
                state.slots[index].vecTNow = tNow
                state.slots[index].vecTPre = tPre

                var vec1 = SIMD3<Float>(bPre.x + base, bPre.y, bPre.z)
                var vec2 = SIMD3<Float>(bNow.x + base, bNow.y, bNow.z)
                var vec3 = SIMD3<Float>(tNow.x + base, tNow.y, tNow.z)
                var vec4 = SIMD3<Float>(tPre.x + base, tPre.y, tPre.z)
                Self.towardScreen(&vec1, &vec2, &vec3, &vec4, rot0: rot0, rot1: rot1)

                vec1.y -= drop
                vec2.y -= drop
                vec3.y -= drop
                vec4.y -= drop

                let alpha = Int(state.slots[index].height[ring])
                if alpha > 0 {
                    let shade: UInt8 = ring == 10 ? 55 : 5
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: Int16(clamping: alpha),
                        v1: vec2,
                        v2: vec1,
                        v3: vec4,
                        v4: vec3,
                        blendSelector: 0,
                        textureIndex: textureIndex,
                        isWorldPosition: false,
                        red: shade,
                        green: shade,
                        blue: 255
                    )
                }
            }
        }
    }

    // MARK: - Primitive 143

    /// Motion update for primitive `143` spinning textured ground squares at 60Hz.
    func primTextureSpin() {
        followMaster()

        let frames = Float(max(1, state.totalTexture))
        for index in 0..<4 where state.slots[index].life == 1 {
            let process = state.slots[index].process + 1
            state.slots[index].process = process

            if state.slots[index].height[2] == 0 {
                state.slots[index].rotStart += 6
                if state.slots[index].rotStart >= 360 {
                    state.slots[index].rotStart -= 360
                }
                state.slots[index].riseAngle += 3
                if state.slots[index].riseAngle >= 360 {
                    state.slots[index].riseAngle -= 360
                }
            }

            if process % 4 == 0 {
                state.slots[index].height[1] += 1.0
            }
            if state.slots[index].height[1] >= frames {
                state.slots[index].height[1] -= frames
            }
        }
    }

    /// Geometry submission for primitive `143`, rendering pulsing rotating ground squares.
    func renderGroundSquare(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 where state.slots[index].life == 1 {
            let (bPre, bNow, tNow, tPre) = updateGroundSquareCorners(forSlot: index)
            let slot = state.slots[index]
            let blendSelector: Int16 = slot.height[2] == 1.0 ? 1 : 0
            let textureIndex = Int(slot.height[1])

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: bPre,
                v2: bNow,
                v3: tNow,
                v4: tPre,
                blendSelector: blendSelector,
                textureIndex: textureIndex,
                isWorldPosition: false,
                red: 255,
                green: 255,
                blue: 255
            )
        }
    }

    // MARK: - Primitive 148

    /// Geometry submission for primitive `148`, cross-fading two ground textures on a pulsing square.
    func renderGroundSquareBlend(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 where state.slots[index].life == 1 {
            let (bPre, bNow, tNow, tPre) = updateGroundSquareCorners(forSlot: index)
            var alpha = Int16((state.slots[index].process % 256) * 2)
            if alpha > 255 {
                alpha = 511 - alpha
            }

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: alpha,
                v1: bPre,
                v2: bNow,
                v3: tNow,
                v4: tPre,
                blendSelector: 1,
                textureIndex: 0,
                isWorldPosition: false,
                red: 255,
                green: 255,
                blue: 255
            )
            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: 255 - alpha,
                v1: bPre,
                v2: bNow,
                v3: tNow,
                v4: tPre,
                blendSelector: 1,
                textureIndex: 1,
                isWorldPosition: false,
                red: 255,
                green: 255,
                blue: 255
            )
        }
    }

    // MARK: - Shared Helpers

    private func updateFloorSquare(recomputeInitialAngle: Bool) {
        for index in 0..<4 where state.slots[index].life == 1 {
            let previousProcess = state.slots[index].process
            state.slots[index].process += 1
            guard state.slots[index].process > 0 else {
                continue
            }

            if previousProcess == 0 {
                if recomputeInitialAngle {
                    var rotStart = Self.angle(
                        dx: state.deltaPos.x - position.x,
                        dy: state.deltaPos.z - position.z
                    )
                    let turn = if state.slots[index].flag1[1] == 1 {
                        Int16(Int.random(in: 0..<11) - 5)
                    } else {
                        Int16(Int.random(in: 0..<31) - 15)
                    }
                    rotStart += turn
                    if rotStart >= 360 {
                        rotStart -= 360
                    }
                    if rotStart < 0 {
                        rotStart += 360
                    }
                    state.slots[index].rotStart = rotStart
                }
            } else if previousProcess < 10 {
                state.slots[index].alphaB += 10
                state.slots[index].height[1] *= 1.02
            } else {
                state.slots[index].alphaB -= 5
                state.slots[index].height[1] *= 1.04
                if state.slots[index].alphaB < 0 {
                    state.slots[index].alphaB = 0
                    state.slots[index].life = 0
                }
            }

            let heading = Int(state.slots[index].rotStart)
            state.slots[index].vecBNow.x += state.slots[index].height[1] * EffectSpace.cosine(degrees: heading)
            state.slots[index].vecBNow.z += state.slots[index].height[1] * EffectSpace.sine(degrees: heading)
        }
    }

    private func resolvedHomingTargetPosition(world: any EffectWorldContext) -> SIMD3<Float>? {
        if let targetObjectID = state.slots[0].targetObjectID ?? master?.targetObjectID {
            return world.targetState(for: targetObjectID)?.effectPosition
        }
        return nil
    }

    private func turnSlot0Heading(step: Int16) {
        if state.slots[0].flag1[2] == 0 {
            state.slots[0].rotStart -= step
            if state.slots[0].rotStart < 0 {
                state.slots[0].rotStart += 360
            }
        } else {
            state.slots[0].rotStart += step
            if state.slots[0].rotStart >= 360 {
                state.slots[0].rotStart -= 360
            }
        }
    }

    private func shiftFloorSquareTrailIfNeeded(process: Int) {
        guard process % 3 == 0 else {
            return
        }
        for index in stride(from: 3, through: 1, by: -1) {
            state.slots[index].vecBNow = state.slots[index - 1].vecBNow
            state.slots[index].alphaB = Int16(Float(state.slots[index - 1].alphaB) * 0.8)
            state.slots[index].riseAngle = state.slots[index - 1].riseAngle
        }
    }

    private func updateGroundSquareCorners(forSlot index: Int) -> (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>) {
        let slot = state.slots[index]
        let radius = Float(
            (Double(EffectSpace.sine(degrees: Int(slot.riseAngle))) + 1.0) * Double(slot.distance * 0.1)
                + Double(slot.distance) * 0.8
        )
        let y = slot.height[0]

        let a0 = ((Int(slot.rotStart) % 360) + 360) % 360
        let a1 = (a0 + 90) % 360
        let a2 = (a1 + 90) % 360
        let a3 = (a2 + 90) % 360

        let bPre = SIMD3<Float>(EffectSpace.cosine(degrees: a0) * radius, y, EffectSpace.sine(degrees: a0) * radius)
        let bNow = SIMD3<Float>(EffectSpace.cosine(degrees: a1) * radius, y, EffectSpace.sine(degrees: a1) * radius)
        let tNow = SIMD3<Float>(EffectSpace.cosine(degrees: a2) * radius, y, EffectSpace.sine(degrees: a2) * radius)
        let tPre = SIMD3<Float>(EffectSpace.cosine(degrees: a3) * radius, y, EffectSpace.sine(degrees: a3) * radius)

        state.slots[index].vecBPre = bPre
        state.slots[index].vecBNow = bNow
        state.slots[index].vecTNow = tNow
        state.slots[index].vecTPre = tPre
        return (bPre, bNow, tNow, tPre)
    }

    private func emitFourColumnWalls(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?,
        alpha: Int16,
        bottomCorners: (bPre: SIMD3<Float>, bNow: SIMD3<Float>, tNow: SIMD3<Float>, tPre: SIMD3<Float>),
        topY: Float,
        blendSelector: Int16,
        red: UInt8,
        green: UInt8,
        blue: UInt8
    ) {
        let top1 = SIMD3<Float>(bottomCorners.bPre.x, topY, bottomCorners.bPre.z)
        let top2 = SIMD3<Float>(bottomCorners.bNow.x, topY, bottomCorners.bNow.z)
        let top3 = SIMD3<Float>(bottomCorners.tPre.x, topY, bottomCorners.tPre.z)
        let top4 = SIMD3<Float>(bottomCorners.tNow.x, topY, bottomCorners.tNow.z)

        let walls: [(SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>)] = [
            (bottomCorners.bPre, bottomCorners.bNow, top2, top1),
            (bottomCorners.bNow, bottomCorners.tNow, top4, top2),
            (bottomCorners.tNow, bottomCorners.tPre, top3, top4),
            (bottomCorners.tPre, bottomCorners.bPre, top1, top3),
        ]

        for (v1, v2, v3, v4) in walls {
            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: alpha,
                v1: v1,
                v2: v2,
                v3: v3,
                v4: v4,
                blendSelector: blendSelector,
                textureIndex: 0,
                isWorldPosition: false,
                red: red,
                green: green,
                blue: blue
            )
        }
    }
}
