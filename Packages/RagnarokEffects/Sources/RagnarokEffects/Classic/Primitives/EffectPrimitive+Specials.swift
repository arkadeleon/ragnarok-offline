//
//  EffectPrimitive+Specials.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/25.
//

import Foundation
import simd

extension EffectPrimitive {

    // MARK: - Primitive 35 & PP_DOUBLEGUMGANG (99)

    /// Motion update for primitive `35` and `PP_DOUBLEGUMGANG` (99) orbiting character-head bubbles at 60Hz.
    func primFloatingBubbles(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        let headOffset = resolvedOwnerHeadOffset(world: context.world)

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1

            for bubble in stride(from: 0, through: 12, by: 4) {
                state.slots[index].height[bubble] += 1.0
                if state.slots[index].height[bubble] < 10.0 {
                    state.slots[index].height[bubble + 1] += 25.0
                } else {
                    state.slots[index].height[bubble + 1] -= 12.0
                    if state.slots[index].height[bubble + 1] < 12.0 {
                        state.slots[index].height[bubble] = 0
                        state.slots[index].height[bubble + 1] = 0
                        state.slots[index].height[bubble + 3] = Float(Int.random(in: 0..<360))
                        state.slots[index].height[bubble + 2] = Float(Int.random(in: 0..<5))

                        let randomY = Float(-3 - Int.random(in: 0..<8))
                        switch bubble {
                        case 0:
                            state.slots[index].vecBPre.y = randomY
                        case 4:
                            state.slots[index].vecBNow.y = randomY
                        case 8:
                            state.slots[index].vecTPre.y = randomY
                        default:
                            state.slots[index].vecTNow.y = randomY
                        }
                    }
                }
            }

            if let headOffset {
                state.slots[index].height[20] = headOffset
            }
        }
    }

    /// Geometry submission for primitive `35`, rendering 4 orbiting camera-facing bubble icons per slot.
    func renderOrbitIcons(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?,
        scale: Float,
        red: UInt8,
        green: UInt8,
        blue: UInt8
    ) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT
        let orbitRadius: Float = 4.0

        for index in 0..<4 where state.slots[index].life == 1 {
            var r = red
            var g = green
            var b = blue
            if state.slots[index].flag1[4] == 1 {
                r = 255
                g = 20
                b = 20
            }

            let rx = scale * state.slots[index].distance
            updateOrbitBubblePositions(slotIndex: index, orbitRadius: orbitRadius)
            let corners = Self.facingSquareCorners(radius: rx, rot0: rot0, rot1: rot1)

            let slot = state.slots[index]
            let entries: [(center: SIMD3<Float>, alpha: Int, tex: Int, angle: Float)] = [
                (slot.vecBPre, Int(slot.height[1]), Int(slot.height[2]), slot.height[3]),
                (slot.vecBNow, Int(slot.height[5]), Int(slot.height[6]), slot.height[7]),
                (slot.vecTPre, Int(slot.height[9]), Int(slot.height[10]), slot.height[11]),
                (slot.vecTNow, Int(slot.height[13]), Int(slot.height[14]), slot.height[15]),
            ]

            for entry in entries {
                emitOrbitBubbleQuad(
                    into: &collector,
                    assets: assets,
                    corners: corners,
                    center: entry.center,
                    liftY: slot.height[20],
                    alpha: Int16(clamping: entry.alpha),
                    textureIndex: entry.tex,
                    bubbleAngle: entry.angle,
                    rot0: rot0,
                    red: r,
                    green: g,
                    blue: b
                )
            }
        }
    }

    // MARK: - PP_SHIELDBOOMERANG (42)

    /// Motion update for `PP_SHIELDBOOMERANG` (42) spinning shield projectile with return arc and 3-step trail at 60Hz.
    func primShieldBoomerang(context: EffectTickContext) {
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

        let isFastMode = state.slots[0].flag1[2] == 1
        let trailPeriod = isFastMode ? 1 : 3

        if isFastMode {
            if process <= 10 {
                state.slots[0].alphaB += 25
            }
            if state.slots[0].alphaB >= 255 {
                state.slots[0].alphaB = 255
            }
        }

        if process % trailPeriod == 0 {
            shiftSpecialTrailSlots(process: process, firstDrop: 150)
        }

        state.slots[0].fullDisplayAngle -= 15
        if state.slots[0].fullDisplayAngle < 0 {
            state.slots[0].fullDisplayAngle += 360
        }

        if process == 1 {
            let rx = state.deltaPos.x - state.slots[0].vecBNow.x
            let rz = state.deltaPos.z - state.slots[0].vecBNow.z
            state.slots[0].rotStart = Self.angle(dx: rx, dy: rz)
        }

        if state.slots[0].flag1[1] == 0 {
            if state.slots[0].maxHeight < state.slots[0].height[1] * Float(process) {
                if isFastMode {
                    state.slots[0].flag1[1] = 2
                    state.slots[0].height[1] *= 3
                    let scatter = Int16(Int.random(in: 0..<45))
                    if Int.random(in: 0..<2) == 0 {
                        state.slots[0].rotStart += scatter
                        if state.slots[0].rotStart >= 360 {
                            state.slots[0].rotStart -= 360
                        }
                    } else {
                        state.slots[0].rotStart -= scatter
                        if state.slots[0].rotStart < 0 {
                            state.slots[0].rotStart += 360
                        }
                    }
                } else {
                    state.slots[0].flag1[1] = 1
                }
            }
            state.slots[0].vecBNow.y += state.slots[0].height[2]
        } else if state.slots[0].flag1[1] == 1 {
            let rx = position.x - state.slots[0].vecBNow.x
            let rz = position.z - state.slots[0].vecBNow.z
            let returnAngle = Self.angle(dx: rx, dy: rz)
            if state.slots[0].rotStart < returnAngle - 4 || state.slots[0].rotStart > returnAngle + 4 {
                state.slots[0].rotStart += 5
                if state.slots[0].rotStart >= 360 {
                    state.slots[0].rotStart -= 360
                }
            } else {
                state.slots[0].flag1[1] = 2
            }
        } else {
            state.slots[0].alphaB = max(0, state.slots[0].alphaB - 12)
            state.slots[0].vecBNow.y -= state.slots[0].height[2]
        }

        let heading = Int(state.slots[0].rotStart)
        state.slots[0].vecBNow.x += state.slots[0].height[1] * EffectSpace.cosine(degrees: heading)
        state.slots[0].vecBNow.z += state.slots[0].height[1] * EffectSpace.sine(degrees: heading)
    }

    // MARK: - PP_INTIMIDATE (43)

    /// Motion update for `PP_INTIMIDATE` (43) expanding orbiting squares at 60Hz.
    func primIntimidate(context: EffectTickContext) {
        faceCamera(world: context.world)

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            if process > 0 {
                state.slots[index].distance += state.slots[index].height[0]
            }

            if process > 0 && process <= 10 {
                state.slots[index].alphaB += state.slots[index].flag1[0] == 0 ? 15 : 25
            } else if process > 25 {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 7)
            }

            if state.slots[index].flag1[0] == 2 {
                state.slots[index].rotStart += 3
            }
            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            state.slots[index].height[2] += state.slots[index].flag1[0] == 2 ? 3.0 : 5.0
            if state.slots[index].height[2] >= 360.0 {
                state.slots[index].height[2] -= 360.0
            }
        }
    }

    /// Geometry submission for `PP_INTIMIDATE` (43), rendering orbiting tilted or camera-facing squares.
    func renderOrbitSquare(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for slot in state.slots where slot.life == 1 && slot.alphaB > 0 {
            let distance = slot.distance
            let baseX = EffectSpace.cosine(degrees: Int(slot.fullDisplayAngle)) * distance
            let offsetY = EffectSpace.sine(degrees: Int(slot.fullDisplayAngle)) * distance
            let offsetX = baseX * EffectSpace.cosine(degrees: Int(slot.riseAngle))
            let offsetZ = baseX * EffectSpace.sine(degrees: Int(slot.riseAngle))

            let radius = slot.height[1]
            let a1 = ((Int(slot.rotStart) % 360) + 360) % 360
            let a2 = (a1 + 90) % 360
            let a3 = (a2 + 90) % 360
            let a4 = (a3 + 90) % 360

            let kind = slot.flag1[0]
            var v1: SIMD3<Float>
            var v2: SIMD3<Float>
            var v3: SIMD3<Float>
            var v4: SIMD3<Float>

            if kind == 2 || kind == 8 || kind == 9 {
                v1 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a1), 0, radius * EffectSpace.sine(degrees: a1))
                v2 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a2), 0, radius * EffectSpace.sine(degrees: a2))
                v3 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a3), 0, radius * EffectSpace.sine(degrees: a3))
                v4 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a4), 0, radius * EffectSpace.sine(degrees: a4))
                Self.towardScreen(&v1, &v2, &v3, &v4, rot0: rot0, rot1: rot1)
            } else {
                let tilt = Int(slot.height[2])
                let cs = EffectSpace.cosine(degrees: tilt)
                let sn = EffectSpace.sine(degrees: tilt)
                func tilted(_ angle: Int) -> SIMD3<Float> {
                    let radial = radius * EffectSpace.cosine(degrees: angle)
                    return SIMD3<Float>(cs * radial, radius * EffectSpace.sine(degrees: angle), sn * radial)
                }
                v1 = tilted(a1)
                v2 = tilted(a2)
                v3 = tilted(a3)
                v4 = tilted(a4)
            }

            let center = slot.vecBNow + SIMD3<Float>(offsetX, offsetY, offsetZ)
            let style: (r: UInt8, g: UInt8, b: UInt8, extra: Int8)? = switch kind {
            case 0: (100, 150, 255, 0)
            case 1: (250, 250, 155, 0)
            case 2: (250, 100, 100, 0)
            case 3: (50, 50, 255, 0)
            case 4: (255, 50, 50, 0)
            case 5: (50, 255, 50, 0)
            case 6: (250, 100, 100, 1)
            case 7: (5, 5, 255, 1)
            case 8: (50, 50, 255, 0)
            case 9: (70, 70, 70, 0)
            default: nil
            }

            if let style {
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: slot.alphaB,
                    v1: v1 + center,
                    v2: v2 + center,
                    v3: v3 + center,
                    v4: v4 + center,
                    blendSelector: 0,
                    textureIndex: 0,
                    isWorldPosition: true,
                    red: style.r,
                    green: style.g,
                    blue: style.b,
                    extra: style.extra
                )
            }
        }
    }

    // MARK: - PP_TEIHIT2 (45)

    /// Motion update for `PP_TEIHIT2` (45) directional hit scatter panels at 60Hz.
    func primTeiHit2(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            state.slots[index].fullDisplayAngle -= 5
            if state.slots[index].fullDisplayAngle < 0 {
                state.slots[index].fullDisplayAngle += 360
            }

            if process == 1 {
                var heading = Self.angle(
                    dx: state.deltaPos.x - position.x,
                    dy: state.deltaPos.z - position.z
                )
                heading += Int16(Int.random(in: 0..<60) - 30)
                if heading >= 360 {
                    heading -= 360
                }
                if heading < 0 {
                    heading += 360
                }
                state.slots[index].rotStart = heading
            } else if process <= 10 {
                state.slots[index].alphaB += 15
            } else {
                state.slots[index].alphaB -= 3
                if state.slots[index].alphaB < 0 {
                    state.slots[index].alphaB = 0
                    state.slots[index].life = 0
                }
            }

            let heading = Int(state.slots[index].rotStart)
            state.slots[index].vecBNow.y += state.slots[index].height[2]
            state.slots[index].vecBNow.x += state.slots[index].height[1] * EffectSpace.cosine(degrees: heading)
            state.slots[index].vecBNow.z += state.slots[index].height[1] * EffectSpace.sine(degrees: heading)
        }
    }

    // MARK: - PP_CHEMICALPROTECTION (54)

    /// Motion update for `PP_CHEMICALPROTECTION` (54) flashing rays at 60Hz.
    func primChemical(context: EffectTickContext) {
        faceCamera(world: context.world)

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            if process <= 10 {
                state.slots[index].alphaB += 18
            } else if process > 20 {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 15)
            }
        }
    }

    /// Geometry submission for `PP_CHEMICALPROTECTION` (54), rendering dual-width camera-facing wedge rays.
    func renderChemical(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for slot in state.slots where slot.life == 1 && slot.alphaB > 0 {
            let passes: [(spread: Int, alpha: Int16, red: UInt8, green: UInt8, blue: UInt8)] = [
                (3, Int16(Float(slot.alphaB) * 0.5), 255, 255, 255),
                (5, slot.alphaB, 130, 130, 255),
            ]

            for pass in passes {
                let leftAngle = ((Int(slot.riseAngle) - pass.spread) % 360 + 360) % 360
                let rightAngle = ((Int(slot.riseAngle) + pass.spread) % 360 + 360) % 360

                var v1 = SIMD3<Float>.zero
                var v2 = SIMD3<Float>(
                    EffectSpace.cosine(degrees: leftAngle) * slot.distance,
                    0,
                    EffectSpace.sine(degrees: leftAngle) * slot.distance
                )
                var v3 = SIMD3<Float>(
                    EffectSpace.cosine(degrees: rightAngle) * slot.distance,
                    0,
                    EffectSpace.sine(degrees: rightAngle) * slot.distance
                )
                var v4 = SIMD3<Float>.zero
                Self.towardScreen(&v1, &v2, &v3, &v4, rot0: rot0, rot1: rot1)

                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: pass.alpha,
                    v1: v1,
                    v2: v2,
                    v3: v3,
                    v4: v4,
                    blendSelector: 0,
                    textureIndex: 0,
                    isWorldPosition: false,
                    red: pass.red,
                    green: pass.green,
                    blue: pass.blue
                )
            }
        }
    }

    // MARK: - PP_FIRSTAID (58)

    /// Motion update for `PP_FIRSTAID` (58) pulsing healing glow at 60Hz.
    func primFirstAid(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        state.slots[0].height[8] += 3.0
        if state.slots[0].height[8] >= 360.0 {
            state.slots[0].height[8] -= 360.0
        }

        if state.slots[0].process <= 20 {
            state.slots[0].alphaB += 4
        }
        if state.slots[0].process > 100 {
            state.slots[0].alphaB = max(0, state.slots[0].alphaB - 1)
        }
    }

    // MARK: - PP_SAINTWING (76)

    /// Motion update for `PP_SAINTWING` (76) flapping angel wings at 60Hz.
    func primSaintWing(context: EffectTickContext) {
        followMaster()

        let ownerAngle = resolvedOwnerFacingAngle(world: context.world)
        let pitchOffset = -9.0 - Float(Int(state.slots[1].alphaT) - 115) * 0.17

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            state.slots[index].riseAngle += 1
            if state.slots[index].riseAngle >= 360 {
                state.slots[index].riseAngle -= 360
            }

            state.slots[index].height[0] = pitchOffset
            let flap = EffectSpace.sine(degrees: Int(state.slots[index].riseAngle)) * 20.0 + 20.0
            state.slots[index].fullDisplayAngle = Int16(Int(flap))

            if index == 0 || index == 2 {
                state.slots[index].rotStart = Int16(Int(ownerAngle + 135.0))
            } else {
                state.slots[index].rotStart = Int16(Int(ownerAngle + 45.0))
            }
        }
    }

    /// Geometry submission for `PP_SAINTWING` (76), rendering 10 layered feather quads per wing.
    func renderSaintWing(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 where state.slots[index].life == 1 {
            let slot = state.slots[index]
            guard index == 0 || index == 1 else {
                continue
            }

            let rx = slot.distance
            let angle1 = ((Int(slot.rotStart) - 65) % 360 + 360) % 360
            let angle2 = ((Int(slot.rotStart) + 65) % 360 + 360) % 360
            let baseAngle = ((Int(slot.rotStart) % 360) + 360) % 360
            let cs1 = EffectSpace.cosine(degrees: baseAngle)
            let sn1 = EffectSpace.sine(degrees: baseAngle)

            let v1 = SIMD3<Float>(rx * EffectSpace.cosine(degrees: angle1), slot.height[0], rx * EffectSpace.sine(degrees: angle1))
            let v4 = SIMD3<Float>(rx * EffectSpace.cosine(degrees: angle2), slot.height[0], rx * EffectSpace.sine(degrees: angle2))

            for feather in 0..<10 {
                let rz: Float = feather < 5
                    ? slot.maxHeight
                    : EffectSpace.sine(degrees: Int(slot.riseAngle)) * 0.5 + 0.5 + slot.maxHeight

                var add = (feather / 5) * 45 + (feather % 5) * 3
                if feather < 5 {
                    add += Int(slot.fullDisplayAngle)
                }

                let wingSpan = SIMD3<Float>(
                    cs1 * rz * EffectSpace.cosine(degrees: add),
                    -(rz * EffectSpace.sine(degrees: add)),
                    sn1 * rz * EffectSpace.cosine(degrees: add)
                )

                let v2 = v1 + wingSpan
                let v3 = v4 + wingSpan

                let p1 = index == 1 ? v1 : v4
                let p2 = index == 1 ? v2 : v3
                let p3 = index == 1 ? v3 : v2
                let p4 = index == 1 ? v4 : v1

                if feather % 5 < 4 {
                    var alpha = Int(slot.alphaB)
                    for _ in stride(from: 3, through: feather % 5, by: -1) {
                        alpha = Int(Float(alpha) * 0.7)
                    }
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: Int16(clamping: alpha),
                        v1: p1,
                        v2: p2,
                        v3: p3,
                        v4: p4,
                        blendSelector: 0,
                        textureIndex: 0,
                        isWorldPosition: false,
                        red: 105,
                        green: 105,
                        blue: 255
                    )
                } else {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: slot.alphaB,
                        v1: p1,
                        v2: p2,
                        v3: p3,
                        v4: p4,
                        blendSelector: 1,
                        textureIndex: 0,
                        isWorldPosition: false,
                        red: 205,
                        green: 205,
                        blue: 255
                    )
                }
            }
        }
    }

    // MARK: - PP_SPHEREWIND (77) & PP_SPHEREWIND2 (91)

    /// Motion update for `PP_SPHEREWIND` (77) orbiting wind bands at 60Hz.
    func primSphereWind() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            var rot = Int(Float(state.slots[index].rotStart) + state.slots[index].height[1])
            if rot >= 360 {
                rot -= 360
            }
            state.slots[index].rotStart = Int16(rot)
        }
    }

    /// Motion update for `PP_SPHEREWIND2` (91) expanding tilting wind bands at 60Hz.
    func primSphereWind2() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            if process <= 25 {
                state.slots[index].alphaB += 2
            } else if process > 70 {
                state.slots[index].alphaB -= 2
            }
            if state.slots[index].alphaB < 0 {
                state.slots[index].alphaB = 0
            }

            state.slots[index].distance *= 1.01
            state.slots[index].riseAngle += 1
            if Int.random(in: 0..<2) == 0 {
                state.slots[index].riseAngle += 1
            }
            if state.slots[index].riseAngle >= 360 {
                state.slots[index].riseAngle -= 360
            }

            state.slots[index].rotStart += Int16(state.slots[index].height[1])
            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }
        }
    }

    /// Geometry submission for `PP_SPHEREWIND` (77) and `PP_SPHEREWIND2` (91), rendering 20-segment tilted wind ribbons.
    func renderSphereWind(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for slot in state.slots where slot.life == 1 {
            let fullAngle = Int(slot.fullDisplayAngle)
            let step = fullAngle / 20
            guard step > 0 else {
                continue
            }

            let cosRise = EffectSpace.cosine(degrees: Int(slot.riseAngle))
            let sinRise = EffectSpace.sine(degrees: Int(slot.riseAngle))
            let halfRibbon = SIMD3<Float>(
                -(slot.maxHeight * sinRise),
                slot.maxHeight * cosRise,
                0
            )

            var prevTop = SIMD3<Float>.zero
            var prevBottom = SIMD3<Float>.zero
            var order = 0
            var count = 0

            while count <= fullAngle {
                var angle = Int(slot.rotStart) + count
                if angle >= 360 {
                    angle -= 360
                } else if angle < 0 {
                    angle += 360
                }
                if fullAngle == 360 && order == 20 {
                    angle = Int(slot.rotStart)
                }

                let cs1 = EffectSpace.cosine(degrees: angle)
                let sn1 = EffectSpace.sine(degrees: angle)
                let mid = SIMD3<Float>(
                    cs1 * (cosRise * slot.distance),
                    cs1 * (sinRise * slot.distance) + slot.height[0],
                    sn1 * slot.distance
                )
                let curTop = mid + halfRibbon
                let curBottom = mid - halfRibbon

                if order > 0 {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        texPart: order - 1,
                        alphaB: slot.alphaB,
                        alphaT: slot.alphaB,
                        v1: prevTop,
                        v2: curTop,
                        v3: curBottom,
                        v4: prevBottom,
                        textureIndex: 0
                    )
                }

                order += 1
                if order >= 21 {
                    order = 20
                }
                prevTop = curTop
                prevBottom = curBottom
                count += step
            }
        }
    }

    // MARK: - PP_RAINBOW (93)

    /// Motion update for `PP_RAINBOW` (93) rising and fading 7-band rainbow arch at 60Hz.
    func primRainbow() {
        for index in 0..<4 where state.slots[index].life > 0 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            if process <= 180 {
                state.slots[index].alphaB += 1
                state.slots[index].rotStart += 1
            } else if process <= 360 {
                state.slots[index].alphaB -= 1
                state.slots[index].rotStart += 1
            }

            state.slots[index].alphaB = max(0, min(250, state.slots[index].alphaB))
            if state.slots[index].riseAngle >= 360 {
                state.slots[index].riseAngle -= 360
            }
        }
    }

    /// Geometry submission for `PP_RAINBOW` (93), rendering a 7-color spectral arch.
    func renderRainbow(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let spectrum: [(UInt8, UInt8, UInt8)] = [
            (255, 0, 0),
            (255, 126, 0),
            (255, 255, 0),
            (0, 255, 0),
            (0, 0, 255),
            (115, 50, 200),
            (255, 0, 255),
        ]

        for slot in state.slots where slot.life == 1 && slot.alphaB > 0 {
            let fullAngle = Int(slot.fullDisplayAngle)
            let basicAngle = fullAngle / 20
            guard basicAngle > 0 else {
                continue
            }

            let cosYaw = EffectSpace.cosine(degrees: Int(slot.riseAngle))
            let sinYaw = EffectSpace.sine(degrees: Int(slot.riseAngle))

            for (bandIndex, rgb) in spectrum.enumerated() {
                let outerScale = Float(1.0 - Double(bandIndex) * 0.05)
                let innerScale = Float(1.0 - Double(bandIndex + 1) * 0.05)
                var order = 0
                var count = 0

                while count <= fullAngle {
                    let a1 = (count + Int(slot.rotStart)) % 360
                    let a2 = (count + Int(slot.rotStart) + basicAngle) % 360

                    let cs1 = EffectSpace.cosine(degrees: a1)
                    let sn1 = EffectSpace.sine(degrees: a1)
                    let cs2 = EffectSpace.cosine(degrees: a2)
                    let sn2 = EffectSpace.sine(degrees: a2)

                    let r1Out = cs1 * slot.distance * outerScale
                    let r1In = cs1 * slot.distance * innerScale
                    let r2Out = cs2 * slot.distance * outerScale
                    let r2In = cs2 * slot.distance * innerScale

                    let v1 = SIMD3<Float>(cosYaw * r1Out, sn1 * slot.distance * outerScale * 2.0, sinYaw * r1Out)
                    let v4 = SIMD3<Float>(cosYaw * r1In, sn1 * slot.distance * innerScale * 2.0, sinYaw * r1In)
                    let v2 = SIMD3<Float>(cosYaw * r2Out, sn2 * slot.distance * outerScale * 2.0, sinYaw * r2Out)
                    let v3 = SIMD3<Float>(cosYaw * r2In, sn2 * slot.distance * innerScale * 2.0, sinYaw * r2In)

                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        texPart: order,
                        alphaB: slot.alphaB,
                        alphaT: slot.alphaB,
                        v1: v2,
                        v2: v3,
                        v3: v4,
                        v4: v1,
                        blendSelector: 0,
                        red: rgb.0,
                        green: rgb.1,
                        blue: rgb.2
                    )

                    order += 1
                    if order >= 21 {
                        order = 20
                    }
                    count += basicAngle
                }
            }
        }
    }

    // MARK: - PP_PEONG (94)

    /// Motion update for `PP_PEONG` (94) arcing outward burst quads at 60Hz.
    func primPeong(context: EffectTickContext) {
        faceCamera(world: context.world)

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            if process <= 90 {
                let heading = Int(state.slots[index].riseAngle)
                state.slots[index].vecBPre.x += EffectSpace.cosine(degrees: heading) * state.slots[index].maxHeight
                state.slots[index].vecBPre.z += EffectSpace.sine(degrees: heading) * state.slots[index].maxHeight

                let arcAngle = (process * 2) % 360
                state.slots[index].vecBPre.y = state.slots[index].vecBNow.y
                    - EffectSpace.sine(degrees: arcAngle) * state.slots[index].maxHeight * 50.0
            }

            if process <= 25 {
                state.slots[index].alphaB += 2
            }
            if process > 70 {
                state.slots[index].alphaB -= 1
            }
            if state.slots[index].alphaB < 0 {
                state.slots[index].alphaB = 0
            }
        }
    }

    /// Geometry submission for `PP_PEONG` (94), rendering camera-facing burst quads at `vecBPre`.
    func renderPeong(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for slot in state.slots where slot.life == 1 {
            let corners = Self.facingSquareCorners(radius: slot.distance, rot0: rot0, rot1: rot1)
            let base = slot.vecBPre
            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: corners.0 + base,
                v2: corners.1 + base,
                v3: corners.2 + base,
                v4: corners.3 + base,
                blendSelector: 1,
                textureIndex: 0,
                isWorldPosition: false,
                red: 255,
                green: 255,
                blue: 255
            )
        }
    }

    // MARK: - PP_PEONGUP (96)

    /// Motion update for `PP_PEONGUP` (96) drifting rising puffs at 60Hz.
    func primPeongUp(context: EffectTickContext) {
        faceCamera(world: context.world)

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            state.slots[index].alphaB = max(0, state.slots[index].alphaB + (process >= 30 ? -2 : 5))
            Self.driftSlotAngles(&state.slots[index], count: 2, rise: 3.0, fall: 2.0)

            let height = state.slots[index].vecBPre.y
            if height < 0 {
                state.slots[index].vecBPre.x += EffectSpace.sine(degrees: Int(state.slots[index].height[0])) * 0.03
                state.slots[index].vecBPre.z += EffectSpace.sine(degrees: Int(state.slots[index].height[2])) * 0.03
            }
            state.slots[index].vecBPre.y = height - state.slots[index].maxHeight
        }
    }

    /// Geometry submission for `PP_PEONGUP` (96), rendering tinted rising camera-facing quads.
    func renderPeongUp(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for slot in state.slots where slot.life == 1 {
            let corners = Self.facingSquareCorners(radius: slot.distance, rot0: rot0, rot1: rot1)
            let base = slot.vecBPre
            let v1 = corners.0 + base
            guard v1.y <= 0 else {
                continue
            }

            let (red, green, blue): (UInt8, UInt8, UInt8) = switch slot.flag1[0] {
            case 2: (105, 105, 225)
            case 3: (55, 55, 55)
            default: (255, 255, 255)
            }

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: v1,
                v2: corners.1 + base,
                v3: corners.2 + base,
                v4: corners.3 + base,
                blendSelector: 0,
                textureIndex: 0,
                isWorldPosition: false,
                red: red,
                green: green,
                blue: blue
            )
        }
    }

    // MARK: - PP_TANJI2 (97)

    /// Motion update for `PP_TANJI2` (97) traveling projectile spawning `EF_AIRTEXTURE` child effects every 4 ticks at 60Hz.
    func primTanji2(context: EffectTickContext) {
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

        let isFastMode = state.slots[0].flag1[2] == 1
        let trailPeriod = isFastMode ? 1 : 3

        if isFastMode {
            if process <= 10 {
                state.slots[0].alphaB += 25
            }
            if state.slots[0].alphaB >= 255 {
                state.slots[0].alphaB = 255
            }
        }

        if process % trailPeriod == 0 {
            shiftSpecialTrailSlots(process: process, firstDrop: 150)
        }

        state.slots[0].fullDisplayAngle -= 15
        if state.slots[0].fullDisplayAngle < 0 {
            state.slots[0].fullDisplayAngle += 360
        }

        if process == 1 {
            let rx = state.deltaPos.x - state.slots[0].vecBNow.x
            let rz = state.deltaPos.z - state.slots[0].vecBNow.z
            state.slots[0].rotStart = Self.angle(dx: rx, dy: rz)
        }

        let heading = Int(state.slots[0].rotStart)
        state.slots[0].vecBNow.x += state.slots[0].height[1] * EffectSpace.cosine(degrees: heading)
        state.slots[0].vecBNow.z += state.slots[0].height[1] * EffectSpace.sine(degrees: heading)

        if process % 4 == 0 {
            let ownerID = state.slots[0].targetObjectID ?? master?.ownerObjectID ?? master?.targetObjectID
            let childRequest = EffectSpawnRequest(
                effectID: .ef_airtexture,
                worldPosition: EffectSpace.toWorldPosition(state.slots[0].vecBNow),
                ownerObjectID: ownerID,
                targetObjectID: ownerID
            )
            context.spawnChildEffect(childRequest)
        }
    }

    // MARK: - PP_DOUBLEGUMGANG (99)

    /// Geometry submission for `PP_DOUBLEGUMGANG` (99), rendering 3 concentric glow passes for each of 4 orbiting bubbles.
    func renderDoubleGumGang(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT
        let orbitRadius: Float = 4.0

        for index in 0..<4 where state.slots[index].life == 1 {
            updateOrbitBubblePositions(slotIndex: index, orbitRadius: orbitRadius)
            let slot = state.slots[index]

            let passes: [(scale: Float, red: UInt8, green: UInt8, blue: UInt8)] = switch slot.flag1[4] {
            case 0:
                [(1.0, 100, 100, 255), (1.2, 0, 0, 120), (2.0, 0, 0, 120)]
            case 1:
                [(1.0, 90, 90, 80), (1.2, 60, 60, 50), (2.0, 30, 30, 20)]
            default:
                [(1.0, 255, 100, 100), (1.2, 120, 0, 0), (2.0, 120, 0, 0)]
            }

            let entries: [(center: SIMD3<Float>, alpha: Int, tex: Int, angle: Float)] = [
                (slot.vecBPre, min(Int(slot.height[1]), slot.process), Int(slot.height[2]), slot.height[3]),
                (slot.vecBNow, min(Int(slot.height[5]), slot.process), Int(slot.height[6]), slot.height[7]),
                (slot.vecTPre, min(Int(slot.height[9]), slot.process), Int(slot.height[10]), slot.height[11]),
                (slot.vecTNow, min(Int(slot.height[13]), slot.process), Int(slot.height[14]), slot.height[15]),
            ]

            for pass in passes {
                let corners = Self.facingSquareCorners(radius: slot.distance * pass.scale, rot0: rot0, rot1: rot1)
                for entry in entries {
                    emitOrbitBubbleQuad(
                        into: &collector,
                        assets: assets,
                        corners: corners,
                        center: entry.center,
                        liftY: slot.height[20],
                        alpha: Int16(clamping: entry.alpha),
                        textureIndex: entry.tex,
                        bubbleAngle: entry.angle,
                        rot0: rot0,
                        red: pass.red,
                        green: pass.green,
                        blue: pass.blue
                    )
                }
            }
        }
    }

    // MARK: - PP_ATTACKENERGY2 (106)

    /// Motion update for `PP_ATTACKENERGY2` (106) forward-facing energy shockwave rings at 60Hz.
    func primAttackEnergy2(context: EffectTickContext) {
        followMaster()

        let ownerAngle = resolvedOwnerFacingAngle(world: context.world)

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            if state.slots[index].height[1] < 90.0 {
                state.slots[index].height[1] += 1.0
                state.slots[index].alphaB = min(60, state.slots[index].alphaB + 10)
            } else {
                state.slots[index].alphaB = 10
                state.slots[index].height[1] = 0
            }

            if process > 30 {
                let limit = Int16(max(0, (45 - process) * 4))
                if state.slots[index].alphaB >= limit {
                    state.slots[index].alphaB = limit
                }
            }

            state.slots[index].riseAngle += 1
            if state.slots[index].riseAngle >= 360 {
                state.slots[index].riseAngle -= 360
            }

            var rotStart = Int(ownerAngle + 180.0) % 360
            if rotStart < 0 {
                rotStart += 360
            }
            state.slots[index].rotStart = Int16(rotStart)

            let forwardAngle = (rotStart + 90) % 360
            state.slots[index].vecTNow.x = EffectSpace.cosine(degrees: forwardAngle)
            state.slots[index].vecTNow.z = EffectSpace.sine(degrees: forwardAngle)
        }
    }

    /// Geometry submission for `PP_ATTACKENERGY2` (106), rendering double-drawn hemispherical shockwave bands.
    func renderAttackEnergy2(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for slot in state.slots where slot.life == 1 && slot.alphaB > 0 {
            let fullAngle = Int(slot.fullDisplayAngle)
            let basicAngle = fullAngle / 20
            guard basicAngle > 0 else {
                continue
            }

            let cs2 = EffectSpace.cosine(degrees: Int(slot.rotStart))
            let sn2 = EffectSpace.sine(degrees: Int(slot.rotStart))
            let angle2 = Int(slot.height[1])
            let angle3 = min(90, Int(slot.height[1] + 10.0))

            let cs3A = EffectSpace.cosine(degrees: angle2)
            let sn3A = EffectSpace.sine(degrees: angle2)
            let cs3B = EffectSpace.cosine(degrees: angle3)
            let sn3B = EffectSpace.sine(degrees: angle3)

            var prev2 = SIMD3<Float>.zero
            var prev4 = SIMD3<Float>.zero
            var order = 0
            var count = 0

            while count <= fullAngle {
                var angle = count + Int(slot.riseAngle)
                if angle >= 360 {
                    angle -= 360
                }
                if fullAngle == 360 && count == 360 {
                    angle = Int(slot.riseAngle)
                }

                let cs1 = EffectSpace.cosine(degrees: angle)
                let sn1 = EffectSpace.sine(degrees: angle)

                let dA = slot.distance * sn3A
                let v2 = SIMD3<Float>(
                    cs2 * (sn1 * dA) + slot.vecTNow.x * (3.0 + cs3A * slot.maxHeight),
                    cs1 * dA - slot.maxHeight,
                    sn2 * (sn1 * dA) + slot.vecTNow.z * (3.0 + cs3A * slot.maxHeight)
                )

                let dB = slot.distance * sn3B
                let v4 = SIMD3<Float>(
                    cs2 * (sn1 * dB) + slot.vecTNow.x * (3.0 + cs3B * slot.maxHeight),
                    cs1 * dB - slot.maxHeight,
                    sn2 * (sn1 * dB) + slot.vecTNow.z * (3.0 + cs3B * slot.maxHeight)
                )

                if count > 0 {
                    for _ in 0..<2 {
                        renderTeiRect(
                            into: &collector,
                            assets: assets,
                            texPart: order - 1,
                            alphaB: slot.alphaB,
                            alphaT: slot.alphaB,
                            v1: prev2,
                            v2: v2,
                            v3: v4,
                            v4: prev4,
                            textureIndex: 0
                        )
                    }
                }

                order += 1
                if order > 20 {
                    order = 20
                }
                prev2 = v2
                prev4 = v4
                count += basicAngle
            }
        }
    }

    // MARK: - PP_SOULLINK (109)

    /// Motion update for `PP_SOULLINK` (109) orbiting soul arc that spawns `EF_SOULLIGHT` child effects during ticks `< 180`.
    func primSoulLink(context: EffectTickContext) {
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

            if process <= 10 {
                state.slots[index].height[13] += 20.0
            } else if process > 170 {
                state.slots[index].height[13] = max(0, state.slots[index].height[13] - 5.0)
            }

            var angle = Float(process) / 30.0 + state.slots[index].vecTNow.x
            if angle >= 359.0 {
                angle = 359.0
            }
            state.slots[index].vecTNow.x = angle

            let intAngle = Int(angle)
            state.slots[index].vecBPre = SIMD3<Float>(
                Float(intAngle) / 6.0 - 30.0,
                -(EffectSpace.sine(degrees: intAngle) * 20.0) - 40.0,
                0
            )

            let corners = Self.facingSquareCorners(radius: state.slots[index].distance, rot0: rot0, rot1: rot1)
            let length = state.slots[index].vecBPre.x
            let offset = SIMD3<Float>(
                length * EffectSpace.cosine(degrees: Int(rot0)),
                state.slots[index].vecBPre.y,
                length * EffectSpace.sine(degrees: Int(rot0))
            )

            if (corners.0.y + offset.y) <= 0 && process < 180 {
                let targetID = state.slots[index].targetObjectID ?? master?.targetObjectID ?? master?.ownerObjectID
                let childRequest = EffectSpawnRequest(
                    effectID: .ef_soullight,
                    worldPosition: EffectSpace.toWorldPosition(position + offset),
                    ownerObjectID: targetID,
                    targetObjectID: targetID
                )
                context.spawnChildEffect(childRequest)
            }
        }
    }

    /// Geometry submission for `PP_SOULLINK` (109), rendering camera-aligned glowing soul quads (read-only).
    func renderSoulLink(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for slot in state.slots where slot.life == 1 {
            let corners = Self.facingSquareCorners(radius: slot.distance, rot0: rot0, rot1: rot1)
            let length = slot.vecBPre.x
            let offset = SIMD3<Float>(
                length * EffectSpace.cosine(degrees: Int(rot0)),
                slot.vecBPre.y,
                length * EffectSpace.sine(degrees: Int(rot0))
            )

            let v1 = corners.0 + offset
            guard v1.y <= 0 else {
                continue
            }

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: Int16(clamping: Int(slot.height[13])),
                v1: v1,
                v2: corners.1 + offset,
                v3: corners.2 + offset,
                v4: corners.3 + offset,
                blendSelector: 0,
                textureIndex: 0,
                isWorldPosition: false,
                red: 125,
                green: 125,
                blue: 255
            )
        }
    }

    // MARK: - PP_SOULPARTICLE (111) & Primitive 115

    /// Motion update for `PP_SOULPARTICLE` (111) drifting 3-point soul motes at 60Hz.
    func primSoulParticle(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            Self.driftSlotAngles(&state.slots[index], count: 6, rise: 3.0, fall: 2.0)

            for value in 12..<15 {
                if process < 10 {
                    state.slots[index].height[value] += 20.0
                } else if process > 30 {
                    state.slots[index].height[value] = max(0, state.slots[index].height[value] - 3.0)
                }
            }

            let speed = state.slots[index].maxHeight
            if state.slots[index].vecBPre.y < 0 {
                state.slots[index].vecBPre.x += speed * EffectSpace.sine(degrees: Int(state.slots[index].height[0]))
                state.slots[index].vecBPre.z += speed * EffectSpace.sine(degrees: Int(state.slots[index].height[2]))
            }
            state.slots[index].vecBPre.y -= speed

            if state.slots[index].vecBNow.y < 0 {
                state.slots[index].vecBNow.x -= speed * EffectSpace.sine(degrees: Int(state.slots[index].height[4]))
                state.slots[index].vecBNow.z -= speed * EffectSpace.sine(degrees: Int(state.slots[index].height[6]))
            }
            state.slots[index].vecBNow.y += speed

            if state.slots[index].vecTPre.y < 0 {
                state.slots[index].vecTPre.x += speed * 1.2 * EffectSpace.sine(degrees: Int(state.slots[index].height[8]))
                state.slots[index].vecTPre.z -= speed * 1.2 * EffectSpace.sine(degrees: Int(state.slots[index].height[10]))
            }
        }
    }

    /// Motion update for primitive `115` spherical outward particle spread at 60Hz.
    func primParticleSpread(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let maxH = state.slots[index].maxHeight

            let s0 = maxH * EffectSpace.cosine(degrees: Int(state.slots[index].height[2]))
            state.slots[index].vecBPre.y -= maxH * EffectSpace.sine(degrees: Int(state.slots[index].height[2]))
            state.slots[index].vecBPre.x += s0 * EffectSpace.sine(degrees: Int(state.slots[index].height[0]))
            state.slots[index].vecBPre.z += s0 * EffectSpace.cosine(degrees: Int(state.slots[index].height[0]))

            let s1 = maxH * EffectSpace.cosine(degrees: Int(state.slots[index].height[6]))
            state.slots[index].vecBNow.y -= maxH * EffectSpace.sine(degrees: Int(state.slots[index].height[6]))
            state.slots[index].vecBNow.x += s1 * EffectSpace.sine(degrees: Int(state.slots[index].height[4]))
            state.slots[index].vecBNow.z += s1 * EffectSpace.cosine(degrees: Int(state.slots[index].height[4]))

            let s2 = maxH * EffectSpace.cosine(degrees: Int(state.slots[index].height[10]))
            state.slots[index].vecTPre.y -= maxH * EffectSpace.sine(degrees: Int(state.slots[index].height[10]))
            state.slots[index].vecTPre.x += s2 * EffectSpace.sine(degrees: Int(state.slots[index].height[8]))
            state.slots[index].vecTPre.z += s2 * EffectSpace.cosine(degrees: Int(state.slots[index].height[8]))

            if state.slots[index].process > 25 {
                state.slots[index].maxHeight *= 0.9
                for value in 12..<15 {
                    state.slots[index].height[value] = max(0, state.slots[index].height[value] - 6.0)
                }
            }
        }
    }

    /// Geometry submission for `PP_SOULPARTICLE` (111) and primitive `115`, rendering 3 tinted camera-facing motes per slot.
    func renderSoulParticle(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for slot in state.slots where slot.life == 1 {
            let corners = Self.facingSquareCorners(radius: slot.distance, rot0: rot0, rot1: rot1)
            let points: [(base: SIMD3<Float>, alpha: Float, extraShade: UInt8)] = [
                (slot.vecBPre, slot.height[12], 40),
                (slot.vecBNow, slot.height[13], 10),
                (slot.vecTPre, slot.height[14], 70),
            ]

            for entry in points {
                let v1 = corners.0 + entry.base
                guard v1.y <= 0 else {
                    continue
                }

                let alpha = Int16(clamping: max(0, Int(entry.alpha)))
                let rgb: (UInt8, UInt8, UInt8)? = switch slot.height[15] {
                case 0.0: (80, 80, 255)
                case 1.0: (255, 200, 200)
                case 2.0: (255, 160, 160)
                case 3.0: (255, 120, 120)
                case 4.0: (entry.extraShade, entry.extraShade, 255)
                default: nil
                }

                if let rgb {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: alpha,
                        v1: v1,
                        v2: corners.1 + entry.base,
                        v3: corners.2 + entry.base,
                        v4: corners.3 + entry.base,
                        blendSelector: 0,
                        textureIndex: 0,
                        isWorldPosition: false,
                        red: rgb.0,
                        green: rgb.1,
                        blue: rgb.2
                    )
                }
            }
        }
    }

    // MARK: - PP_SHIELDBOOMERANG3 (116)

    /// Motion update for `PP_SHIELDBOOMERANG3` (116) straight spinning shield projectile with 3-step trail at 60Hz.
    func primShieldBoomerang3(context: EffectTickContext) {
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

        if process % 3 == 0 {
            shiftSpecialTrailSlots(process: process, firstDrop: 150)
        }

        state.slots[0].fullDisplayAngle -= 15
        if state.slots[0].fullDisplayAngle < 0 {
            state.slots[0].fullDisplayAngle += 360
        }

        if process <= 5 {
            state.slots[0].alphaB = min(255, state.slots[0].alphaB + 45)
        }
        if process >= 15 {
            state.slots[0].alphaB = max(0, state.slots[0].alphaB - 10)
        }

        let heading = Int(state.slots[0].rotStart)
        state.slots[0].vecBNow.x += state.slots[0].height[1] * EffectSpace.cosine(degrees: heading)
        state.slots[0].vecBNow.z += state.slots[0].height[1] * EffectSpace.sine(degrees: heading)
    }

    // MARK: - PP_SMA (120)

    /// Motion update for `PP_SMA` (120) traveling spawner that emits `EF_SMA2`, `EF_SMA3`, or `EF_SMA_BLACK2` child effects.
    func primSMA(context: EffectTickContext) {
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            if process == 1 {
                state.slots[index].rotStart = Self.angle(
                    dx: state.deltaPos.x - position.x,
                    dy: state.deltaPos.z - position.z
                )
            }

            let heading = Int(state.slots[index].rotStart)
            state.slots[index].vecBNow.x += state.slots[index].height[1] * EffectSpace.cosine(degrees: heading)
            state.slots[index].vecBNow.z += state.slots[index].height[1] * EffectSpace.sine(degrees: heading)
        }

        let slot = state.slots[0]
        guard slot.life == 1 else {
            return
        }

        let ownerID = slot.targetObjectID ?? master?.ownerObjectID ?? master?.targetObjectID
        let childWorldPos = EffectSpace.toWorldPosition(slot.vecBNow)
        let extra = SIMD3<Float>(Float(slot.process), slot.process % 16 == 0 ? 0.0 : 1.0, 0.0)

        switch slot.flag1[0] {
        case 0 where slot.process % 8 == 0:
            context.spawnChildEffect(
                EffectSpawnRequest(
                    effectID: .ef_sma2,
                    worldPosition: childWorldPos,
                    ownerObjectID: ownerID,
                    targetObjectID: ownerID,
                    extraParams: extra
                )
            )
        case 1:
            context.spawnChildEffect(
                EffectSpawnRequest(
                    effectID: .ef_sma3,
                    worldPosition: childWorldPos,
                    ownerObjectID: ownerID,
                    targetObjectID: ownerID
                )
            )
        case 99 where slot.process % 8 == 0:
            context.spawnChildEffect(
                EffectSpawnRequest(
                    effectID: .ef_sma_black2,
                    worldPosition: childWorldPos,
                    ownerObjectID: ownerID,
                    targetObjectID: ownerID,
                    extraParams: extra
                )
            )
        default:
            break
        }
    }

    // MARK: - PP_SMA2 (121)

    /// Motion update for `PP_SMA2` (121) rising pillar cylinder at 60Hz.
    func primSMA2() {
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            state.slots[index].rotStart += Int16(3 + index)
            if state.slots[index].rotStart > 359 {
                state.slots[index].rotStart -= 360
            }

            if process < state.duration - 40 {
                if process < 40 {
                    state.slots[index].alphaB = min(180, state.slots[index].alphaB + 5)
                }
            } else {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 5)
            }

            if state.deltaPos2.x > 50.0 {
                let limit = Int16(max(0, Int(200.0 - (state.deltaPos2.x - 50.0) * 5.0)))
                if limit < state.slots[index].alphaB {
                    state.slots[index].alphaB = limit
                }
            }

            for value in 0..<21 where state.slots[index].flag1[value] == 0 {
                let cap = EffectSpace.sine(degrees: value * 9) * state.slots[index].maxHeight
                if process < 91 {
                    state.slots[index].height[value] = cap * EffectSpace.sine(degrees: process)
                }
                if cap < state.slots[index].height[value] {
                    state.slots[index].height[value] = cap
                    state.slots[index].flag1[value] = 1
                }
                if state.slots[index].height[value] < 0 {
                    state.slots[index].height[value] = 0
                }
            }
        }
    }

    /// Geometry submission for `PP_SMA2` (121), rendering world-offset 20-segment rising energy cylinders.
    func renderSMA2(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for slot in state.slots where slot.life == 1 {
            let fullAngle = Int(slot.fullDisplayAngle)
            let basicAngle = fullAngle / 20
            guard basicAngle > 0 else {
                continue
            }

            let cosRise = EffectSpace.cosine(degrees: Int(slot.riseAngle))
            let sinRise = EffectSpace.sine(degrees: Int(slot.riseAngle))

            var prevBottom = SIMD3<Float>.zero
            var prevTop = SIMD3<Float>.zero
            var order = 0
            var count = 0

            while count <= fullAngle {
                var angle = (count + Int(slot.rotStart)) % 360
                if fullAngle == 360 && order == 20 {
                    angle = Int(slot.rotStart)
                }

                let cs1 = EffectSpace.cosine(degrees: angle)
                let sn1 = EffectSpace.sine(degrees: angle)
                let base = SIMD3<Float>(cs1 * slot.distance, 0, sn1 * slot.distance) + state.deltaPos

                let h = slot.height[order]
                let rx = cosRise * h
                let top = SIMD3<Float>(
                    base.x + cs1 * rx,
                    base.y - sinRise * h,
                    base.z + sn1 * rx
                )

                if order > 0 {
                    let u1 = Float(order - 1) / 21.0
                    let u2 = Float(order) / 21.0
                    let isBlack = slot.alphaT == 99
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: slot.alphaB,
                        v1: prevBottom,
                        v2: base,
                        v3: top,
                        v4: prevTop,
                        blendSelector: isBlack ? 99 : 0,
                        textureIndex: 0,
                        isWorldPosition: true,
                        red: isBlack ? 70 : 90,
                        green: isBlack ? 70 : 90,
                        blue: isBlack ? 70 : 255,
                        v1Coord: 0,
                        v2Coord: 1,
                        u1Coord: u1,
                        u2Coord: u2
                    )
                }

                order += 1
                if order >= 21 {
                    order = 20
                }
                prevBottom = base
                prevTop = top
                count += basicAngle
            }
        }
    }

    // MARK: - PP_TWILIGHT (123)

    /// Motion update for `PP_TWILIGHT` (123) gently drifting rotating panels at 60Hz.
    func primTwilight(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            if process < 50 {
                state.slots[index].alphaB += 5
            }
            if process > Int(state.slots[index].rotStart) {
                state.slots[index].alphaB -= 5
            }

            Self.driftSlotAngles(&state.slots[index], count: 2)

            state.slots[index].vecBNow.x += 0.1 * EffectSpace.sine(degrees: Int(state.slots[index].height[0]))
            state.slots[index].vecBNow.z += 0.1 * EffectSpace.sine(degrees: Int(state.slots[index].height[2]))

            state.slots[index].height[8] += 1.0
            if state.slots[index].height[8] >= 360.0 {
                state.slots[index].height[8] -= 360.0
            }

            state.slots[index].fullDisplayAngle += 1
            if state.slots[index].fullDisplayAngle >= 360 {
                state.slots[index].fullDisplayAngle -= 360
            }
        }
    }

    // MARK: - Shared Helpers

    private func resolvedOwnerFacingAngle(world: any EffectWorldContext) -> Float {
        let ownerID = master?.ownerObjectID ?? master?.targetObjectID
        return ownerID.flatMap { world.targetState(for: $0)?.facingAngle } ?? 0
    }

    private func resolvedOwnerHeadOffset(world: any EffectWorldContext) -> Float? {
        let ownerID = master?.ownerObjectID ?? master?.targetObjectID
        guard let targetState = ownerID.flatMap({ world.targetState(for: $0) }) else {
            return nil
        }
        return -targetState.effectHeadOffsetY
    }

    private func updateOrbitBubblePositions(slotIndex: Int, orbitRadius: Float) {
        let a0 = Int(state.slots[slotIndex].height[3])
        state.slots[slotIndex].vecBPre.x = EffectSpace.cosine(degrees: a0) * orbitRadius
        state.slots[slotIndex].vecBPre.z = EffectSpace.sine(degrees: a0) * orbitRadius

        let a1 = Int(state.slots[slotIndex].height[7])
        state.slots[slotIndex].vecBNow.x = EffectSpace.cosine(degrees: a1) * orbitRadius
        state.slots[slotIndex].vecBNow.z = EffectSpace.sine(degrees: a1) * orbitRadius

        let a2 = Int(state.slots[slotIndex].height[11])
        state.slots[slotIndex].vecTPre.x = EffectSpace.cosine(degrees: a2) * orbitRadius
        state.slots[slotIndex].vecTPre.z = EffectSpace.sine(degrees: a2) * orbitRadius

        let a3 = Int(state.slots[slotIndex].height[15])
        state.slots[slotIndex].vecTNow.x = EffectSpace.cosine(degrees: a3) * orbitRadius
        state.slots[slotIndex].vecTNow.z = EffectSpace.sine(degrees: a3) * orbitRadius
    }

    private func emitOrbitBubbleQuad(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?,
        corners: (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>),
        center: SIMD3<Float>,
        liftY: Float,
        alpha: Int16,
        textureIndex: Int,
        bubbleAngle: Float,
        rot0: Int16,
        red: UInt8,
        green: UInt8,
        blue: UInt8
    ) {
        let dif = Int(bubbleAngle - Float(rot0))
        let inFront = (dif < 70 && dif > -80) || dif < -270 || dif > 270
        let isPrimaryType = textureIndex == 0 || textureIndex == 2
        let normalWinding = isPrimaryType == inFront

        let c0 = (normalWinding ? corners.0 : corners.1) + center - SIMD3<Float>(0, liftY, 0)
        let c1 = (normalWinding ? corners.1 : corners.0) + center - SIMD3<Float>(0, liftY, 0)
        let c2 = (normalWinding ? corners.2 : corners.3) + center - SIMD3<Float>(0, liftY, 0)
        let c3 = (normalWinding ? corners.3 : corners.2) + center - SIMD3<Float>(0, liftY, 0)

        renderTeiRect(
            into: &collector,
            assets: assets,
            alpha: alpha,
            v1: c0,
            v2: c1,
            v3: c2,
            v4: c3,
            blendSelector: 0,
            textureIndex: textureIndex,
            isWorldPosition: false,
            red: red,
            green: green,
            blue: blue,
            extra: 2
        )
    }

    private func shiftSpecialTrailSlots(process: Int, firstDrop: Int16) {
        if process > 3 {
            copySpecialTrailSlot(from: 2, to: 3, alphaDrop: 25)
        }
        if process > 2 {
            copySpecialTrailSlot(from: 1, to: 2, alphaDrop: 25)
        }
        if process > 1 {
            copySpecialTrailSlot(from: 0, to: 1, alphaDrop: firstDrop)
        }
    }

    private func copySpecialTrailSlot(from source: Int, to destination: Int, alphaDrop: Int16) {
        state.slots[destination].fullDisplayAngle = state.slots[source].fullDisplayAngle
        state.slots[destination].distance = state.slots[source].distance
        state.slots[destination].height[8] = state.slots[source].height[8]
        state.slots[destination].alphaB = max(0, state.slots[source].alphaB - alphaDrop)
        state.slots[destination].vecBNow = state.slots[source].vecBNow
        state.slots[destination].flag1[0] = state.slots[source].flag1[0]
    }
}
