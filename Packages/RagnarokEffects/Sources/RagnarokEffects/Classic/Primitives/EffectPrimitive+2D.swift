//
//  EffectPrimitive+2D.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/25.
//

import Foundation
import RagnarokRendering
import simd

extension EffectPrimitive {

    // MARK: - PP_2DTEXTURE (0) / PP_2DQUAD (2)

    /// Motion update for `PP_2DTEXTURE` (0) and `PP_2DQUAD` (2) at 60Hz.
    @discardableResult
    func move2DPrimitive() -> Bool {
        if state.cooldownSkillID != nil || state.slots[0].life == 98 {
            state.slots[0].process = 999
        }

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
        }

        state.speed += state.accel
        state.rollSpeed += state.rollAccel
        state.widthSpeed += state.widthAccel
        state.heightSpeed += state.heightAccel

        if (state.pattern & 2) != 0 && state.stateCnt >= Int(state.chCnt) {
            state.widthAccel = 0
            state.widthSpeed = 0
            state.heightAccel = 0
            state.heightSpeed = 0
        }

        if (state.pattern & 0x80) != 0 {
            if state.alphaSpeed < 0 {
                if state.alpha <= state.minAlpha {
                    state.alphaSpeed = -state.alphaSpeed
                }
            } else if state.alpha >= state.maxAlpha {
                state.alphaSpeed = -state.alphaSpeed
            }
        }

        let direction = Int(state.longitude)
        state.roll += state.rollSpeed
        state.widthSize += state.widthSpeed
        state.heightSize += state.heightSpeed

        state.deltaPos.x += EffectSpace.sine(degrees: direction) * state.speed
        state.deltaPos.y -= EffectSpace.cosine(degrees: direction) * state.speed
        position.x = state.deltaPos2.x + state.deltaPos.x
        position.y = state.deltaPos2.y + state.deltaPos.y

        state.red += state.redSpeed
        state.green += state.greenSpeed
        state.blue += state.blueSpeed

        if state.red > 255 {
            state.red = 0
        } else if state.red < 0 {
            state.red = 255
        }
        if state.green > 255 {
            state.green = 255
        } else if state.green < 0 {
            state.green = 0
        }
        if state.blue > 255 {
            state.blue = 255
        } else if state.blue < 0 {
            state.blue = 0
        }

        if (state.pattern & 8) != 0 && state.chCnt > 0 && state.stateCnt % Int(state.chCnt) == 0 {
            state.longitude = Float(Int.random(in: 0..<16)) + (state.longitude - 8.0)
            state.chCnt = UInt32(Int.random(in: 0..<10) + 10)
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

    /// Geometry submission for `PP_2DTEXTURE` (0) and `PP_2DTEXTUREORBIT` (1).
    func render2DPrimitive(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let sinRoll = EffectSpace.sine(degrees: Int(state.roll))
        let cosRoll = EffectSpace.cosine(degrees: Int(state.roll))
        let width = state.widthSize
        let negWidth = -width
        let height = state.heightSize
        let negHeight = (state.pattern & 1) != 0 ? -height * 2.0 : -height
        let extra: Float = (state.pattern & 1) != 0 ? 0 : height

        let x0 = negWidth * cosRoll
        let y0 = negWidth * sinRoll
        let p1X = x0 - negHeight * sinRoll
        let p1Y = y0 + negHeight * cosRoll
        let p3X = width * cosRoll - extra * sinRoll
        let p3Y = width * sinRoll + extra * cosRoll

        let (anchor, centerOffset, isAbsolute) = resolved2DAnchorAndOffset()
        let v0 = SIMD2<Float>(x0 - extra * sinRoll - 0.5, y0 + extra * cosRoll - 0.5) + centerOffset
        let v1 = SIMD2<Float>(p1X - 0.5, p1Y - 0.5) + centerOffset
        let v2 = SIMD2<Float>(width * cosRoll - negHeight * sinRoll - 0.5, width * sinRoll + negHeight * cosRoll - 0.5) + centerOffset
        let v3 = SIMD2<Float>(p3X - 0.5, p3Y - 0.5) + centerOffset

        let color = EffectPrimitiveBatchCollector.unpackARGB(state.argb)
        let motionIndex = (state.cooldownSkillID != nil || state.slots[0].life == 98) ? 0 : currentMotion
        let texture = resolveTexture(at: motionIndex, assets: assets)
        let flag = state.useRenderFlag[0] != 0 ? state.renderFlag : EffectPrimitiveState.RenderFlag.alpha
        let renderState = make2DRenderState(renderFlag: flag)

        collector.appendScreen2DQuad(
            anchorEffectPosition: anchor,
            offset0: v0,
            offset1: v1,
            offset2: v2,
            offset3: v3,
            uv0: SIMD2<Float>(0, 1),
            uv1: SIMD2<Float>(0, 0),
            uv2: SIMD2<Float>(1, 0),
            uv3: SIMD2<Float>(1, 1),
            color0: color,
            color1: color,
            color2: color,
            color3: color,
            texture: texture,
            renderState: renderState,
            isAbsoluteScreen: isAbsolute
        )
    }

    // MARK: - PP_2DTEXTUREORBIT (1)

    /// Motion update for `PP_2DTEXTUREORBIT` (1) orbiting 2D sprite at 60Hz.
    @discardableResult
    func prim2DTextureOrbit() -> Bool {
        state.orgPos.x = state.deltaPos2.x
        state.orgPos.y = state.deltaPos2.y
        state.radiusSpeed += state.radiusAccel
        state.longSpeed += state.longAccel
        state.widthSpeed += state.widthAccel
        state.heightSpeed += state.heightAccel
        state.rollSpeed += state.rollAccel
        state.radius += state.radiusSpeed
        state.longitude += state.longSpeed
        state.roll += state.rollSpeed
        state.widthSize += state.widthSpeed
        state.heightSize += state.heightSpeed

        position.x = EffectSpace.sine(degrees: Int(state.longitude)) * state.radius + state.orgPos.x
        position.y = state.orgPos.y - EffectSpace.cosine(degrees: Int(state.longitude)) * state.radius
        processAlpha()

        let animSpeed = max(1, state.animSpeed)
        if state.stateCnt % animSpeed == 0 {
            let next = currentMotion + 1
            let total = max(1, state.texturePaths.isEmpty ? state.totalTexture : state.texturePaths.count)
            currentMotion = next
            if state.repeatAnim {
                currentMotion = next % total
            } else if next == total {
                return false
            }
        }

        return true
    }

    // MARK: - PP_2DQUAD (2)

    /// Geometry submission for `PP_2DQUAD` (2) notched 2D diamond.
    func render2DDiamond(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let sn = EffectSpace.sine(degrees: Int(state.roll))
        let cs = EffectSpace.cosine(degrees: Int(state.roll))
        let halfHeight = state.heightSize * 0.5
        let halfWidth = state.widthSize * 0.5
        let notch = halfHeight / 1.2

        let (anchor, centerOffset, isAbsolute) = resolved2DAnchorAndOffset()
        func rotateOffset(_ x: Float, _ y: Float) -> SIMD2<Float> {
            SIMD2<Float>(x * cs - y * sn, y * cs + x * sn) + centerOffset
        }

        let color = EffectPrimitiveBatchCollector.unpackARGB(state.argb)
        let white = SIMD4<Float>(1, 1, 1, 1)
        let texture = resolveTexture(at: currentMotion, assets: assets)
        let renderState = make2DRenderState(renderFlag: EffectPrimitiveState.RenderFlag.alpha)

        let leftMid = rotateOffset(-halfWidth, notch - halfHeight)
        let rightMid = rotateOffset(halfWidth, halfHeight - notch)
        let bottom = rotateOffset(0, halfHeight)
        let top = rotateOffset(0, -halfHeight)

        collector.appendScreen2DTriangle(
            anchorEffectPosition: anchor,
            offset0: leftMid,
            offset1: bottom,
            offset2: top,
            uv0: SIMD2<Float>(0, 0.5),
            uv1: SIMD2<Float>(0.5, 1.0),
            uv2: SIMD2<Float>(0.5, 0.0),
            color0: color,
            color1: white,
            color2: color,
            texture: texture,
            renderState: renderState,
            isAbsoluteScreen: isAbsolute
        )

        collector.appendScreen2DTriangle(
            anchorEffectPosition: anchor,
            offset0: rightMid,
            offset1: bottom,
            offset2: top,
            uv0: SIMD2<Float>(1, 0.5),
            uv1: SIMD2<Float>(0.5, 1.0),
            uv2: SIMD2<Float>(0.5, 0.0),
            color0: color,
            color1: white,
            color2: color,
            texture: texture,
            renderState: renderState,
            isAbsoluteScreen: isAbsolute
        )
    }

    // MARK: - PP_2DFLASH (3)

    /// Motion update for `PP_2DFLASH` (3) radial 2D flash wedge at 60Hz.
    func prim2DFlash() {
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
        state.longitude += state.longSpeed
        state.heightSize += state.heightSpeed
        state.arcAngle += state.widthSpeed
        processAlpha()
    }

    /// Geometry submission for `PP_2DFLASH` (3) single radial flash triangle.
    func render2DFlash(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let firstCos = EffectSpace.cosine(degrees: Int(state.longitude - state.arcAngle))
        let firstSin = EffectSpace.sine(degrees: Int(state.longitude - state.arcAngle))
        let secondCos = EffectSpace.cosine(degrees: Int(state.longitude + state.arcAngle))
        let secondSin = EffectSpace.sine(degrees: Int(state.longitude + state.arcAngle))

        let (anchor, centerOffset, isAbsolute) = resolved2DAnchorAndOffset()
        let radius = state.heightSize
        let v0 = centerOffset
        let v1 = SIMD2<Float>(radius * firstCos, -radius * firstSin) + centerOffset
        let v2 = SIMD2<Float>(radius * secondCos, -radius * secondSin) + centerOffset

        let color = EffectPrimitiveBatchCollector.unpackARGB(state.argb)
        let texture = resolveTexture(at: 0, assets: assets)
        let renderState = make2DRenderState(renderFlag: EffectPrimitiveState.RenderFlag.alpha)

        collector.appendScreen2DTriangle(
            anchorEffectPosition: anchor,
            offset0: v0,
            offset1: v1,
            offset2: v2,
            uv0: SIMD2<Float>(0.5, 0.0),
            uv1: SIMD2<Float>(1.0, 1.0),
            uv2: SIMD2<Float>(0.0, 1.0),
            color0: color,
            color1: color,
            color2: color,
            texture: texture,
            renderState: renderState,
            isAbsoluteScreen: isAbsolute
        )
    }

    // MARK: - PP_2DCIRCLE (4)

    /// Motion update for `PP_2DCIRCLE` (4) expanding 2D screen ring at 60Hz.
    func prim2DCircle() {
        position.x = state.deltaPos2.x
        position.y = state.deltaPos2.y
        state.radiusSpeed += state.radiusAccel
        state.radius += state.radiusSpeed

        if (state.pattern & 1) != 0 || state.radius < state.innerSize {
            state.size = state.radius
        } else {
            state.size = state.innerSize
        }

        processAlpha()
    }

    /// Geometry submission for `PP_2DCIRCLE` (4) segmented 2D ring.
    func render2DCircle(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        guard state.arcAngle > 0 else {
            return
        }

        let (anchor, centerOffset, isAbsolute) = resolved2DAnchorAndOffset()
        let innerSize = state.radius - state.size
        let maxAngle = 360.0 - state.arcAngle
        let color = EffectPrimitiveBatchCollector.unpackARGB(state.argb)
        let texture = resolveTexture(at: 0, assets: assets)
        let renderState = make2DRenderState(renderFlag: EffectPrimitiveState.RenderFlag.alpha)

        var uInc: Float = 0
        var angle: Float = 0
        while angle <= maxAngle {
            let cs1 = EffectSpace.cosine(degrees: Int(angle))
            let sn1 = EffectSpace.sine(degrees: Int(angle))
            let cs2 = EffectSpace.cosine(degrees: Int(angle + state.arcAngle))
            let sn2 = EffectSpace.sine(degrees: Int(angle + state.arcAngle))

            let pInner1 = SIMD2<Float>(innerSize * cs1, -innerSize * sn1) + centerOffset
            let pInner2 = SIMD2<Float>(innerSize * cs2, -innerSize * sn2) + centerOffset
            let pOuter2 = SIMD2<Float>(state.radius * cs2, -state.radius * sn2) + centerOffset
            let pOuter1 = SIMD2<Float>(state.radius * cs1, -state.radius * sn1) + centerOffset

            collector.appendScreen2DQuad(
                anchorEffectPosition: anchor,
                offset0: pInner1,
                offset1: pInner2,
                offset2: pOuter2,
                offset3: pOuter1,
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
                isAbsoluteScreen: isAbsolute
            )

            uInc += 0.25
            if uInc >= 1.0 {
                uInc = 0
            }
            angle += state.arcAngle
        }
    }

    // MARK: - Helpers

    private func resolved2DAnchorAndOffset() -> (anchor: SIMD3<Float>, offset: SIMD2<Float>, isAbsolute: Bool) {
        let isAbsolute = (state.pattern & 4) != 0
        if isAbsolute {
            return (SIMD3<Float>(position.x, position.y, 0), .zero, true)
        }
        let anchor = master?.position ?? .zero
        return (anchor, SIMD2<Float>(position.x, position.y), false)
    }

    private func make2DRenderState(renderFlag: UInt32) -> EffectPrimitiveRenderState {
        var renderState = EffectPrimitiveRenderState(renderFlag: renderFlag)
        renderState.depthTest = false
        renderState.depthWrite = false
        renderState.bucket = .overlay
        return renderState
    }
}
