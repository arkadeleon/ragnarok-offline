//
//  EffectPrimitive+Sweeps.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/25.
//

import Foundation
import simd

extension EffectPrimitive {

    // MARK: - Primitive 89

    /// Motion update for primitive `89` expanding fan beams at 60Hz.
    func primFanBeam() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            let kind = state.slots[index].height[4]
            if kind == 2.0 || kind == 6.0 {
                if process <= 10 {
                    state.slots[index].alphaB += 10
                } else if process > 11 {
                    state.slots[index].alphaB = max(0, state.slots[index].alphaB - 3)
                }
                state.slots[index].distance += 3.0
            } else if kind == 3.0 {
                if process <= 10 {
                    state.slots[index].alphaB += 6
                } else if process > 11 {
                    state.slots[index].alphaB = max(0, state.slots[index].alphaB - 1)
                }
                state.slots[index].distance += 3.0
            } else {
                if process <= 10 {
                    state.slots[index].alphaB += 20
                } else if process > 12 {
                    state.slots[index].alphaB = max(0, state.slots[index].alphaB - 15)
                }
                state.slots[index].distance *= 1.15
            }
        }
    }

    /// Geometry submission for primitive `89`, emitting inner core and outer halo tilted fan wedges.
    func renderFanBeam(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let mode = slot.height[4]
            let length = slot.distance
            let lift = slot.height[0]
            let center = SIMD3<Float>(0, lift, 0)

            let innerSpread = mode == 2.0 ? 1 : 2
            let (innerLeft, innerRight) = Self.tiltedFanEndpoints(
                angle: Int(slot.riseAngle),
                halfSpread: innerSpread,
                distance: length,
                rotStart: Int(slot.rotStart),
                baseY: lift
            )

            let innerStyle: (r: UInt8, g: UInt8, b: UInt8, extra: Int8) = switch mode {
            case 2.0: (0, 0, 250, 0)
            case 3.0: (250, 250, 250, 0)
            case 4.0: (0, 0, 250, 0)
            case 5.0: (50, 50, 50, 0)
            case 6.0: (0, 0, 255, 1)
            default: (0, 250, 250, 0)
            }

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: innerLeft,
                v2: innerRight,
                v3: center,
                v4: center,
                blendSelector: 0,
                textureIndex: 0,
                isWorldPosition: false,
                red: innerStyle.r,
                green: innerStyle.g,
                blue: innerStyle.b,
                extra: innerStyle.extra
            )

            let outerSpread = mode == 2.0 ? 2 : 5
            let (outerLeft, outerRight) = Self.tiltedFanEndpoints(
                angle: Int(slot.riseAngle),
                halfSpread: outerSpread,
                distance: length,
                rotStart: Int(slot.rotStart),
                baseY: lift
            )

            let outerStyle: (pw: Int16, r: UInt8, g: UInt8, b: UInt8, extra: Int8) = switch mode {
            case 2.0: (0, 250, 250, 0, 0)
            case 3.0: (1, 250, 250, 250, 0)
            case 4.0: (1, 250, 250, 0, 0)
            case 5.0: (1, 250, 250, 250, 0)
            case 6.0: (0, 50, 50, 255, 1)
            default: (0, 250, 0, 0, 0)
            }

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: outerLeft,
                v2: outerRight,
                v3: center,
                v4: center,
                blendSelector: outerStyle.pw,
                textureIndex: 0,
                isWorldPosition: false,
                red: outerStyle.r,
                green: outerStyle.g,
                blue: outerStyle.b,
                extra: outerStyle.extra
            )
        }
    }

    // MARK: - Primitive 133

    /// Motion update for primitive `133` animated flash blades at 60Hz.
    func primAnimatedFlash(context: EffectTickContext) {
        faceCamera(world: context.world)

        guard state.slots[0].life == 1 else {
            return
        }

        let process = state.slots[0].process + 1
        state.slots[0].process = process

        if process % 4 == 0 {
            let nextFrame = Int(state.slots[0].flag1[0]) + 1
            let frames = max(1, state.totalTexture)
            state.slots[0].flag1[0] = nextFrame >= frames ? 0 : Int8(clamping: nextFrame)
        }

        if process < 30 {
            state.slots[0].alphaB += 10
        } else if process > 80 {
            state.slots[0].alphaB -= 3
        }

        state.slots[0].alphaB = max(0, min(255, state.slots[0].alphaB))
    }

    /// Geometry submission for primitive `133`, rendering 14 stepped billboarded blades along `riseAngle`.
    func renderSpiralBlades(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT
        let style = state.slots[0].flag1[2]
        let textureCount = max(1, state.totalTexture)

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let deltaX = slot.vecBNow.x - position.x
            let deltaZ = slot.vecBNow.z - position.z
            let totalLength = sqrtf(deltaX * deltaX + deltaZ * deltaZ)
            let riseAngle = Int(slot.riseAngle)
            let riseCos = EffectSpace.cosine(degrees: riseAngle)
            let riseSin = EffectSpace.sine(degrees: riseAngle)
            let wobble = slot.distance * EffectSpace.sine(degrees: Int(slot.height[8])) * 0.05

            for stepIndex in 4..<18 {
                let step = Float(stepIndex)
                let rx = slot.distance * step / 14.0 * Float(stepIndex + 46) / 50.0 + wobble
                var (v1, v2, v3, v4) = Self.polygonCorners(
                    radius: rx,
                    startAngle: Int(slot.fullDisplayAngle),
                    shape: slot.height[10]
                )
                Self.towardScreen(&v1, &v2, &v3, &v4, rot0: rot0, rot1: rot1)

                let along = totalLength / 12.0 * step
                let origin = SIMD3<Float>(
                    along * riseCos + position.x,
                    position.y - 12.0,
                    along * riseSin + position.z
                )

                switch style {
                case 0, 3:
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: slot.alphaB,
                        v1: origin + v1,
                        v2: origin + v2,
                        v3: origin + v3,
                        v4: origin + v4,
                        blendSelector: 1,
                        textureIndex: Int(UInt8(bitPattern: slot.flag1[0])),
                        isWorldPosition: true,
                        red: 255,
                        green: 255,
                        blue: 255
                    )
                case 4:
                    let frame = (stepIndex + Int(slot.flag1[0])) % textureCount
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: slot.alphaB,
                        v1: origin + v2,
                        v2: origin + v1,
                        v3: origin + v4,
                        v4: origin + v3,
                        blendSelector: 0,
                        textureIndex: max(0, frame),
                        isWorldPosition: true,
                        red: 255,
                        green: 150,
                        blue: 150
                    )
                default:
                    break
                }
            }
        }
    }

    // MARK: - Primitive 134

    /// Motion update for primitive `134` drifting blade trails at 60Hz.
    func primBladeTrail(context: EffectTickContext) {
        faceCamera(world: context.world)

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            state.slots[index].fullDisplayAngle += 1
            if state.slots[index].fullDisplayAngle > 359 {
                state.slots[index].fullDisplayAngle -= 360
            }

            if process < 10 {
                state.slots[index].alphaB += 25
            } else if process > 40 {
                state.slots[index].alphaB -= 5
            }

            state.slots[index].alphaB = max(0, min(255, state.slots[index].alphaB))
        }
    }

    /// Geometry submission for primitive `134`, rendering a 5-step fading billboarded blade trail.
    func renderBladeTrail(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT
        let style = state.slots[0].flag1[2]
        let divisor = Float(max(1, Int(state.slots[0].flag1[5])))

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let rx = slot.distance * EffectSpace.sine(degrees: Int(slot.height[8])) * 0.05 + slot.distance
            var (v1, v2, v3, v4) = Self.polygonCorners(
                radius: rx,
                startAngle: Int(slot.fullDisplayAngle),
                shape: slot.height[10]
            )
            Self.towardScreen(&v1, &v2, &v3, &v4, rot0: rot0, rot1: rot1)

            let deltaX = slot.vecBNow.x - position.x
            let deltaZ = slot.vecBNow.z - position.z
            let length = sqrtf(deltaX * deltaX + deltaZ * deltaZ)
            let riseAngle = Int(slot.riseAngle)
            let riseCos = EffectSpace.cosine(degrees: riseAngle)
            let riseSin = EffectSpace.sine(degrees: riseAngle)
            let textureIndex = Int(UInt8(bitPattern: slot.flag1[0]))

            let shade: UInt8? = switch style {
            case 0: 55
            case 1: 105
            case 2: 75
            case 3: 85
            default: nil
            }
            guard let shade else {
                continue
            }

            for trail in 0..<5 {
                let i = Float(trail * 2)
                let along = max(length / divisor * Float(slot.process) - i, 0)
                let origin = SIMD3<Float>(
                    along * riseCos + position.x,
                    position.y - 12.0,
                    along * riseSin + position.z
                )

                var alpha = slot.alphaB
                if trail > 0 {
                    alpha = max(0, Int16(clamping: Int(alpha) + 20 * (-5 - trail)))
                }

                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: alpha,
                    v1: origin + v2,
                    v2: origin + v1,
                    v3: origin + v4,
                    v4: origin + v3,
                    blendSelector: 0,
                    textureIndex: textureIndex,
                    isWorldPosition: true,
                    red: shade,
                    green: shade,
                    blue: 255
                )
            }
        }
    }

    // MARK: - Primitive 135

    /// Motion update for primitive `135` sweeping electric jitter arcs at 60Hz.
    func primTrailShift() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            state.slots[index].vecBNow = SIMD3<Float>(position.x, position.y - 10.0, position.z)

            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            let delay = index * 10
            if state.slots[index].alphaT == 1 {
                if process > delay {
                    state.slots[index].riseAngle += 2
                }
                if state.slots[index].riseAngle >= 360 {
                    state.slots[index].riseAngle -= 360
                }
            } else {
                if process > delay {
                    state.slots[index].riseAngle -= 2
                }
                if state.slots[index].riseAngle < 0 {
                    state.slots[index].riseAngle += 360
                }
            }

            if process > 60 {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 6)
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
                        continue
                    }

                    if tailCount >= 1 {
                        for point in stride(from: tailCount, through: 1, by: -1) {
                            state.slots[index].height[point] = state.slots[index].height[point - 1]
                            state.slots[index].flag1[point] = state.slots[index].flag1[point - 1]
                        }
                    }
                }
            }
        }
    }

    /// Geometry submission for primitive `135`, rendering multi-layer jittered electric sweep ribbons.
    func renderJitterSweeps(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        var bottoms = Array(repeating: SIMD3<Float>.zero, count: 20)
        var tops = Array(repeating: SIMD3<Float>.zero, count: 20)

        for layer in 0..<4 {
            let slot = state.slots[layer]
            let count = min(19, max(0, Int(slot.vecTNow.y)))
            var jitterX = Array(repeating: Float(0), count: 21)
            var jitterY = Array(repeating: Float(0), count: 21)
            var jitterZ = Array(repeating: Float(0), count: 21)

            for i in 0..<min(21, max(0, Int(slot.vecTNow.y))) {
                jitterY[i] = Float(Int.random(in: 0..<7)) * 0.1 - 0.3
                jitterX[i] = Float(Int.random(in: 0..<7)) * 0.1 - 0.3
                jitterZ[i] = Float(Int.random(in: 0..<7)) * 0.1 - 0.3
            }

            guard slot.life == 1, slot.alphaB > 0, slot.process > 0, count > 1 else {
                continue
            }

            let riseAngle = Int(slot.riseAngle)
            let riseCos = EffectSpace.cosine(degrees: riseAngle)
            let riseSin = EffectSpace.sine(degrees: riseAngle)
            let depth = -slot.distance

            for i in 0..<count {
                let h1 = slot.height[i]
                let r1 = h1 > 0 ? (h1 / 90.0) * slot.distance : 0
                let startLocal = SIMD3<Float>(
                    riseCos * r1 + jitterX[i],
                    depth * EffectSpace.sine(degrees: Int(h1)) * slot.vecTNow.x + (jitterY[i] - 2.0),
                    riseSin * r1 + jitterZ[i]
                )

                let h2 = slot.height[i + 1]
                let r2 = h2 > 0 ? (h2 / 90.0) * slot.distance : 0
                let endLocal = SIMD3<Float>(
                    riseCos * r2 + jitterX[i + 1],
                    depth * EffectSpace.sine(degrees: Int(h2)) * slot.vecTNow.x + (jitterY[i + 1] - 2.0),
                    riseSin * r2 + jitterZ[i + 1]
                )

                var facing = Int(Self.angle(dx: startLocal.x - endLocal.x, dy: startLocal.z - endLocal.z)) + 90
                if facing >= 360 {
                    facing -= 360
                }

                let start = startLocal + slot.vecBNow
                let end = endLocal + slot.vecBNow

                guard i > 0, i < 19 else {
                    continue
                }

                let facingCos = EffectSpace.cosine(degrees: facing)
                let facingSin = EffectSpace.sine(degrees: facing)
                var lastBottom = SIMD3<Float>.zero
                var lastTop = SIMD3<Float>.zero
                var currentBottom = SIMD3<Float>.zero
                var currentTop = SIMD3<Float>.zero

                for ring in 0...3 {
                    let turn = ring * 120
                    let rise = slot.maxHeight * EffectSpace.sine(degrees: turn)
                    let radial = slot.maxHeight * EffectSpace.cosine(degrees: turn)
                    let offset = SIMD3<Float>(radial * facingCos, rise, radial * facingSin)
                    currentBottom = start + offset
                    currentTop = end + offset

                    if ring > 0 {
                        let alpha = Int(slot.alphaB) - i * 5
                        if alpha > 0 && layer == 0 {
                            let green: UInt8
                            let blue: UInt8
                            if state.slots[0].fullDisplayAngle == 3 {
                                green = UInt8(Int.random(in: 0..<51))
                                blue = UInt8(Int.random(in: 0..<26) + 100)
                            } else {
                                green = UInt8(clamping: i * 3)
                                blue = UInt8(clamping: i * 3)
                            }
                            renderTeiRect(
                                into: &collector,
                                assets: assets,
                                alpha: Int16(clamping: alpha),
                                v1: currentBottom,
                                v2: currentTop,
                                v3: lastTop,
                                v4: lastBottom,
                                blendSelector: 0,
                                textureIndex: 0,
                                isWorldPosition: true,
                                red: 255,
                                green: green,
                                blue: blue
                            )
                        }
                    }

                    lastBottom = currentBottom
                    lastTop = currentTop
                }

                if layer != 0 {
                    var alpha = Int(slot.alphaB)
                    if layer == 1 {
                        alpha /= 3
                    } else if layer == 2 {
                        alpha /= 2
                    }
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: Int16(clamping: alpha),
                        v1: currentBottom,
                        v2: currentTop,
                        v3: tops[i],
                        v4: bottoms[i],
                        blendSelector: 0,
                        textureIndex: 0,
                        isWorldPosition: true,
                        red: 255,
                        green: 0,
                        blue: 0
                    )
                } else {
                    bottoms[i] = currentBottom
                    tops[i] = currentTop
                }
            }
        }
    }

    // MARK: - Primitive 136

    /// Motion update for primitive `136` spinning rising square columns at 60Hz.
    func primRandomSpin(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            let process = state.slots[index].process + 1
            state.slots[index].process = process
            guard process > 0 else {
                continue
            }

            state.slots[index].fullDisplayAngle -= 10
            if state.slots[index].fullDisplayAngle < 0 {
                state.slots[index].fullDisplayAngle += 360
            }

            if process == 1 {
                state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            } else if process <= 10 {
                state.slots[index].alphaB += 10
            } else if process > 100 {
                state.slots[index].alphaB -= 1
                if state.slots[index].alphaB < 0 {
                    state.slots[index].alphaB = 0
                    state.slots[index].life = 0
                }
            }
        }
    }

    /// Geometry submission for primitive `136`, rendering a 36-tier dual-pass spiral column of billboard squares.
    func renderSpinSquares(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 where state.slots[index].life == 1 && state.slots[index].alphaB > 0 {
            emitSpinSquareStack(
                into: &collector,
                assets: assets,
                slotIndex: index,
                scale: 1.0,
                blendSelector: 1,
                red: 55,
                green: 55,
                blue: 255
            )
            emitSpinSquareStack(
                into: &collector,
                assets: assets,
                slotIndex: index,
                scale: 2.0,
                blendSelector: 0,
                red: 25,
                green: 25,
                blue: 255
            )
        }
    }

    // MARK: - Primitive 141

    /// Motion update for primitive `141` rising tapered quads at 60Hz.
    func primRiseFollow(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            guard state.slots[index].process > 0 else {
                continue
            }

            state.slots[index].rotStart += 5
            if state.slots[index].rotStart > 100 {
                state.slots[index].alphaB -= 2
                state.slots[index].rotStart = 100
            }

            state.slots[index].alphaB = max(0, min(255, state.slots[index].alphaB))
            state.slots[index].vecBNow = SIMD3<Float>(position.x, state.slots[index].vecBPre.y, position.z)
        }
    }

    /// Geometry submission for primitive `141`, rendering tapered billboarded streaks.
    func renderTaperedQuad(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let dist = slot.distance
            let angle = ((Int(slot.fullDisplayAngle) % 360) + 360) % 360
            let inner = dist - Float(slot.rotStart) * dist / 50.0
            let angle1 = (angle + 270) % 360
            let angle2 = (angle1 + 180) % 360

            let cosA = EffectSpace.cosine(degrees: angle)
            let sinA = EffectSpace.sine(degrees: angle)
            let cos1 = EffectSpace.cosine(degrees: angle1)
            let sin1 = EffectSpace.sine(degrees: angle1)
            let cos2 = EffectSpace.cosine(degrees: angle2)
            let sin2 = EffectSpace.sine(degrees: angle2)

            var v1 = SIMD3<Float>(dist * cos1 * 0.5 + cosA * inner, 0, dist * sin1 * 0.5 + sinA * inner)
            var v2 = SIMD3<Float>(dist * cos2 * 0.5 + cosA * inner, 0, dist * sin2 * 0.5 + sinA * inner)
            var v3 = SIMD3<Float>(dist * cos2 * 0.5 + cosA * dist, 0, dist * sin2 * 0.5 + sinA * dist)
            var v4 = SIMD3<Float>(dist * cos1 * 0.5 + cosA * dist, 0, dist * sin1 * 0.5 + sinA * dist)

            Self.towardScreen(&v1, &v2, &v3, &v4, rot0: rot0, rot1: rot1)

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: v1 + slot.vecBNow,
                v2: v2 + slot.vecBNow,
                v3: v3 + slot.vecBNow,
                v4: v4 + slot.vecBNow,
                blendSelector: 0,
                textureIndex: Int(UInt8(bitPattern: slot.flag1[0])),
                isWorldPosition: true,
                red: 100,
                green: 100,
                blue: 255,
                extra: 1
            )
        }
    }

    // MARK: - Primitive 154

    /// Motion update for primitive `154` flashing blade fins at 60Hz.
    func primFlashFade(context: EffectTickContext) {
        faceCamera(world: context.world)

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            if process <= 15 {
                state.slots[index].alphaB = min(255, state.slots[index].alphaB + 13)
            } else if process > 20 {
                state.slots[index].alphaB -= 3
                if state.slots[index].alphaB < 0 {
                    state.slots[index].life = 0
                    state.slots[index].alphaB = 0
                }
            }
        }
    }

    /// Geometry submission for primitive `154`, rendering twin dual-layer blade fins at `riseAngle ± 25°`.
    func renderBladeFins(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let base = SIMD3<Float>(0, -6.0, 0)

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let baseStyle: (r: UInt8, g: UInt8, b: UInt8)
            let glowStyle: (r: UInt8, g: UInt8, b: UInt8)
            if slot.flag1[0] == 1 {
                baseStyle = (255, 89, 182)
                glowStyle = (255, 25, 25)
            } else if slot.flag1[0] == 2 {
                baseStyle = (255, 255, 255)
                glowStyle = (255, 255, 255)
            } else {
                baseStyle = (255, 255, 255)
                glowStyle = (25, 25, 255)
            }

            for delta in [-25, 25] {
                let innerAngle = ((Int(slot.riseAngle) + delta) % 360 + 360) % 360
                let inner = SIMD3<Float>(
                    slot.height[0] * EffectSpace.cosine(degrees: innerAngle),
                    -6.0,
                    slot.height[0] * EffectSpace.sine(degrees: innerAngle)
                )
                let outerAngle = (innerAngle + 270) % 360
                let outer = SIMD3<Float>(
                    slot.maxHeight * EffectSpace.cosine(degrees: outerAngle) + inner.x,
                    -6.0,
                    slot.maxHeight * EffectSpace.sine(degrees: outerAngle) + inner.z
                )

                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: slot.alphaB / 4,
                    v1: base,
                    v2: outer,
                    v3: inner,
                    v4: base,
                    blendSelector: 1,
                    textureIndex: 0,
                    isWorldPosition: false,
                    red: baseStyle.r,
                    green: baseStyle.g,
                    blue: baseStyle.b,
                    extra: 1
                )
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: slot.alphaB,
                    v1: base,
                    v2: outer,
                    v3: inner,
                    v4: base,
                    blendSelector: 0,
                    textureIndex: 0,
                    isWorldPosition: false,
                    red: glowStyle.r,
                    green: glowStyle.g,
                    blue: glowStyle.b,
                    extra: 1
                )
            }
        }
    }

    // MARK: - Primitive 156

    /// Motion update for primitive `156` hovering jittering billboard quads at 60Hz.
    func primHoverFollow(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        state.slots[0].height[8] += 5.0
        if state.slots[0].height[8] >= 360.0 {
            state.slots[0].height[8] -= 360.0
        }

        state.slots[0].rotStart += 1
        if state.slots[0].rotStart >= 360 {
            state.slots[0].rotStart -= 360
        }

        let baseY = position.y - 6.0
        state.slots[0].vecBPre.y = baseY
        state.slots[0].vecBNow = SIMD3<Float>(
            position.x,
            EffectSpace.sine(degrees: Int(state.slots[0].rotStart)) * 3.0 + baseY,
            position.z
        )
    }

    /// Geometry submission for primitive `156`, rendering a jittered quad plus 4 subtle cardinal aura copies.
    func renderJitterQuads(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT
        let style = state.slots[0].flag1[1]

        for index in 0..<4 {
            guard state.slots[index].life == 1, state.slots[index].alphaB > 0 else {
                continue
            }

            let slot = state.slots[index]
            let pulseAngle = (slot.height[8] >= 360.0 || slot.height[8] < 0) ? 0 : Int(slot.height[8])
            let radius = slot.distance * EffectSpace.sine(degrees: pulseAngle) * 0.05 + slot.distance

            var angle = ((Int(slot.fullDisplayAngle) % 360) + 360) % 360
            var v1 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: angle), 0, radius * EffectSpace.sine(degrees: angle))
            angle = (angle + Int.random(in: 0..<16) + 85) % 360
            var v2 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: angle), 0, radius * EffectSpace.sine(degrees: angle))
            angle = (angle + Int.random(in: 0..<16) + 85) % 360
            var v3 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: angle), 0, radius * EffectSpace.sine(degrees: angle))
            angle = (angle + Int.random(in: 0..<16) + 85) % 360
            var v4 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: angle), 0, radius * EffectSpace.sine(degrees: angle))

            Self.towardScreen(&v1, &v2, &v3, &v4, rot0: rot0, rot1: rot1)

            v1 += slot.vecBNow
            v2 += slot.vecBNow
            v3 += slot.vecBNow
            v4 += slot.vecBNow

            let textureIndex = Int(UInt8(bitPattern: slot.flag1[0]))
            let primaryBlend: Int16 = style == 2 ? 0 : 1
            let haloColor: (r: UInt8, g: UInt8, b: UInt8) = style == 1 ? (5, 5, 255) : (255, 255, 255)

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: v2,
                v2: v1,
                v3: v4,
                v4: v3,
                blendSelector: primaryBlend,
                textureIndex: textureIndex,
                isWorldPosition: true,
                red: 255,
                green: 255,
                blue: 255
            )

            let offsets: [SIMD3<Float>] = [
                SIMD3<Float>(0.2, 0, 0),
                SIMD3<Float>(-0.2, 0, 0),
                SIMD3<Float>(0, 0, 0.2),
                SIMD3<Float>(0, 0, -0.2),
            ]
            for offset in offsets {
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: slot.alphaB / 2,
                    v1: v2 + offset,
                    v2: v1 + offset,
                    v3: v4 + offset,
                    v4: v3 + offset,
                    blendSelector: 0,
                    textureIndex: textureIndex,
                    isWorldPosition: true,
                    red: haloColor.r,
                    green: haloColor.g,
                    blue: haloColor.b
                )
            }
        }
    }

    // MARK: - Primitive 159

    /// Motion update for primitive `159` inward-collapsing spiral blade quads at 60Hz.
    func primSpiralCollapse() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            if process < 20 {
                state.slots[index].alphaB = min(255, state.slots[index].alphaB + 5)
            }

            let vec = state.slots[index].vecBNow
            let length = sqrtf(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z)

            if state.slots[index].flag1[0] == 0 && length < 12.0 {
                state.slots[index].flag1[0] = 1
                state.slots[index].flag1[1] = 0
            }

            if state.slots[index].flag1[0] == 1 {
                state.slots[index].riseAngle += 9
                if state.slots[index].riseAngle >= 360 {
                    state.slots[index].riseAngle -= 360
                }
                if state.slots[index].rotStart >= 360 {
                    state.slots[index].rotStart -= 360
                }
                state.slots[index].flag1[1] += 1
                if state.slots[index].flag1[1] >= 10 {
                    state.slots[index].flag1[0] = 2
                }
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 2)
                state.slots[index].distance *= 0.99
            }

            if state.slots[index].flag1[0] == 2 {
                state.slots[index].riseAngle -= 3
                if state.slots[index].riseAngle < 0 {
                    state.slots[index].riseAngle += 360
                }
                if state.slots[index].riseAngle >= 360 {
                    state.slots[index].riseAngle -= 360
                }
                state.slots[index].rotStart += 1
                if state.slots[index].rotStart < 0 {
                    state.slots[index].rotStart += 360
                }
                if state.slots[index].rotStart >= 360 {
                    state.slots[index].rotStart -= 360
                }
                if process > 300 {
                    state.slots[index].alphaB = max(0, state.slots[index].alphaB - 1)
                    state.slots[index].distance *= 0.99
                }
            }

            let riseAngle = Int(state.slots[index].riseAngle)
            let rotStart = Int(state.slots[index].rotStart)
            let step = state.slots[index].height[1]
            let cosRise = EffectSpace.cosine(degrees: riseAngle)
            let sinRise = EffectSpace.sine(degrees: riseAngle)
            state.slots[index].vecBNow.x -= step * cosRise * EffectSpace.cosine(degrees: rotStart)
            state.slots[index].vecBNow.y -= step * cosRise * EffectSpace.sine(degrees: rotStart)
            state.slots[index].vecBNow.z -= step * sinRise
        }
    }

    /// Geometry submission for primitive `159`, rendering narrow inner and wider outer tilted blade quads.
    func renderBladeQuads(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let innerColor: (r: UInt8, g: UInt8, b: UInt8)? = switch slot.flag1[2] {
            case 0: (0, 250, 250)
            case 1: (250, 250, 250)
            case 2: (250, 100, 100)
            case 3: (200, 200, 255)
            default: nil
            }
            if let innerColor {
                let (v1, v2, v3, v4) = Self.tiltedBladeCorners(
                    angle: Int(slot.riseAngle),
                    halfSpread: 2,
                    distance: slot.distance,
                    rotStart: Int(slot.rotStart),
                    baseY: slot.height[0],
                    offset: slot.vecBNow
                )
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
                    red: innerColor.r,
                    green: innerColor.g,
                    blue: innerColor.b
                )
            }

            let outerColor: (r: UInt8, g: UInt8, b: UInt8)? = switch slot.flag1[2] {
            case 0: (250, 0, 0)
            case 1: (250, 250, 0)
            case 2: (255, 166, 210)
            case 3: (5, 5, 255)
            default: nil
            }
            if let outerColor {
                let (v1, v2, v3, v4) = Self.tiltedBladeCorners(
                    angle: Int(slot.riseAngle),
                    halfSpread: 8,
                    distance: slot.distance,
                    rotStart: Int(slot.rotStart),
                    baseY: slot.height[0],
                    offset: slot.vecBNow
                )
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
                    red: outerColor.r,
                    green: outerColor.g,
                    blue: outerColor.b
                )
            }
        }
    }

    // MARK: - Primitive 162

    /// Geometry submission for primitive `162`, rendering blue tilted fan slices.
    func renderFanSlice(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let base = slot.height[0]
            let center = SIMD3<Float>(0, base, 0)
            let (left, right) = Self.tiltedFanEndpoints(
                angle: Int(slot.riseAngle),
                halfSpread: 5,
                distance: slot.distance,
                rotStart: Int(slot.rotStart),
                baseY: base
            )

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: left,
                v2: right,
                v3: center,
                v4: center,
                blendSelector: 0,
                textureIndex: 0,
                isWorldPosition: false,
                red: 0,
                green: 0,
                blue: 255,
                extra: 1
            )
        }
    }

    // MARK: - Primitive 163

    /// Motion update for primitive `163` animated fan wedges at 60Hz.
    func primTextureFrames() {
        followMaster()

        let frames = Float(max(1, state.totalTexture))
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            guard state.slots[index].process > 0 else {
                continue
            }

            state.slots[index].height[1] += 1.0
            if state.slots[index].height[1] >= frames {
                state.slots[index].height[1] = 0
            }
        }
    }

    /// Geometry submission for primitive `163`, rendering tilted blue fan wedges with inner base width.
    func renderFanWedge(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let angle = Int(slot.riseAngle)
            let rotStart = Int(slot.rotStart)
            let base = slot.height[0]
            let (left, right) = Self.tiltedFanEndpoints(
                angle: angle,
                halfSpread: 7,
                distance: slot.distance,
                rotStart: rotStart,
                baseY: base
            )

            let rotCos = EffectSpace.cosine(degrees: rotStart)
            let rotSin = EffectSpace.sine(degrees: rotStart)
            let backAngle = ((angle - 270) % 360 + 360) % 360
            let tipAngle = ((angle - 90) % 360 + 360) % 360
            let back = SIMD3<Float>(
                EffectSpace.cosine(degrees: backAngle) * 7.0 * rotCos,
                EffectSpace.cosine(degrees: backAngle) * 7.0 * rotSin + base,
                EffectSpace.sine(degrees: backAngle) * 7.0
            )
            let tip = SIMD3<Float>(
                EffectSpace.cosine(degrees: tipAngle) * 7.0 * rotCos,
                EffectSpace.cosine(degrees: tipAngle) * 7.0 * rotSin + base,
                EffectSpace.sine(degrees: tipAngle) * 7.0
            )

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: tip,
                v2: left,
                v3: right,
                v4: back,
                blendSelector: 0,
                textureIndex: Int(slot.height[1]),
                isWorldPosition: false,
                red: 105,
                green: 105,
                blue: 255
            )
        }
    }

    // MARK: - Primitive 164

    /// Motion update for primitive `164` scrolling straight fan trails at 60Hz.
    func primFrameScroll() {
        followMaster()

        let frames = Float(max(1, state.totalTexture))
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            guard state.slots[index].process > 0 else {
                continue
            }

            state.slots[index].height[1] += 1.0
            if state.slots[index].height[1] >= frames {
                state.slots[index].height[1] = 0
            }

            state.slots[index].distance -= 1.0
            if state.slots[index].distance < 0 {
                state.slots[index].distance += state.slots[index].maxHeight
            }
        }
    }

    /// Geometry submission for primitive `164`, rendering up to 6 straight fan-trail quads along `riseAngle`.
    func renderFanTrail(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let angle = Int(slot.riseAngle)
            let (backRight, left, right, backLeft) = Self.tiltedFanTrailQuad(
                angle: angle,
                halfSpread: 20,
                size: slot.maxHeight,
                rotStart: Int(slot.rotStart),
                baseY: slot.height[0]
            )
            let dirCos = EffectSpace.cosine(degrees: angle)
            let dirSin = EffectSpace.sine(degrees: angle)
            let textureIndex = Int(slot.height[1])

            for step in 0..<6 {
                let dist = Float(step) * slot.maxHeight + slot.distance
                if dist > 100.0 {
                    break
                }
                guard dist > 0 else {
                    continue
                }

                let offset = SIMD3<Float>(dist * dirCos, 0, dist * dirSin)
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: slot.alphaB,
                    v1: backRight + offset,
                    v2: left + offset,
                    v3: right + offset,
                    v4: backLeft + offset,
                    blendSelector: 0,
                    textureIndex: textureIndex,
                    isWorldPosition: false,
                    red: 105,
                    green: 105,
                    blue: 255
                )
            }
        }
    }

    // MARK: - Primitive 165

    /// Motion update for primitive `165` dual-layer curved scrolling fan trails at 60Hz.
    func primScrollTexture() {
        followMaster()

        let frames = Float(max(1, state.totalTexture))
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            guard state.slots[index].process > 0 else {
                continue
            }

            state.slots[index].alphaB = min(255, state.slots[index].alphaB + 2)

            state.slots[index].height[1] += 1.0
            if state.slots[index].height[1] >= frames {
                state.slots[index].height[1] = 0
            }

            state.slots[index].distance -= 0.66
            state.slots[index].height[10] -= 1.0
            if state.slots[index].distance < 0 {
                state.slots[index].distance += state.slots[index].maxHeight
            }
            if state.slots[index].height[10] < 0 {
                state.slots[index].height[10] += state.slots[index].maxHeight
            }
        }
    }

    /// Geometry submission for primitive `165`, rendering two curved 7-step spiral fan trail layers.
    func renderCurvedFanTrail(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            emitCurvedFanTrailLayer(
                into: &collector,
                assets: assets,
                slot: slot,
                baseDistance: slot.distance,
                halfSpread: 15,
                shade: 65
            )
            emitCurvedFanTrailLayer(
                into: &collector,
                assets: assets,
                slot: slot,
                baseDistance: slot.height[10],
                halfSpread: 25,
                shade: 35
            )
        }
    }

    // MARK: - Shared Sweep & Fan Helpers

    private func emitSpinSquareStack(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?,
        slotIndex: Int,
        scale: Float,
        blendSelector: Int16,
        red: UInt8,
        green: UInt8,
        blue: UInt8
    ) {
        let slot = state.slots[slotIndex]
        let pulseAngle = (slot.height[8] >= 360.0 || slot.height[8] < 0) ? 0 : Int(slot.height[8])
        let radius = slot.distance * EffectSpace.sine(degrees: pulseAngle) * 0.05 + slot.distance * scale
        let corners = Self.facingSquareCorners(
            radius: radius,
            startAngle: Int(slot.fullDisplayAngle),
            rot0: state.slots[0].alphaT,
            rot1: state.slots[1].alphaT
        )
        let base0 = corners.0 + slot.vecBNow
        let base1 = corners.1 + slot.vecBNow
        let base2 = corners.2 + slot.vecBNow
        let base3 = corners.3 + slot.vecBNow
        let textureIndex = Int(UInt8(bitPattern: slot.flag1[0]))

        for turn in 0..<36 {
            let drop = Float(turn * 2)
            let spin = ((turn * 45 + slot.process) % 360 + 360) % 360
            let offset = SIMD3<Float>(
                EffectSpace.cosine(degrees: spin) * 10.0,
                -drop,
                EffectSpace.sine(degrees: spin) * 10.0
            )
            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: base0 + offset,
                v2: base1 + offset,
                v3: base2 + offset,
                v4: base3 + offset,
                blendSelector: blendSelector,
                textureIndex: textureIndex,
                isWorldPosition: true,
                red: red,
                green: green,
                blue: blue
            )
        }
    }

    private func emitCurvedFanTrailLayer(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?,
        slot: EffectPrimitiveSlot,
        baseDistance: Float,
        halfSpread: Int,
        shade: UInt8
    ) {
        let size = slot.maxHeight
        let rotStart = Int(slot.rotStart)
        let baseY = slot.height[0]
        let textureIndex = Int(slot.height[1])

        let bendThresholds: [(threshold: Float, segmentLength: Float)] = [
            (20.0, 20.0),
            (33.0, 13.0),
            (46.0, 13.0),
            (59.0, 13.0),
            (71.0, 12.0),
            (84.0, 13.0),
        ]

        for step in 0..<7 {
            let dist = Float(step) * size + baseDistance
            if dist > 100.0 {
                break
            }
            guard dist > 0 else {
                continue
            }

            var bentAngle = Int(slot.riseAngle)
            for item in bendThresholds where dist > item.threshold {
                bentAngle += 5
            }
            bentAngle %= 360

            let (backRight, left, right, backLeft) = Self.tiltedFanTrailQuad(
                angle: bentAngle,
                halfSpread: halfSpread,
                size: size,
                rotStart: rotStart,
                baseY: baseY
            )

            var remain = dist
            var dir = ((Int(slot.riseAngle) % 360) + 360) % 360
            var offset = SIMD3<Float>.zero

            for (idx, item) in bendThresholds.enumerated() where dist > item.threshold {
                if idx > 0 {
                    dir = (dir + 5) % 360
                }
                remain = dist - item.threshold
                offset.x += EffectSpace.cosine(degrees: dir) * item.segmentLength
                offset.z += EffectSpace.sine(degrees: dir) * item.segmentLength
            }
            if dist > 20.0 {
                dir = (dir + 5) % 360
            }
            offset.x += remain * EffectSpace.cosine(degrees: dir)
            offset.z += remain * EffectSpace.sine(degrees: dir)

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: backRight + offset,
                v2: left + offset,
                v3: right + offset,
                v4: backLeft + offset,
                blendSelector: 0,
                textureIndex: textureIndex,
                isWorldPosition: false,
                red: shade,
                green: shade,
                blue: 255
            )
        }
    }

    private static func tiltedFanEndpoints(
        angle: Int,
        halfSpread: Int,
        distance: Float,
        rotStart: Int,
        baseY: Float
    ) -> (left: SIMD3<Float>, right: SIMD3<Float>) {
        let leftAngle = ((angle - halfSpread) % 360 + 360) % 360
        let rightAngle = ((angle + halfSpread) % 360 + 360) % 360
        let rotCos = EffectSpace.cosine(degrees: rotStart)
        let rotSin = EffectSpace.sine(degrees: rotStart)

        let leftX = distance * EffectSpace.cosine(degrees: leftAngle)
        let left = SIMD3<Float>(leftX * rotCos, leftX * rotSin + baseY, distance * EffectSpace.sine(degrees: leftAngle))
        let rightX = distance * EffectSpace.cosine(degrees: rightAngle)
        let right = SIMD3<Float>(rightX * rotCos, rightX * rotSin + baseY, distance * EffectSpace.sine(degrees: rightAngle))
        return (left, right)
    }

    private static func tiltedBladeCorners(
        angle: Int,
        halfSpread: Int,
        distance: Float,
        rotStart: Int,
        baseY: Float,
        offset: SIMD3<Float>
    ) -> (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>) {
        let rotCos = EffectSpace.cosine(degrees: rotStart)
        let rotSin = EffectSpace.sine(degrees: rotStart)

        func point(at rawAngle: Int) -> SIMD3<Float> {
            let a = ((rawAngle % 360) + 360) % 360
            let rx = distance * EffectSpace.cosine(degrees: a)
            return SIMD3<Float>(
                rx * rotCos + offset.x,
                rx * rotSin + baseY + offset.y,
                distance * EffectSpace.sine(degrees: a) + offset.z
            )
        }

        return (
            point(at: angle - halfSpread),
            point(at: angle + halfSpread),
            point(at: angle + 180 - halfSpread),
            point(at: angle + 180 + halfSpread)
        )
    }

    private static func tiltedFanTrailQuad(
        angle: Int,
        halfSpread: Int,
        size: Float,
        rotStart: Int,
        baseY: Float
    ) -> (backRight: SIMD3<Float>, left: SIMD3<Float>, right: SIMD3<Float>, backLeft: SIMD3<Float>) {
        let rotCos = EffectSpace.cosine(degrees: rotStart)
        let rotSin = EffectSpace.sine(degrees: rotStart)

        func corner(at rawAngle: Int) -> SIMD3<Float> {
            let a = ((rawAngle % 360) + 360) % 360
            let x = size * EffectSpace.cosine(degrees: a)
            return SIMD3<Float>(x * rotCos, x * rotSin + baseY, size * EffectSpace.sine(degrees: a))
        }

        let leftAngle = angle - halfSpread
        let rightAngle = angle + halfSpread
        return (
            corner(at: rightAngle - 180),
            corner(at: leftAngle),
            corner(at: rightAngle),
            corner(at: leftAngle + 180)
        )
    }
}
