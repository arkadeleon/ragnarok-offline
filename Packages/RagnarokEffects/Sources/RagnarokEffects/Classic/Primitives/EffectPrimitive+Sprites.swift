//
//  EffectPrimitive+Sprites.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/25.
//

import Foundation
import RagnarokRendering
import simd

extension EffectPrimitive {

    // MARK: - PP_3DPARTICLE (5)
    // Prim3DParticle / RenderSegmentSprites2

    // MARK: - PP_3DPARTICLEGRAVITY (6)
    // Prim3DParticleGravity / RenderSegmentSprites2

    // MARK: - PP_3DPARTICLEORBIT (7)
    // Prim3DParticleOrbit / RenderSegmentSprites2

    // MARK: - PP_3DPARTICLESPLINE (8)
    // Prim3DParticleSpline / RenderSegmentSprites2

    // MARK: - PP_3DTEXTURE (15) / PP_3DCROSSTEXTURE (16)

    /// Motion update for `PP_3DTEXTURE` (15) and `PP_3DCROSSTEXTURE` (16) at 60Hz.
    @discardableResult
    func moveEffectPrimitive(context: EffectTickContext) -> Bool {
        let masterPos = master?.position ?? state.orgPos
        state.orgPos = masterPos + state.deltaPos2

        if state.changePoint == state.stateCnt {
            state.changePointReached = true
            let sentinel = EffectPrimitiveState.defaultChangeSentinel
            if state.changeWidthSpeed != sentinel {
                state.widthSpeed = state.changeWidthSpeed
            }
            if state.changeHeightSpeed != sentinel {
                state.heightSpeed = state.changeHeightSpeed
            }
            if state.changeSpeed != sentinel {
                state.speed = state.changeSpeed
            }
            if state.changeWidthAccel != sentinel {
                state.widthAccel = state.changeWidthAccel
            }
            if state.changeHeightAccel != sentinel {
                state.heightAccel = state.changeHeightAccel
            }
            if state.changeAccel != sentinel {
                state.accel = state.changeAccel
            }
            if state.changeSpeed3d.x != sentinel {
                state.speed3d.x = state.changeSpeed3d.x
            }
            if state.changeSpeed3d.y != sentinel {
                state.speed3d.y = state.changeSpeed3d.y
            }
            if state.changeSpeed3d.z != sentinel {
                state.speed3d.z = state.changeSpeed3d.z
            }
            state.changeWidthSpeed = sentinel
            state.changeHeightSpeed = sentinel
            state.changeSpeed = sentinel
            state.changeWidthAccel = sentinel
            state.changeHeightAccel = sentinel
            state.changeAccel = sentinel
            state.changeSpeed3d = SIMD3<Float>(repeating: sentinel)
            state.changeAccel3d = SIMD3<Float>(repeating: sentinel)
        }

        return advanceTextured3DPrimitive(origin: state.orgPos, context: context, isNoMaster: false)
    }

    /// Geometry submission for `PP_3DTEXTURE` (15) oriented 3D texture quad.
    func render3DTexture(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let width = state.widthSize
        let height = state.heightSize

        var v0 = SIMD3<Float>(0, -height, width)
        var v1 = SIMD3<Float>(0, -height, -width)
        var v2 = SIMD3<Float>(0, height, width)
        var v3 = SIMD3<Float>(0, height, -width)

        if (state.pattern & 0x80) != 0 {
            v0.y *= 2
            v1.y *= 2
            v2.y = 0
            v3.y = 0
        }
        if (state.pattern & 8) != 0 {
            v2.y = 0
            v3.y = 0
        }

        let p0 = EffectSpace.transformVector(v0, by: state.rotTransform) + position
        let p1 = EffectSpace.transformVector(v1, by: state.rotTransform) + position
        let p2 = EffectSpace.transformVector(v2, by: state.rotTransform) + position
        let p3 = EffectSpace.transformVector(v3, by: state.rotTransform) + position

        let color = EffectPrimitiveBatchCollector.unpackARGB(state.argb)
        let texture = resolveTexture(at: currentMotion, assets: assets)
        let renderState = EffectPrimitiveRenderState(renderFlag: state.renderFlag)

        collector.appendEffectQuad(
            p0: p0,
            p1: p1,
            p2: p3,
            p3: p2,
            uv0: SIMD2<Float>(0, state.v1),
            uv1: SIMD2<Float>(1, state.v1),
            uv2: SIMD2<Float>(1, state.v2),
            uv3: SIMD2<Float>(0, state.v2),
            color0: color,
            color1: color,
            color2: color,
            color3: color,
            texture: texture,
            renderState: renderState,
            effectCenter: position
        )
    }

    /// Geometry submission for `PP_3DCROSSTEXTURE` (16) crossed 3D texture planes.
    func renderCrossPlanes(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let w = state.widthSize
        let h = state.heightSize
        let planes: [(SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>)] = [
            (
                SIMD3<Float>(-h, 0, w),
                SIMD3<Float>(-h, 0, -w),
                SIMD3<Float>(h, 0, w),
                SIMD3<Float>(h, 0, -w)
            ),
            (
                SIMD3<Float>(0, -h, w),
                SIMD3<Float>(0, -h, -w),
                SIMD3<Float>(0, h, w),
                SIMD3<Float>(0, h, -w)
            ),
        ]

        let color = EffectPrimitiveBatchCollector.unpackARGB(state.argb)
        let texture = resolveTexture(at: currentMotion, assets: assets)
        let renderState = EffectPrimitiveRenderState(renderFlag: EffectPrimitiveState.RenderFlag.alpha)

        for (c0, c1, c2, c3) in planes {
            let p0 = EffectSpace.transformVector(c0, by: state.transform) + position
            let p1 = EffectSpace.transformVector(c1, by: state.transform) + position
            let p2 = EffectSpace.transformVector(c2, by: state.transform) + position
            let p3 = EffectSpace.transformVector(c3, by: state.transform) + position

            collector.appendEffectQuad(
                p0: p0,
                p1: p1,
                p2: p3,
                p3: p2,
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
                effectCenter: position
            )
        }
    }

    // MARK: - PP_3DPARTICLE_NOMASTER (21)
    // Prim3DParticleNoMaster / RenderSegmentSprites2

    // MARK: - PP_3DTEXTURE_NOMASTER (22)

    /// Motion update for `PP_3DTEXTURE_NOMASTER` (22) detached 3D texture at 60Hz.
    @discardableResult
    func prim3DTextureNoMaster(context: EffectTickContext) -> Bool {
        let origin = state.orgPos + state.deltaPos2

        if state.changePoint == state.stateCnt {
            let sentinel = EffectPrimitiveState.defaultChangeSentinel
            if state.changeWidthSpeed != sentinel {
                state.widthSpeed = state.changeWidthSpeed
            }
            if state.changeHeightSpeed != sentinel {
                state.heightSpeed = state.changeHeightSpeed
            }
            if state.changeSpeed != sentinel {
                state.speed = state.changeSpeed
            }
            if state.changeWidthAccel != sentinel {
                state.widthAccel = state.changeWidthAccel
            }
            if state.changeHeightAccel != sentinel {
                state.heightAccel = state.changeHeightAccel
            }
            if state.changeAccel != sentinel {
                state.accel = state.changeAccel
            }
            if state.changeSpeed3d.x != sentinel {
                state.speed3d.x = state.changeSpeed3d.x
            }
            if state.changeSpeed3d.y != sentinel {
                state.speed3d.y = state.changeSpeed3d.y
            }
            if state.changeSpeed3d.z != sentinel {
                state.speed3d.z = state.changeSpeed3d.z
            }
            if state.changeAccel3d.x != sentinel {
                state.deltaPosAccel.x = state.changeAccel3d.x
            }
            if state.changeAccel3d.y != sentinel {
                state.deltaPosAccel.y = state.changeAccel3d.y
            }
            if state.changeAccel3d.z != sentinel {
                state.deltaPosAccel.z = state.changeAccel3d.z
            }
        }

        return advanceTextured3DPrimitive(origin: origin, context: context, isNoMaster: true)
    }

    /// Geometry submission for `PP_3DTEXTURE_NOMASTER` (22) world-anchored screen-aligned quad.
    func render3DTextureNoMaster(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let color = EffectPrimitiveBatchCollector.unpackARGB(state.argb)
        let texture = resolveTexture(at: currentMotion, assets: assets)
        let renderState = EffectPrimitiveRenderState(renderFlag: state.renderFlag)

        collector.appendScreen2DQuad(
            anchorEffectPosition: position,
            offset0: SIMD2<Float>(0, 0),
            offset1: SIMD2<Float>(state.widthSize, 0),
            offset2: SIMD2<Float>(state.widthSize, -state.heightSize),
            offset3: SIMD2<Float>(0, -state.heightSize),
            uv0: SIMD2<Float>(0, 0),
            uv1: SIMD2<Float>(1, 0),
            uv2: SIMD2<Float>(1, 1),
            uv3: SIMD2<Float>(0, 1),
            color0: color,
            color1: color,
            color2: color,
            color3: color,
            texture: texture,
            renderState: renderState,
            isAbsoluteScreen: false
        )
    }

    // MARK: - PP_SAKURA (40)
    // PrimSakura / RenderSegmentSprites2

    // MARK: - Primitive 46
    // ProcessAlpha, ShiftSegment / RenderSegmentSprites2

    // MARK: - Primitive 51
    // ProcessAlpha, ShiftSegment / RenderSegmentSprites2

    // MARK: - PP_POKJUK (52)

    /// Motion update for `PP_POKJUK` (52) firework spark burst at 60Hz.
    func primPokJuk(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            if process % 3 == 0 {
                state.slots[index].vecTPre = state.slots[index].vecTNow
                state.slots[index].vecTNow = state.slots[index].vecBPre
                state.slots[index].vecBPre = state.slots[index].vecBNow
            }

            let offset = Int(state.slots[index].flag1[2])
            if process >= 160 + offset && process <= 180 + offset {
                let per = process % 20
                if per == 15 || per == 19 {
                    state.slots[index].flag1[3] = 1
                } else if per == 17 {
                    state.slots[index].flag1[3] = 2
                } else {
                    state.slots[index].flag1[3] = 0
                }
            } else {
                state.slots[index].flag1[3] = 0
            }

            state.slots[index].rotStart += 5
            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            if state.slots[index].flag1[1] == 0 {
                state.slots[index].vecBNow.y -= 0.25
                if process > 154 {
                    state.slots[index].flag1[1] = 1
                    state.slots[index].alphaB = 250
                }
            } else if state.slots[index].flag1[1] == 1 {
                let sn1 = EffectSpace.sine(degrees: Int(state.slots[index].fullDisplayAngle))
                let cs1 = EffectSpace.cosine(degrees: Int(state.slots[index].fullDisplayAngle))
                state.slots[index].vecBNow.y += sn1 * state.slots[index].distance + 0.02

                let rx = cs1 * state.slots[index].distance
                state.slots[index].vecBNow.x += EffectSpace.cosine(degrees: Int(state.slots[index].riseAngle)) * rx
                state.slots[index].vecBNow.z += EffectSpace.sine(degrees: Int(state.slots[index].riseAngle)) * rx
                state.slots[index].distance *= 0.98

                state.slots[index].alphaB -= 1
                if Int.random(in: 0..<2) == 0 {
                    state.slots[index].alphaB -= 1
                }
                if state.slots[index].alphaB < 0 {
                    state.slots[index].alphaB = 0
                }
            }

            if process > 2000 {
                state.slots[index].life = 0
            }
        }
    }

    /// Geometry submission for `PP_POKJUK` (52) 2-step trailing firework squares.
    func renderTrailSquares(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for slot in state.slots where slot.life == 1 && slot.alphaB > 0 {
            let (red, green, blue): (UInt8, UInt8, UInt8) = switch slot.flag1[0] {
            case 0: (70, 70, 255)
            case 1: (255, 70, 70)
            case 2: (70, 255, 70)
            case 3: (255, 255, 90)
            default: (255, 70, 255)
            }

            var shrink: Float = 0
            for step in 0..<2 {
                let radius = slot.maxHeight - shrink
                let a1 = Int(slot.rotStart)
                let a2 = (a1 + 90) % 360
                let a3 = (a2 + 90) % 360
                let a4 = (a3 + 90) % 360

                var v1 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a1), 0, radius * EffectSpace.sine(degrees: a1))
                var v2 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a2), 0, radius * EffectSpace.sine(degrees: a2))
                var v3 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a3), 0, radius * EffectSpace.sine(degrees: a3))
                var v4 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a4), 0, radius * EffectSpace.sine(degrees: a4))
                Self.towardScreen(&v1, &v2, &v3, &v4, rot0: rot0, rot1: rot1)

                let offset = step == 0 ? slot.vecBNow : slot.vecBPre
                let alpha = slot.alphaB / Int16(step + 1)
                let p1 = v1 + offset
                let p2 = v2 + offset
                let p3 = v3 + offset
                let p4 = v4 + offset

                if slot.flag1[3] == 0 {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: alpha,
                        v1: p1,
                        v2: p2,
                        v3: p3,
                        v4: p4,
                        blendSelector: 0,
                        textureIndex: 0,
                        isWorldPosition: true,
                        red: red,
                        green: green,
                        blue: blue
                    )
                } else {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: alpha / 4,
                        v1: p1,
                        v2: p2,
                        v3: p3,
                        v4: p4,
                        blendSelector: 0,
                        textureIndex: Int(slot.flag1[3]),
                        isWorldPosition: true,
                        red: 255,
                        green: 255,
                        blue: 255
                    )
                }

                shrink += step != 0 ? 0.25 : 0.5
            }
        }
    }

    // MARK: - PP_THROWITEM (53)

    /// Motion update for `PP_THROWITEM` (53) parabolic thrown item with afterimage trail at 60Hz.
    func primThrowItem(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        let process = state.slots[0].process

        if process % 2 == 1 {
            if process > 3 {
                copyTrailingSlot(from: 2, to: 3, alphaDrop: 25)
            }
            if process > 2 {
                copyTrailingSlot(from: 1, to: 2, alphaDrop: 25)
            }
            if process > 1 {
                copyTrailingSlot(from: 0, to: 1, alphaDrop: 150)
            }
        }

        state.slots[0].fullDisplayAngle += state.slots[0].flag1[2] == 15 ? 45 : 10
        if state.slots[0].fullDisplayAngle >= 360 {
            state.slots[0].fullDisplayAngle -= 360
        }

        if process == 1 {
            let rx = state.deltaPos.x - state.slots[0].vecBNow.x
            let rz = state.deltaPos.z - state.slots[0].vecBNow.z
            state.slots[0].rotStart = Self.angle(dx: rx, dy: rz)
        }

        let denom = Float(max(1, Int(state.slots[0].flag1[1])))
        let progress = Float(process) / denom
        if progress > 1.05 {
            state.slots[0].alphaB = max(0, state.slots[0].alphaB - 20)
        } else {
            let clamped = min(progress, 1.0)
            let sinAngle = Int(180.0 * clamped)
            state.slots[0].vecBPre.y += state.slots[0].height[2]

            let arcHeight: Float = switch state.slots[0].flag1[2] {
            case 0: 10.0
            case 15: 1.0
            default: 30.0
            }
            state.slots[0].vecBNow.y = state.slots[0].vecBPre.y - EffectSpace.sine(degrees: sinAngle) * arcHeight
            state.slots[0].vecBNow.x += state.slots[0].height[1] * EffectSpace.cosine(degrees: Int(state.slots[0].rotStart))
            state.slots[0].vecBNow.z += state.slots[0].height[1] * EffectSpace.sine(degrees: Int(state.slots[0].rotStart))
        }
    }

    // MARK: - PP_BLIND (71)

    /// Motion update for `PP_BLIND` (71) fade-in camera overlay at 60Hz.
    func primFadeInFollow(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            if state.slots[index].alphaB < 255 {
                state.slots[index].alphaB += 1
            }
        }
    }

    /// Geometry submission for `PP_BLIND` (71) 8-quad dark tunnel vignette.
    func renderBlind(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT
        var red: UInt8 = 10
        var green: UInt8 = 10
        var blue: UInt8 = 10

        for slot in state.slots where slot.life == 1 && slot.alphaB > 0 {
            if slot.flag1[0] == 1 {
                red = 30
                green = 30
                blue = 30
            }

            let d = slot.distance
            let outer = d + 100.0
            let quads: [(SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, Int)] = [
                (SIMD3<Float>(0, 0, 0), SIMD3<Float>(0, 0, d), SIMD3<Float>(d, 0, d), SIMD3<Float>(d, 0, 0), 0),
                (SIMD3<Float>(0, 0, 0), SIMD3<Float>(0, 0, -d), SIMD3<Float>(d, 0, -d), SIMD3<Float>(d, 0, 0), 0),
                (SIMD3<Float>(0, 0, 0), SIMD3<Float>(0, 0, d), SIMD3<Float>(-d, 0, d), SIMD3<Float>(-d, 0, 0), 0),
                (SIMD3<Float>(0, 0, 0), SIMD3<Float>(0, 0, -d), SIMD3<Float>(-d, 0, -d), SIMD3<Float>(-d, 0, 0), 0),
                (SIMD3<Float>(d, 0, -d), SIMD3<Float>(outer, 0, -d), SIMD3<Float>(outer, 0, outer), SIMD3<Float>(d, 0, outer), 1),
                (SIMD3<Float>(d, 0, d), SIMD3<Float>(d, 0, outer), SIMD3<Float>(-outer, 0, outer), SIMD3<Float>(-outer, 0, d), 1),
                (SIMD3<Float>(-d, 0, d), SIMD3<Float>(-outer, 0, d), SIMD3<Float>(-outer, 0, -outer), SIMD3<Float>(-d, 0, -outer), 1),
                (SIMD3<Float>(-d, 0, -d), SIMD3<Float>(-d, 0, -outer), SIMD3<Float>(outer, 0, -outer), SIMD3<Float>(outer, 0, -d), 1),
            ]

            for (c0, c1, c2, c3, textureIndex) in quads {
                var v1 = c0
                var v2 = c1
                var v3 = c2
                var v4 = c3
                Self.towardScreen(&v1, &v2, &v3, &v4, rot0: rot0, rot1: rot1)
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: slot.alphaB,
                    v1: v1,
                    v2: v2,
                    v3: v3,
                    v4: v4,
                    blendSelector: 1,
                    textureIndex: textureIndex,
                    isWorldPosition: false,
                    red: red,
                    green: green,
                    blue: blue
                )
            }
        }
    }

    // MARK: - PP_COLORPAPER (78)

    /// Motion update for `PP_COLORPAPER` (78) falling tumbling confetti at 60Hz.
    func primColorPaper() {
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            state.slots[index].riseAngle += 2
            if state.slots[index].riseAngle >= 360 {
                state.slots[index].riseAngle -= 360
            }

            state.slots[index].vecBNow.y += state.slots[index].distance
            if state.slots[index].vecBNow.y > -10.0 {
                state.slots[index].alphaB -= 10
                if state.slots[index].alphaB < 0 {
                    state.slots[index].alphaB = 0
                    state.slots[index].fullDisplayAngle += 1
                    if state.slots[index].fullDisplayAngle < 3 {
                        state.slots[index].vecBNow.x = Float(Int.random(in: 0..<101) - 50)
                        state.slots[index].vecBNow.z = Float(Int.random(in: 0..<101) - 50)
                        state.slots[index].vecBNow.y = Float(-110 - Int.random(in: 0..<50))
                        state.slots[index].process = 0
                    }
                }
            } else if state.slots[index].vecBNow.y > 0 {
                state.slots[index].life = 0
            }

            if state.slots[index].process < 60 {
                state.slots[index].alphaB = min(250, state.slots[index].alphaB + 5)
            }
        }
    }

    /// Geometry submission for `PP_COLORPAPER` (78) tumbling colored paper quads.
    func renderColorPaper(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        for slot in state.slots where slot.life == 1 {
            let rx = slot.maxHeight
            let cs2 = EffectSpace.cosine(degrees: Int(slot.riseAngle))
            let sn2 = EffectSpace.sine(degrees: Int(slot.riseAngle))

            func corner(angleOffset: Int) -> SIMD3<Float> {
                let angle = (((Int(slot.rotStart) + angleOffset) % 360) + 360) % 360
                let x = rx * EffectSpace.cosine(degrees: angle)
                let ry = rx * EffectSpace.sine(degrees: angle)
                return SIMD3<Float>(x, ry * cs2, ry * sn2) + slot.vecBNow
            }

            let v1 = corner(angleOffset: 0)
            let v2 = corner(angleOffset: 90)
            let v3 = corner(angleOffset: 180)
            let v4 = corner(angleOffset: 270)

            let red = UInt8(clamping: Int(slot.height[0]))
            let green = UInt8(clamping: Int(slot.height[1]))
            let blue = UInt8(clamping: Int(slot.height[2]))

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: v1,
                v2: v2,
                v3: v3,
                v4: v4,
                blendSelector: 0,
                textureIndex: 0,
                isWorldPosition: false,
                red: red,
                green: green,
                blue: blue
            )
        }
    }

    // MARK: - PP_GHOST (84)
    // PrimGhost / RenderSegmentSprites2

    // MARK: - PP_SUPERANGEL (85)
    // PrimSuperAngel / RenderSegmentSprites2

    // MARK: - PP_KOUENKA (124)
    // PrimKouenka / RenderSegmentSprites2

    // MARK: - PP_BUBBLE_DROP (127)

    /// Motion update for `PP_BUBBLE_DROP` (127) falling bubble with 3-step trail at 60Hz.
    func primBubbleDrop(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        let process = state.slots[0].process
        guard process > 0 else {
            return
        }

        if process > 3 {
            copyTrailingSlot(from: 2, to: 3, alphaDrop: 25)
        }
        if process > 2 {
            copyTrailingSlot(from: 1, to: 2, alphaDrop: 25)
        }
        if process > 1 {
            copyTrailingSlot(from: 0, to: 1, alphaDrop: 100)
        }

        if process <= 10 {
            state.slots[0].alphaB += 20
        }

        if process < Int(state.slots[0].flag1[4]) {
            state.slots[0].fullDisplayAngle -= 15
            if state.slots[0].fullDisplayAngle < 0 {
                state.slots[0].fullDisplayAngle += 360
            }
            state.slots[0].vecBPre.y += state.slots[0].height[1]
            state.slots[0].vecBNow = position + state.slots[0].vecBPre
        } else {
            state.slots[0].alphaB = max(0, state.slots[0].alphaB - 10)
        }
    }

    // MARK: - Primitive 151

    /// Motion update for primitive `151` spiraling fade that spawns `EF_SOULLIGHT2` / `EF_SOULLIGHT3` child effects.
    func primSpiralFade(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            let mode = state.slots[index].flag1[0]
            if process <= 10 {
                state.slots[index].height[13] += 20.0
            } else if mode >= 1 {
                if process > 90 {
                    state.slots[index].height[13] = max(0, state.slots[index].height[13] - 5.0)
                }
            } else if process > 270 {
                state.slots[index].height[13] = max(0, state.slots[index].height[13] - 5.0)
            }

            state.slots[index].vecTNow.x += 0.05
            let radius = Float(Int(state.slots[index].vecTNow.x))
            var phase = process % 60
            if mode == 1 {
                phase = 60 - phase
            }
            let base = SIMD3<Float>(
                radius * EffectSpace.sine(degrees: 6 * phase),
                -25.0,
                radius * EffectSpace.cosine(degrees: 6 * phase)
            )
            state.slots[index].vecBPre = base

            // Trigger child effect spawning during tick (keeping collectBatches read-only).
            let rx = state.slots[index].distance
            var v1 = SIMD3<Float>(rx * EffectSpace.cosine(degrees: 45), 0, rx * EffectSpace.sine(degrees: 45))
            var v2 = SIMD3<Float>(rx * EffectSpace.cosine(degrees: 135), 0, rx * EffectSpace.sine(degrees: 135))
            var v3 = SIMD3<Float>(rx * EffectSpace.cosine(degrees: 225), 0, rx * EffectSpace.sine(degrees: 225))
            var v4 = SIMD3<Float>(rx * EffectSpace.cosine(degrees: 315), 0, rx * EffectSpace.sine(degrees: 315))
            Self.towardScreen(&v1, &v2, &v3, &v4, rot0: rot0, rot1: rot1)

            let topY = base.y + v1.y
            if topY <= 0 && process < 300 && Int(state.slots[index].height[13]) > 0 {
                let targetID = state.slots[index].targetObjectID ?? master?.targetObjectID ?? master?.ownerObjectID
                let childID: EffectID = mode == 0 ? .ef_soullight2 : .ef_soullight3
                let request = EffectSpawnRequest(
                    effectID: childID,
                    worldPosition: EffectSpace.toWorldPosition(position + base),
                    ownerObjectID: targetID,
                    targetObjectID: targetID
                )
                context.spawnChildEffect(request)
            }
        }
    }

    // MARK: - Primitive 152
    // PrimWanderingSlots / RenderSegmentSpriteTrail

    // MARK: - Primitive 153
    // PrimFadeAlpha / RenderSegmentSpriteGlow

    // MARK: - Primitive 167
    // Prim3DSlotParticle / RenderSegmentSprites

    // MARK: - Primitive 168
    // FollowMasterAndAdvance / RenderGroundSprite

    // MARK: - Shared Helpers

    private func advanceTextured3DPrimitive(
        origin: SIMD3<Float>,
        context: EffectTickContext,
        isNoMaster: Bool
    ) -> Bool {
        state.speed3d += state.deltaPosAccel
        state.widthSpeed += state.widthAccel
        state.heightSpeed += state.heightAccel
        state.longSpeed += state.longAccel
        state.latiSpeed += state.latiAccel
        state.speed += state.accel

        if (state.pattern & 0x400) != 0 {
            state.speed3d = EffectSpace.transformVector(SIMD3<Float>(0, 0, state.speed), by: state.transform)
            state.deltaPos += state.speed3d
        } else if (state.pattern & 0x100) != 0 {
            state.deltaPos += state.speed3d
        } else {
            state.speed3d = EffectSpace.transformVector(SIMD3<Float>(0, 0, state.speed), by: state.transform)
            state.deltaPos += state.speed3d
        }

        if (state.pattern & 0x400) != 0, let master {
            let dx = master.deltaPos.x - position.x
            let dz = master.deltaPos.z - position.z
            if hypotf(dx, dz) <= 3.0 {
                state.masterReached = true
                return false
            }
            state.longitude = angle
        }

        position = origin + state.deltaPos
        state.widthSize += state.widthSpeed
        state.heightSize += state.heightSpeed
        state.longitude += state.longSpeed
        state.latitude += state.latiSpeed

        if state.heightSize > state.maxHeightSize {
            state.heightAccel = 0
            state.heightSpeed = 0
        }

        let yaw: Float
        if (state.pattern & 0x200) != 0 {
            state.rotTransform = EffectSpace.rotationZ(radians: context.world.cameraPitchDegrees)
            yaw = angle
        } else {
            if (state.pattern & 0x40) != 0 {
                state.longitude = context.world.cameraYawDegrees + 90.0
                state.roll = context.world.cameraPitchDegrees
                let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(state.latitude)))
                let rotZ = EffectSpace.rotationZ(radians: EffectSpace.radian(degrees: Int(state.roll)))
                state.rotTransform = rotZ * rotX
            } else {
                let rotZ = EffectSpace.rotationZ(radians: EffectSpace.radian(degrees: Int(state.roll)))
                let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(state.latitude)))
                state.rotTransform = rotX * rotZ
            }
            yaw = state.longitude
        }
        state.rotTransform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(yaw))) * state.rotTransform

        if (state.pattern & 2) != 0 {
            state.v1 = Float(state.chCnt) / 10.0
            state.v2 = state.v1 + 1.0
            state.chCnt += 1
            if state.chCnt == 10 {
                state.chCnt = 0
            }
        }

        if (state.pattern & 0x10) != 0, let master {
            master.deltaPos = state.deltaPos2 + state.deltaPos
        }

        if (state.pattern & 4) != 0 {
            let terrainY = context.world.terrainHeight(atEffectX: position.x, effectZ: position.z)
            if position.y > terrainY {
                state.pattern &= ~4
                state.stateCnt = state.duration - 25
                state.speed = 0
                if !isNoMaster {
                    master?.flag = 1
                }
            }
        }

        if (state.pattern & 0x20) != 0 && state.type > 0 && state.stateCnt % Int(state.type) == 0 {
            state.heightSpeed = -state.heightSpeed
        }

        if (state.pattern & 0x800) != 0 && (state.red == 254 || state.blue == 254 || state.green == 254) {
            if state.rgbCycleDelay != 0 {
                state.rgbCycleCnt += 1
            }
            if state.rgbCycleDelay == state.rgbCycleCnt {
                state.red += state.redSpeed
                state.green += state.greenSpeed
                state.blue += state.blueSpeed
                state.rgbCycleCnt = 0
            }
        } else {
            state.red += state.redSpeed
            state.green += state.greenSpeed
            state.blue += state.blueSpeed
        }

        if (state.pattern & 0x800) != 0 {
            state.red = wrapRGB(state.red, max: 254)
            state.green = wrapRGB(state.green, max: 254)
            state.blue = wrapRGB(state.blue, max: 254)
        } else {
            state.red = wrapRGB(state.red, max: 255)
            state.green = min(255, max(0, state.green))
            state.blue = min(255, max(0, state.blue))
        }

        processAlpha()

        let animSpeed = max(1, state.animSpeed)
        if state.stateCnt % animSpeed == 0 {
            let next = currentMotion + 1
            let total = max(1, state.texturePaths.isEmpty ? state.totalTexture : state.texturePaths.count)
            currentMotion = next
            if !state.repeatAnim {
                if next == total {
                    return false
                }
            } else {
                currentMotion = next % total
            }
        }

        return true
    }

    private func wrapRGB(_ value: Int, max maxValue: Int) -> Int {
        if value > maxValue {
            return 0
        }
        if value < 0 {
            return maxValue
        }
        return value
    }

    private func copyTrailingSlot(from source: Int, to destination: Int, alphaDrop: Int16) {
        state.slots[destination].fullDisplayAngle = state.slots[source].fullDisplayAngle
        state.slots[destination].distance = state.slots[source].distance
        state.slots[destination].height[8] = state.slots[source].height[8]
        state.slots[destination].alphaB = max(0, state.slots[source].alphaB - alphaDrop)
        state.slots[destination].vecBNow = state.slots[source].vecBNow
        state.slots[destination].flag1[0] = state.slots[source].flag1[0]
    }
}
