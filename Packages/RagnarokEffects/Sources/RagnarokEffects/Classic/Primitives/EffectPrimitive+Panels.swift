//
//  EffectPrimitive+Panels.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

import Foundation
import simd

extension EffectPrimitive {

    // MARK: - Primitive 26

    /// Motion update for primitive `26` rotating floor square with texture animation at 60Hz.
    func primFloorSpin26() {
        followMaster()

        if state.slots[0].height[4] == 14.0 {
            state.slots[0].rotStart -= 1
            if state.slots[0].rotStart < 0 {
                state.slots[0].rotStart += 360
            }
        } else {
            state.slots[0].rotStart += 1
            if state.slots[0].rotStart >= 360 {
                state.slots[0].rotStart -= 360
            }
        }

        advanceTextureFrame()
    }

    // MARK: - Primitive 28

    /// Motion update for primitive `28` twin pulsing floor squares with texture animation at 60Hz.
    func primFloorPulse28() {
        followMaster()

        for index in 0..<2 {
            state.slots[index].riseAngle += 3
            if state.slots[index].riseAngle >= 360 {
                state.slots[index].riseAngle -= 360
            }
        }

        advanceTextureFrame()
    }

    // MARK: - Primitive 32

    /// Motion update for primitive `32` orbiting layered-glow orbs at 60Hz.
    func primDriftingOrbs(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        if state.slots[0].process <= 200 {
            state.slots[0].alphaB += 1
        }

        Self.driftSlotAngles(&state.slots[0], count: 3)

        let flag0 = state.slots[0].flag1[0]
        if flag0 != 0 && flag0 < 20 {
            if flag0 >= 10 {
                let period = max(1, Int(flag0) - 9)
                switch state.isChangeProcessed {
                case 0:
                    if state.slots[0].process % period == 0 {
                        state.slots[0].height[6] += 1.0
                        if state.slots[0].height[6] >= 360.0 {
                            state.slots[0].height[6] -= 360.0
                        }
                    }
                    state.slots[0].distance = 6.0
                    state.slots[0].height[7] = -15.0
                case 1:
                    if state.slots[0].process % period == 0 {
                        state.slots[0].height[6] += 15.0
                        if state.slots[0].height[6] >= 360.0 {
                            state.slots[0].height[6] -= 360.0
                        }
                    }
                    state.slots[0].height[7] = max(-30.0, state.slots[0].height[7] - 0.1)
                    state.slots[0].distance = min(10.0, state.slots[0].distance + 0.02)
                default:
                    break
                }
            } else if state.slots[0].process % 2 == 0 {
                state.slots[0].height[6] += 1.0
                if state.slots[0].height[6] >= 360.0 {
                    state.slots[0].height[6] -= 360.0
                }
            }
        } else {
            state.slots[0].height[6] += 1.0
            if state.slots[0].height[6] >= 360.0 {
                state.slots[0].height[6] -= 360.0
            }
        }

        let wobbleScale: Float
        let orbitRadius: Float
        if state.slots[0].height[10] == 1.0 {
            wobbleScale = 0.7
            orbitRadius = 5.5
        } else {
            wobbleScale = (flag0 == 0 || flag0 >= 20) ? 1.0 : 0.5
            orbitRadius = 7.0
        }

        let h0 = EffectSpace.sine(degrees: Int(state.slots[0].height[0]))
        let h2 = EffectSpace.sine(degrees: Int(state.slots[0].height[2]))
        let h4 = EffectSpace.sine(degrees: Int(state.slots[0].height[4]))
        let orbitAngle = Int(state.slots[0].height[6])
        state.slots[0].vecBNow = SIMD3<Float>(
            h0 * wobbleScale + EffectSpace.sine(degrees: orbitAngle) * orbitRadius,
            h4 * wobbleScale + state.slots[0].height[7],
            h2 * wobbleScale + EffectSpace.cosine(degrees: orbitAngle) * orbitRadius
        )

        state.slots[0].height[8] += Float(Int.random(in: 0..<5) + 5)
        if state.slots[0].height[8] >= 360.0 {
            state.slots[0].height[8] -= 360.0
        }
    }

    /// Geometry submission for primitive `32`, rendering multi-layer camera-facing glow orbs.
    func renderLayeredGlow(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let slot = state.slots[0]
        guard slot.life == 1, slot.alphaB > 0 else {
            return
        }

        let rot0 = slot.alphaT
        let rot1 = state.slots[1].alphaT
        let alpha = slot.alphaB
        let drift = EffectSpace.sine(degrees: Int(slot.height[8])) * slot.distance * 0.05

        func emitLayer(scale: Float, layerAlpha: Int16, pw: Int16, r: UInt8, g: UInt8, b: UInt8) {
            let rx = slot.distance * scale + drift
            let corners = Self.facingSquareCorners(radius: rx, startAngle: 0, rot0: rot0, rot1: rot1)
            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: layerAlpha,
                v1: corners.0 + slot.vecBNow,
                v2: corners.1 + slot.vecBNow,
                v3: corners.2 + slot.vecBNow,
                v4: corners.3 + slot.vecBNow,
                blendSelector: pw,
                textureIndex: 0,
                isWorldPosition: false,
                red: r,
                green: g,
                blue: b
            )
        }

        if slot.flag1[0] == 21 {
            emitLayer(scale: 3.0, layerAlpha: alpha / 2, pw: 0, r: 0, g: 0, b: 255)
            emitLayer(scale: 1.7, layerAlpha: alpha, pw: 0, r: 0, g: 0, b: 255)
        } else if slot.flag1[0] == 20 {
            emitLayer(scale: 1.3, layerAlpha: alpha, pw: 0, r: 0, g: 0, b: 255)
        }

        let pw: Int16 = state.isChangeProcessed == 1 ? 0 : 10
        let midStyle: (pw: Int16, r: UInt8, g: UInt8, b: UInt8) = switch slot.flag1[0] {
        case 1: (0, 68, 42, 30)
        case 10: (pw, 255, 50, 50)
        case 11: (pw, 200, 200, 50)
        case 12: (pw, 50, 50, 255)
        case 13: (pw, 255, 255, 255)
        case 20, 21: (0, 40, 40, 255)
        default: (0, 0, 0, 255)
        }
        emitLayer(scale: 1.0, layerAlpha: alpha, pw: midStyle.pw, r: midStyle.r, g: midStyle.g, b: midStyle.b)

        let innerStyle: (r: UInt8, g: UInt8, b: UInt8) = switch slot.flag1[0] {
        case 1: (255, 255, 255)
        case 10: (255, 50, 50)
        case 11: (200, 200, 50)
        case 12: (50, 50, 255)
        case 13: (100, 150, 100)
        case 20: (150, 150, 255)
        case 21: (250, 250, 255)
        default: (255, 255, 0)
        }
        emitLayer(scale: 0.5, layerAlpha: alpha, pw: 0, r: innerStyle.r, g: innerStyle.g, b: innerStyle.b)
    }

    // MARK: - Primitive 33

    /// Motion update for primitive `33` drifting ambient field fireflies at 60Hz.
    func primFieldFireflies(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            let mode = state.slots[index].height[7]
            if mode < 99.0 {
                state.slots[index].process += 1
                let process = state.slots[index].process

                if state.slots[index].flag1[2] == 23 && process % 14 == 0 {
                    state.slots[index].flag1[0] += 1
                    if state.slots[index].flag1[0] > 5 {
                        state.slots[index].flag1[0] = 0
                    }
                }

                if mode == 0.0 {
                    if process < 80 && position.y < state.slots[index].height[6] {
                        state.slots[index].alphaB += 2
                    }
                } else if mode == 2.0 || mode == 5.0 {
                    if process < 80 {
                        state.slots[index].alphaB += 2
                    }
                } else if mode == 3.0 {
                    if process < 170 {
                        state.slots[index].alphaB += 1
                    }
                } else if mode == 11.0 || mode == 12.0 || mode == 13.0 || mode == 14.0 {
                    if process < 70 {
                        state.slots[index].alphaB += 1
                    }
                } else if process < 80 {
                    state.slots[index].alphaB += 3
                }

                if process > Int(state.slots[index].rotStart) {
                    state.slots[index].alphaB -= 1
                    if state.slots[index].alphaB <= 0 {
                        state.slots[index].process = 0
                        state.slots[index].alphaB = 0

                        let respawn = state.slots[index].height[7]
                        var offsetX: Float
                        var offsetZ: Float
                        if respawn == 0.0 {
                            if position.y > state.slots[index].height[6] {
                                state.slots[index].process = 300
                            }
                            offsetX = Float(Int.random(in: 0..<300) - 150)
                            offsetZ = Float(Int.random(in: 0..<300) - 150)
                        } else if respawn == 2.0 || respawn == 5.0 {
                            offsetX = Float(Int.random(in: 0..<300) - 150)
                            offsetZ = Float(Int.random(in: 0..<300) - 150)
                        } else if respawn == 3.0 {
                            offsetX = Float(Int.random(in: 0..<300) - 150)
                            offsetZ = Float(Int.random(in: 0..<300) - 150)
                            let sink = Float(Int.random(in: 0..<5))
                            let terrainY = context.world.terrainHeight(
                                atEffectX: position.x + offsetX,
                                effectZ: position.z + offsetZ
                            )
                            state.slots[index].vecBNow.y = terrainY - 20.0 - sink
                        } else {
                            offsetX = Float(Int.random(in: 0..<200) + 25)
                            offsetZ = Float(Int.random(in: 0..<200) + 25)
                            if Int.random(in: 0..<2) == 0 {
                                offsetX = -offsetX
                            }
                            if Int.random(in: 0..<2) == 0 {
                                offsetZ = -offsetZ
                            }
                        }

                        state.slots[index].vecBNow.x = position.x + offsetX
                        state.slots[index].vecBNow.z = position.z + offsetZ
                    }
                }

                Self.driftSlotAngles(&state.slots[index], count: 2)

                let sinX = EffectSpace.sine(degrees: Int(state.slots[index].height[0]))
                let sinZ = EffectSpace.sine(degrees: Int(state.slots[index].height[2]))
                let motion = state.slots[index].height[7]
                if motion == 3.0 {
                    state.slots[index].vecBNow.x += sinX * 0.015
                    state.slots[index].vecBNow.z += sinZ * 0.015
                } else if motion == 4.0 {
                    state.slots[index].vecBNow.x += abs(sinX) * 0.2
                    state.slots[index].vecBNow.z += sinZ * 0.05
                } else if motion == 5.0 {
                    state.slots[index].vecBNow.x += sinX * 0.035
                    state.slots[index].vecBNow.z += sinZ * 0.035
                } else {
                    state.slots[index].vecBNow.x += sinX * 0.05
                    state.slots[index].vecBNow.z += sinZ * 0.05
                }
            }

            state.slots[index].height[8] += 1.0
            if state.slots[index].height[8] >= 360.0 {
                state.slots[index].height[8] -= 360.0
            }
        }
    }

    // MARK: - Primitive 39

    /// Motion update for primitive `39` twin rotating pulsing floor squares at 60Hz.
    func primFloorSpin39() {
        followMaster()

        for index in 0..<2 where state.slots[index].life == 1 {
            let mode = state.slots[index].height[4]
            if mode == 4.0 {
                state.slots[index].rotStart += 6
                if state.slots[index].rotStart >= 360 {
                    state.slots[index].rotStart -= 360
                }
            } else if mode == 10.0 || mode == 11.0 || mode == 12.0 {
                state.slots[index].rotStart += 3
                if state.slots[index].rotStart >= 360 {
                    state.slots[index].rotStart -= 360
                }
            }

            if mode == 2.0 {
                state.slots[index].riseAngle += 1
            } else if mode == 10.0 {
                if state.slots[index].rotStart < 181 {
                    state.slots[index].distance -= 0.3
                } else {
                    state.slots[index].distance += 0.3
                }
            } else if mode != 11.0 && mode != 12.0 {
                state.slots[index].riseAngle += 3
            }

            if state.slots[index].riseAngle >= 360 {
                state.slots[index].riseAngle -= 360
            }
        }
    }

    // MARK: - PP_PARTICLE_UP (59)

    /// Motion update for `PP_PARTICLE_UP` (59) floating field particles at 60Hz.
    func primParticleUp(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        for index in 0..<4 {
            let flash = 36 - index * 7
            guard state.slots[index].life == 1 else {
                continue
            }

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
                state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            } else if process <= 10 {
                state.slots[index].alphaB += 15
            } else {
                if state.slots[index].flag1[1] == 1 {
                    if process == flash - 1 || process == flash {
                        state.slots[index].flag1[0] = 1
                    } else {
                        state.slots[index].flag1[0] = 0
                    }
                }

                state.slots[index].alphaB -= 3
                if state.slots[index].alphaB < 0 {
                    state.slots[index].alphaB = 0
                    state.slots[index].life = 0
                }
            }

            let rotStart = Int(state.slots[index].rotStart)
            state.slots[index].vecBNow.y -= state.slots[index].height[2]
            state.slots[index].vecBNow.x += state.slots[index].height[1] * EffectSpace.cosine(degrees: rotStart)
            state.slots[index].vecBNow.z += state.slots[index].height[1] * EffectSpace.sine(degrees: rotStart)
        }
    }

    // MARK: - Primitive 67

    /// Motion update for primitive `67` slow-fading floor square at 60Hz.
    func primFadeSquare67() {
        followMaster()
        state.slots[0].process += 1
        if state.slots[0].process > 0 {
            if state.slots[0].process % 2 > 0 {
                state.slots[0].alphaB -= 1
            }
            if state.slots[0].alphaB < 0 {
                state.slots[0].alphaB = 0
            }
        }
    }

    // MARK: - Primitive 79

    /// Motion update for primitive `79` scrolling column panels at 60Hz.
    func primScrollColumn() {
        for index in 0..<4 where state.slots[index].life > 0 {
            state.slots[index].process += 1
        }
    }

    /// Geometry submission for primitive `79`, rendering vertically scrolling tiled column panels.
    func renderScrollColumn(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            var frames = Int(slot.maxHeight)
            let cycle: Int
            var scroll: Float
            if frames == 0 {
                cycle = 0
                scroll = 40.0
                frames = 1
            } else {
                cycle = slot.process % (frames * 3)
                scroll = Float(slot.process % frames) * 40.0 / Float(frames)
            }

            let direction = slot.flag1[1]
            if direction == 1 || direction == 10 {
                scroll = 40.0 - scroll
            }

            let halfWidth = slot.distance * 0.5
            let left = -halfWidth
            let right = halfWidth
            let depth = slot.vecBNow.z
            let shift = cycle / frames

            for i in 0..<5 {
                if frames == 1 && i > 0 {
                    break
                }

                var top = scroll - slot.height[i]
                var bottom = scroll - slot.height[i + 1]
                if slot.flag1[2] > 10 {
                    let scale = 10.0 / Float(slot.flag1[2])
                    top *= scale
                    bottom *= scale
                }

                var v4 = SIMD3<Float>(left, top, depth)
                var v1 = SIMD3<Float>(left, bottom, depth)
                var v2 = SIMD3<Float>(right, bottom, depth)
                var v3 = SIMD3<Float>(right, top, depth)

                if slot.flag1[0] == 1 {
                    v4 = SIMD3<Float>(depth, top, left)
                    v1 = SIMD3<Float>(depth, bottom, left)
                    v2 = SIMD3<Float>(depth, bottom, right)
                    v3 = SIMD3<Float>(depth, top, right)
                }

                var textureIndex = i % 3
                if direction == 1 || direction == 10 {
                    textureIndex -= shift
                    while textureIndex < 0 {
                        textureIndex += 3
                    }
                } else {
                    textureIndex += shift
                    if textureIndex > 2 {
                        textureIndex -= 3
                    }
                }

                let (pw, r, g, b): (Int16, UInt8, UInt8, UInt8) = switch direction {
                case 1: (0, 55, 55, 255)
                case 10: (0, 255, 55, 255)
                default: (1, 255, 255, 255)
                }

                let v1Coord: Float
                let v2Coord: Float
                if i == 0 {
                    let cut = scroll * 0.025
                    top -= (top - bottom) * cut
                    v4.y = top
                    v3.y = top
                    v1Coord = cut
                    v2Coord = 1.0
                } else if i == 4 {
                    let cut = scroll * 0.025
                    bottom = (top - bottom) * (1.0 - cut) + bottom
                    v1.y = bottom
                    v2.y = bottom
                    v1Coord = 0.0
                    v2Coord = cut
                } else {
                    v1Coord = 0.0
                    v2Coord = 1.0
                }

                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: slot.alphaB,
                    v1: v1,
                    v2: v2,
                    v3: v3,
                    v4: v4,
                    blendSelector: pw,
                    textureIndex: textureIndex,
                    isWorldPosition: false,
                    red: r,
                    green: g,
                    blue: b,
                    v1Coord: v1Coord,
                    v2Coord: v2Coord
                )
            }
        }
    }

    // MARK: - Primitive 82

    /// Motion update for primitive `82` character aura glow billboards at 60Hz.
    func primAuraGlow(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        let process = state.slots[0].process
        let kind = state.slots[0].flag1[4]

        if process < 300 {
            if kind == 1 || kind == 3 {
                if process < 200 {
                    state.slots[0].alphaB = min(220, state.slots[0].alphaB + 10)
                } else {
                    state.slots[0].alphaB = max(0, state.slots[0].alphaB - 5)
                }
            } else if kind == 22 {
                state.slots[0].alphaB = min(220, state.slots[0].alphaB + 10)
            } else if kind == 0 {
                state.slots[0].alphaB += 1
            } else if kind == 20 {
                state.slots[0].alphaB = min(200, state.slots[0].alphaB + 5)
            } else if kind >= 16 && kind <= 18 {
                state.slots[0].alphaB = 100
            } else if kind >= 10 && kind <= 12 {
                state.slots[0].alphaB = 150
            } else if kind == 14 {
                state.slots[0].alphaB = 50
            } else if kind >= 10 {
                state.slots[0].alphaB = 250
            }
        }

        if kind == 2 {
            if process > 40 {
                let delta: Int16 = process >= 62 ? -8 : 8
                state.slots[0].alphaB += delta
                if state.slots[0].alphaB > 0 {
                    state.slots[0].distance += 0.7
                }
            }
            if process > 300 && state.slots[0].alphaB > 0 {
                state.slots[0].alphaB -= 1
            }
        } else if kind == 16 || kind == 17 {
            if (process & 1) == 0 {
                state.slots[0].fullDisplayAngle -= 1
            }
            if state.slots[0].fullDisplayAngle < 0 {
                state.slots[0].fullDisplayAngle += 360
            }
        } else if kind < 20 {
            if kind == 18 {
                if state.slots[0].fullDisplayAngle < 0 {
                    state.slots[0].fullDisplayAngle += 360
                }
            } else if kind == 10 || kind >= 13 {
                if (process & 1) == 0 {
                    state.slots[0].fullDisplayAngle += 1
                }
                if state.slots[0].fullDisplayAngle >= 360 {
                    state.slots[0].fullDisplayAngle -= 360
                }
            } else if kind == 11 || kind == 12 {
                if (process & 1) == 0 {
                    state.slots[0].fullDisplayAngle -= 1
                }
                if state.slots[0].fullDisplayAngle < 0 {
                    state.slots[0].fullDisplayAngle += 360
                }
            } else if process > 300 && state.slots[0].alphaB > 0 {
                state.slots[0].alphaB -= 1
            }
        }

        state.slots[0].alphaB = max(0, min(255, state.slots[0].alphaB))

        if kind < 30 {
            state.slots[0].height[8] += 2.0
        }
        if state.slots[0].height[8] >= 360.0 {
            state.slots[0].height[8] -= 360.0
        }

        state.slots[0].vecBNow = SIMD3<Float>(position.x, position.y - state.slots[0].height[15], position.z)
    }

    // MARK: - Primitive 87

    /// Motion update for primitive `87` swirling trailing impact billboards at 60Hz.
    func primBubbleSwirl(context: EffectTickContext) {
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
            copySwirlTrail(from: 2, to: 3, alphaDrop: 25)
        }
        if process > 2 {
            copySwirlTrail(from: 1, to: 2, alphaDrop: 25)
        }
        if process > 1 {
            copySwirlTrail(from: 0, to: 1, alphaDrop: 100)
        }

        if process <= 10 {
            state.slots[0].alphaB += 20
        }

        if state.slots[0].flag1[4] == 4 {
            state.slots[0].fullDisplayAngle -= 15
            if state.slots[0].fullDisplayAngle < 0 {
                state.slots[0].fullDisplayAngle += 360
            }
            state.slots[0].vecBPre.y += state.slots[0].height[1]
            state.slots[0].vecBNow = position + state.slots[0].vecBPre

            if state.slots[0].vecBPre.y >= -60.0,
               state.slots[0].fullDisplayAngle >= 250,
               state.slots[0].fullDisplayAngle <= 280 {
                state.slots[0].flag1[4] = 0
                context.world.shakeCamera(amplitude: 3.0, duration: 0.25, frequency: 30.0)
            }
        } else if process <= 32 {
            if state.slots[0].flag1[4] == 0 || process <= 24 {
                state.slots[0].fullDisplayAngle -= 15
                if state.slots[0].fullDisplayAngle < 0 {
                    state.slots[0].fullDisplayAngle += 360
                }
                state.slots[0].vecBPre.y += state.slots[0].height[1]
            }
            state.slots[0].vecBNow = position + state.slots[0].vecBPre
        } else {
            if state.slots[0].flag1[4] == 0 && process == 33 {
                context.world.shakeCamera(amplitude: 3.0, duration: 0.25, frequency: 30.0)
            }
            state.slots[0].alphaB = max(0, state.slots[0].alphaB - 5)
        }
    }

    // MARK: - Primitive 88

    /// Motion update for primitive `88` expanding floor square following master at 60Hz.
    func primGrowFollow() {
        followMaster()

        for index in 0..<4 where state.slots[index].life > 0 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            if process <= 10 {
                state.slots[index].alphaB += state.size == 113.0 ? 6 : 2
            }

            state.slots[index].distance *= 1.07

            if process > 10 {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 1)
            }
        }
    }

    // MARK: - PP_EFFECTTEXTURE2 (95)

    /// Motion update for `PP_EFFECTTEXTURE2` (95) fading billboard panel at 60Hz.
    func primEffectTexture2(context: EffectTickContext) {
        faceCamera(world: context.world)

        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        if state.slots[0].height[8] >= 360.0 {
            state.slots[0].height[8] -= 360.0
        }

        if state.slots[0].process <= 30 {
            state.slots[0].alphaB = min(255, state.slots[0].alphaB + 10)
        } else {
            state.slots[0].alphaB = max(0, state.slots[0].alphaB - 3)
        }

        state.slots[0].vecBNow.y = state.slots[0].vecBPre.y
    }

    // MARK: - PP_EFFECTTEXTURE_ANI (128)

    /// Motion update for `PP_EFFECTTEXTURE_ANI` (128) animated billboard panel at 60Hz.
    func primEffectTextureAni(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        let frameTicks = state.slots[0].flag1[4] == 0 ? 8 : 6
        let totalFrames = max(1, state.texturePaths.isEmpty ? state.totalTexture : state.texturePaths.count)

        if state.slots[0].process % frameTicks == 0 {
            let next = Int(UInt8(bitPattern: state.slots[0].flag1[0])) + 1
            state.slots[0].flag1[0] = next >= totalFrames ? 0 : Int8(clamping: next)
        }

        state.slots[0].alphaB = max(0, min(255, state.slots[0].alphaB))
        state.slots[0].vecBNow = SIMD3<Float>(position.x, state.slots[0].vecBPre.y, position.z)
    }

    // MARK: - Primitive 129

    /// Motion update for primitive `129` bobbing ring beams at 60Hz.
    func primBobbing() {
        for index in 0..<4 where state.slots[index].life > 0 {
            let process = state.slots[index].process + 1
            state.slots[index].process = process

            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            if state.slots[index].flag1[0] == 11 {
                if process <= 40 {
                    state.slots[index].alphaB += 1
                } else if process > 140 {
                    state.slots[index].alphaB -= 1
                }
                if state.slots[index].alphaB <= 0 {
                    state.slots[index].alphaB = 0
                }
            }

            state.slots[index].maxHeight = EffectSpace.sine(degrees: process % 360) * 0.1 + state.slots[index].height[0]
        }
    }

    /// Geometry submission for primitive `129`, rendering 10-segment tapered rings between `vecTNow` and `vecTPre`.
    func renderBobbingRing(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let radius = slot.maxHeight
            let outerRadius = radius * 4.0
            var prevB = SIMD3<Float>.zero
            var prevT = SIMD3<Float>.zero

            for step in 0...10 {
                let angle = ((Int(slot.rotStart) + 36 * step) % 360 + 360) % 360
                let cs = EffectSpace.cosine(degrees: angle)
                let sn = EffectSpace.sine(degrees: angle)

                let curB = SIMD3<Float>(
                    cs * outerRadius + slot.vecTNow.x,
                    slot.vecTNow.y,
                    sn * outerRadius + slot.vecTNow.z
                )
                let curT = SIMD3<Float>(
                    cs * radius + slot.vecTPre.x,
                    slot.vecTPre.y,
                    sn * radius + slot.vecTPre.z
                )

                if step != 0 {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        alpha: slot.alphaB,
                        v1: prevB,
                        v2: curB,
                        v3: curT,
                        v4: prevT,
                        blendSelector: 0,
                        textureIndex: 0,
                        isWorldPosition: true,
                        red: 230,
                        green: 255,
                        blue: 230
                    )
                }

                prevB = curB
                prevT = curT
            }
        }
    }

    // MARK: - Primitive 130

    /// Motion update for primitive `130` drifting camera-facing squares at 60Hz.
    func primDriftingSquares(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        for ec in 0..<4 {
            var speed: Float = 0.05
            state.slots[ec].process += 1
            guard state.slots[ec].life == 1 else {
                continue
            }

            if state.slots[ec].flag1[11] < 120 {
                state.slots[ec].flag1[11] += 1
            }

            let mode = state.slots[ec].flag1[0]
            if mode == 1 {
                speed = 0.03
            } else {
                if state.slots[ec].flag1[12] < 120 {
                    state.slots[ec].flag1[12] += 1
                }
                if state.slots[ec].flag1[13] < 120 {
                    state.slots[ec].flag1[13] += 1
                }
                if state.slots[ec].flag1[14] < 120 {
                    state.slots[ec].flag1[14] += 1
                }
            }

            Self.driftSlotAngles(&state.slots[ec], count: 8, rise: 3.0, fall: 2.0)

            if mode == 1 {
                state.slots[ec].vecBPre.y += EffectSpace.sine(degrees: Int(state.slots[ec].height[0])) * speed
            } else {
                state.slots[ec].vecBPre.x += EffectSpace.sine(degrees: Int(state.slots[ec].height[0])) * speed
                state.slots[ec].vecBPre.z += EffectSpace.sine(degrees: Int(state.slots[ec].height[2])) * speed
            }

            let reach0 = max(abs(Int(state.slots[ec].vecBPre.x)), abs(Int(state.slots[ec].vecBPre.z)))
            if (mode == 1 && state.slots[ec].process > 3000) || reach0 >= 30 {
                state.slots[ec].flag1[11] &-= 2
                if state.slots[ec].flag1[11] <= 1 {
                    if mode == 1 {
                        state.slots[ec].process = 0
                        state.slots[ec].vecBPre = .zero
                    } else {
                        state.slots[ec].vecBPre.x = Float(Int.random(in: 0..<31) - 15)
                        state.slots[ec].vecBPre.z = Float(Int.random(in: 0..<31) - 15)
                    }
                }
            } else {
                Self.tickBlinkFlag(
                    in: &state.slots[ec],
                    alphaIndex: 11,
                    phaseIndex: 7,
                    triggerChance: mode == 1 ? 20 : 125
                )
            }

            if mode == 1 {
                return
            }

            state.slots[ec].vecBNow.x -= speed * EffectSpace.sine(degrees: Int(state.slots[ec].height[4]))
            state.slots[ec].vecBNow.z -= speed * EffectSpace.sine(degrees: Int(state.slots[ec].height[6]))
            Self.updateDriftingSubQuad(
                in: &state.slots[ec],
                positionKeyPath: \.vecBNow,
                alphaIndex: 12,
                phaseIndex: 8,
                reachThreshold: 30,
                inclusiveThreshold: true
            )

            state.slots[ec].vecTPre.x += speed * EffectSpace.sine(degrees: Int(state.slots[ec].height[8]))
            state.slots[ec].vecTPre.z -= speed * EffectSpace.sine(degrees: Int(state.slots[ec].height[10]))
            Self.updateDriftingSubQuad(
                in: &state.slots[ec],
                positionKeyPath: \.vecTPre,
                alphaIndex: 13,
                phaseIndex: 9,
                reachThreshold: 30,
                inclusiveThreshold: false
            )

            state.slots[ec].vecTNow.x -= speed * EffectSpace.sine(degrees: Int(state.slots[ec].height[12]))
            state.slots[ec].vecTNow.z += speed * EffectSpace.sine(degrees: Int(state.slots[ec].height[14]))
            Self.updateDriftingSubQuad(
                in: &state.slots[ec],
                positionKeyPath: \.vecTNow,
                alphaIndex: 14,
                phaseIndex: 10,
                reachThreshold: 30,
                inclusiveThreshold: false
            )
        }
    }

    /// Geometry submission for primitive `130`, rendering 4 camera-facing drifting quads per slot.
    func renderFacingQuads(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1 else {
                continue
            }

            let corners = Self.facingSquareCorners(radius: slot.distance, rot0: rot0, rot1: rot1)
            let (red, green, blue): (UInt8, UInt8, UInt8) = switch slot.flag1[5] {
            case 7: (250, 70, 100)
            case 8: (250, 250, 10)
            case 10: (250, 250, 250)
            default: (70, 120, 100)
            }

            let points: [(SIMD3<Float>, Int8)] = [
                (slot.vecBPre, slot.flag1[11]),
                (slot.vecBNow, slot.flag1[12]),
                (slot.vecTPre, slot.flag1[13]),
                (slot.vecTNow, slot.flag1[14]),
            ]

            for (center, rawAlpha) in points {
                let alpha = Int16(max(0, Int(rawAlpha) * 2))
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: alpha,
                    v1: corners.0 + center,
                    v2: corners.1 + center,
                    v3: corners.2 + center,
                    v4: corners.3 + center,
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

    // MARK: - Primitive 132

    /// Motion update for primitive `132` pulsing colored vertical panels at 60Hz.
    func primColorPanel() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            guard state.slots[index].process > 0 else {
                continue
            }

            state.slots[index].fullDisplayAngle += 1
            if state.slots[index].fullDisplayAngle > 359 {
                state.slots[index].fullDisplayAngle -= 360
            }

            state.slots[index].maxHeight *= 1.02
            if state.slots[index].maxHeight > 20.0 {
                state.slots[index].alphaB -= 3
                if state.slots[index].alphaB < 1 {
                    if state.slots[index].height[5] < 2.0 {
                        state.slots[index].maxHeight = 10.0
                        state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
                        state.slots[index].alphaB = 200
                    } else if state.slots[index].process > 300 {
                        state.slots[index].alphaB = 0
                        state.slots[index].life = 0
                    } else {
                        state.slots[index].maxHeight = 10.0
                        state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
                        state.slots[index].alphaB = 100
                    }
                }
            }

            let angle = Int(state.slots[index].fullDisplayAngle)
            let maxHeight = state.slots[index].maxHeight
            state.slots[index].height[2] = max(0, maxHeight * EffectSpace.sine(degrees: angle) * 0.1 + maxHeight * 0.9)
        }
    }

    /// Geometry submission for primitive `132`, rendering tinted vertical panels by mode and level.
    func renderColorPanel(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0, slot.process > 0 else {
                continue
            }

            let angle = ((Int(slot.rotStart) % 360) + 360) % 360
            let opposite = angle >= 180 ? angle - 180 : angle + 180
            let size = slot.height[2]
            let half = size * 0.5

            let bPre = SIMD3<Float>(
                half * EffectSpace.cosine(degrees: angle),
                half - slot.height[4],
                half * EffectSpace.sine(degrees: angle)
            )
            let bNow = SIMD3<Float>(
                half * EffectSpace.cosine(degrees: opposite),
                bPre.y,
                half * EffectSpace.sine(degrees: opposite)
            )

            guard size > 0 else {
                continue
            }

            let vec3 = SIMD3<Float>(bNow.x, bNow.y - size, bNow.z)
            let vec4 = SIMD3<Float>(bPre.x, bPre.y - size, bPre.z)

            let shade: UInt8 = switch slot.height[3] {
            case 0.0: 105
            case 1.0: 5
            case 2.0: 55
            case 3.0: slot.height[5] == 8.0 ? 255 : 155
            default: 105
            }

            let (red, green, blue, extra): (UInt8, UInt8, UInt8, Int8) = switch slot.height[5] {
            case 2.0: (shade, 255, shade, 1)
            case 3.0: (shade, shade, 255, 1)
            case 4.0: (255, 255, shade, 1)
            case 5.0: (255, shade, shade, 1)
            case 6.0: (255, shade, 255, 1)
            case 7.0: (shade, 255, 255, 1)
            case 8.0: (shade, shade, shade, 1)
            default: (shade, shade, 255, 0)
            }

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: bPre,
                v2: bNow,
                v3: vec3,
                v4: vec4,
                blendSelector: 0,
                textureIndex: 0,
                isWorldPosition: false,
                red: red,
                green: green,
                blue: blue,
                extra: extra
            )
        }
    }

    // MARK: - Primitive 138

    /// Motion update for primitive `138` orbiting spirit sphere (`PrimCHOOKGI`) at 60Hz.
    func primChookgi(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        if state.slots[0].process <= 100 {
            state.slots[0].alphaB = min(255, state.slots[0].alphaB + 2)
        }

        Self.driftSlotAngles(&state.slots[0], count: 3)

        let flag0 = state.slots[0].flag1[0]
        if flag0 == 0 {
            state.slots[0].height[6] += 1.0
        } else if flag0 >= 10 {
            let period = max(1, Int(flag0) - 9)
            if state.slots[0].process % period == 0 {
                state.slots[0].height[6] += 1.0
            }
        } else if state.slots[0].process % 2 == 0 {
            state.slots[0].height[6] += 1.0
        }
        if state.slots[0].height[6] >= 360.0 {
            state.slots[0].height[6] -= 360.0
        }

        let wobbleScale: Float
        let orbitRadius: Float
        if state.slots[0].height[10] == 1.0 {
            wobbleScale = 0.7
            orbitRadius = 5.5
        } else {
            wobbleScale = flag0 == 0 ? 1.0 : 0.5
            orbitRadius = 7.0
        }

        let h0 = EffectSpace.sine(degrees: Int(state.slots[0].height[0]))
        let h2 = EffectSpace.sine(degrees: Int(state.slots[0].height[2]))
        let h4 = EffectSpace.sine(degrees: Int(state.slots[0].height[4]))
        let orbitAngle = Int(state.slots[0].height[6])

        state.slots[0].vecBNow = SIMD3<Float>(
            wobbleScale * h0 + orbitRadius * EffectSpace.sine(degrees: orbitAngle),
            wobbleScale * h4 + state.slots[0].height[7],
            wobbleScale * h2 + orbitRadius * EffectSpace.cosine(degrees: orbitAngle)
        )

        state.slots[0].height[8] += Float(5 + Int.random(in: 0..<5))
        if state.slots[0].height[8] >= 360.0 {
            state.slots[0].height[8] -= 360.0
        }
    }

    /// Geometry submission for primitive `138`, rendering twin pulsing camera-facing squares.
    func renderTwinFacingSquares(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let slot = state.slots[0]
        guard slot.life == 1, slot.alphaB > 0 else {
            return
        }

        let rot0 = slot.alphaT
        let rot1 = state.slots[1].alphaT
        let wobble = slot.distance * EffectSpace.sine(degrees: Int(slot.height[8])) * 0.05
        let spinAngle = (slot.process * 2) % 360

        let innerRadius = wobble + slot.distance
        let pulse = (slot.process * 5) % 90
        let outerRadius = wobble + (EffectSpace.sine(degrees: pulse) * 2.0 + 1.0) * slot.distance

        let innerStyle: (pw: Int16, tex: Int, r: UInt8, g: UInt8, b: UInt8) = switch slot.flag1[0] {
        case 10: (1, 0, 255, 255, 255)
        case 11: (0, 0, 200, 200, 50)
        case 12: (0, 0, 50, 50, 255)
        case 13: (0, 0, 100, 150, 100)
        default: (0, 0, 0, 0, 255)
        }

        let outerStyle: (pw: Int16, tex: Int, r: UInt8, g: UInt8, b: UInt8) = switch slot.flag1[0] {
        case 10: (0, 1, 255, 20, 20)
        case 11: (0, 0, 200, 200, 50)
        case 12: (0, 0, 50, 50, 255)
        case 13: (0, 0, 100, 150, 100)
        default: (0, 0, 255, 255, 0)
        }

        for (radius, style) in [(innerRadius, innerStyle), (outerRadius, outerStyle)] {
            let corners = Self.facingSquareCorners(radius: radius, startAngle: spinAngle, rot0: rot0, rot1: rot1)
            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: corners.0 + slot.vecBNow,
                v2: corners.1 + slot.vecBNow,
                v3: corners.2 + slot.vecBNow,
                v4: corners.3 + slot.vecBNow,
                blendSelector: style.pw,
                textureIndex: style.tex,
                isWorldPosition: false,
                red: style.r,
                green: style.g,
                blue: style.b
            )
        }
    }

    // MARK: - Primitive 140

    /// Motion update for primitive `140` frame-by-frame fading billboard slots at 60Hz.
    func primFrameFade(context: EffectTickContext) {
        faceCamera(world: context.world)

        let frames = max(1, state.totalTexture)
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            if state.slots[index].process % 3 == 0 {
                let nextFrame = Int(state.slots[index].flag1[0]) + 1
                if nextFrame >= frames {
                    state.slots[index].flag1[0] = Int8(clamping: frames - 1)
                    state.slots[index].alphaB -= 15
                } else {
                    state.slots[index].flag1[0] = Int8(clamping: nextFrame)
                }
            }

            state.slots[index].alphaB = max(0, min(255, state.slots[index].alphaB))
        }
    }

    /// Geometry submission for camera-facing slot panels (`140` and shared callers).
    func renderTeiFacingSlots(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let radius = slot.distance * EffectSpace.sine(degrees: Int(slot.height[8])) * 0.05 + slot.distance
            var (vec1, vec2, vec3, vec4) = Self.polygonCorners(
                radius: radius,
                startAngle: Int(slot.fullDisplayAngle),
                shape: slot.height[10]
            )

            let kind = slot.flag1[2]
            if kind == 3 {
                let shift = SIMD3<Float>(3.1, 0, 6.0)
                vec1 += shift
                vec2 += shift
                vec3 += shift
                vec4 += shift
            } else if kind >= 17 && kind <= 31 {
                let shift = SIMD3<Float>(0, 0, 6.0)
                vec1 += shift
                vec2 += shift
                vec3 += shift
                vec4 += shift
            }

            Self.towardScreen(&vec1, &vec2, &vec3, &vec4, rot0: rot0, rot1: rot1)

            vec1 += slot.vecBNow
            vec2 += slot.vecBNow
            vec3 += slot.vecBNow
            vec4 += slot.vecBNow

            let textureIndex = Int(UInt8(bitPattern: slot.flag1[0]))
            let alpha = slot.alphaB

            func submitReversed(pw: Int16 = 0, r: UInt8, g: UInt8, b: UInt8, extra: Int8 = 0) {
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: alpha,
                    v1: vec2,
                    v2: vec1,
                    v3: vec4,
                    v4: vec3,
                    blendSelector: pw,
                    textureIndex: textureIndex,
                    isWorldPosition: true,
                    red: r,
                    green: g,
                    blue: b,
                    extra: extra
                )
            }

            switch kind {
            case 0, 3:
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: alpha,
                    v1: vec1,
                    v2: vec2,
                    v3: vec3,
                    v4: vec4,
                    blendSelector: 1,
                    textureIndex: textureIndex,
                    isWorldPosition: true,
                    red: 255,
                    green: 255,
                    blue: 255
                )
            case 2:
                submitReversed(r: 130, g: 130, b: 250)
                fallthrough
            case 4:
                submitReversed(r: 255, g: 255, b: 255)
                fallthrough
            case 5:
                submitReversed(r: 125, g: 255, b: 125)
                fallthrough
            case 10:
                submitReversed(r: 150, g: 150, b: 150)
                fallthrough
            case 12:
                submitReversed(r: 50, g: 50, b: 50)
                fallthrough
            case 15:
                submitReversed(r: 51, g: 153, b: 153)
            case 16:
                submitReversed(pw: 1, r: 255, g: 255, b: 255, extra: 3)
            case 17:
                submitReversed(r: 255, g: 255, b: 255)
            case 18:
                submitReversed(r: 5, g: 5, b: 255)
                submitReversed(r: 155, g: 155, b: 255)
            case 19:
                submitReversed(r: 5, g: 255, b: 5)
                submitReversed(r: 155, g: 255, b: 155)
            case 20:
                submitReversed(r: 255, g: 5, b: 5)
                submitReversed(r: 255, g: 155, b: 155)
            case 32:
                submitReversed(r: 255, g: 5, b: 5)
            default:
                break
            }
        }
    }

    // MARK: - Primitive 142

    /// Motion update for primitive `142` waterfall standing panels at 60Hz.
    func primWaterFall() {
        for index in 0..<4 where state.slots[index].life > 0 {
            state.slots[index].process += 1
        }
    }

    /// Geometry submission for primitive `142`, emitting 4 animated waterfall/bubble standing panels per slot.
    func renderStandingPanels(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let dist = slot.distance
            let angle = Int(slot.rotStart)
            let cs = EffectSpace.cosine(degrees: angle)
            let sn = EffectSpace.sine(degrees: angle)
            let frame = slot.process % 30

            func rotated(_ x: Float, _ y: Float, _ z: Float) -> SIMD3<Float> {
                SIMD3<Float>(cs * x - sn * z, y, sn * x + cs * z)
            }

            let halfWidth = dist * 0.5
            let splashHalfWidth = dist * 0.47

            // Top crest panel (textures 87...116)
            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: rotated(halfWidth, -dist * 2.0, 0),
                v2: rotated(-halfWidth, -dist * 2.0, 0),
                v3: rotated(-halfWidth, -dist * 2.0, dist),
                v4: rotated(halfWidth, -dist * 2.0, dist),
                blendSelector: 1,
                textureIndex: frame + 87,
                isWorldPosition: false,
                red: 255,
                green: 255,
                blue: 255
            )

            // Lower fall panel (textures 0...29)
            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: rotated(halfWidth, 0, 0),
                v2: rotated(-halfWidth, 0, 0),
                v3: rotated(-halfWidth, -dist, 0),
                v4: rotated(halfWidth, -dist, 0),
                blendSelector: 1,
                textureIndex: frame,
                isWorldPosition: false,
                red: 255,
                green: 255,
                blue: 255
            )

            // Upper fall panel (textures 30...59)
            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: rotated(halfWidth, -dist, 0),
                v2: rotated(-halfWidth, -dist, 0),
                v3: rotated(-halfWidth, -dist * 2.0, 0),
                v4: rotated(halfWidth, -dist * 2.0, 0),
                blendSelector: 1,
                textureIndex: frame + 30,
                isWorldPosition: false,
                red: 255,
                green: 255,
                blue: 255
            )

            // Base splash panel (textures 60...86)
            let bubbleFrame = slot.process % 27
            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: rotated(splashHalfWidth, 0, -1.0),
                v2: rotated(-splashHalfWidth, 0, -1.0),
                v3: rotated(-splashHalfWidth, -dist * 0.6, -1.0),
                v4: rotated(splashHalfWidth, -dist * 0.6, -1.0),
                blendSelector: 1,
                textureIndex: bubbleFrame + 60,
                isWorldPosition: false,
                red: 255,
                green: 255,
                blue: 255
            )
        }
    }

    // MARK: - Primitive 145

    /// Motion update for primitive `145` drifting orb with vertical spark pillars at 60Hz.
    func primDriftingSparks(context: EffectTickContext) {
        faceCamera(world: context.world)
        followMaster()

        guard state.slots[0].life == 1 else {
            return
        }

        state.slots[0].process += 1
        if state.slots[0].process <= 200 {
            state.slots[0].alphaB += 1
        }

        Self.driftSlotAngles(&state.slots[0], count: 3)

        if (state.slots[0].process & 1) == 0 {
            state.slots[0].height[6] += 1.0
            if state.slots[0].height[6] >= 360.0 {
                state.slots[0].height[6] -= 360.0
            }
        }

        let wobbleScale: Float = state.slots[0].flag1[0] == 0 ? 1.0 : 0.5
        let orbitAngle = Int(state.slots[0].height[6])
        state.slots[0].vecBNow = SIMD3<Float>(
            EffectSpace.sine(degrees: Int(state.slots[0].height[0])) * wobbleScale + EffectSpace.sine(degrees: orbitAngle) * 7.0,
            EffectSpace.sine(degrees: Int(state.slots[0].height[4])) * wobbleScale + state.slots[0].height[7],
            EffectSpace.sine(degrees: Int(state.slots[0].height[2])) * wobbleScale + EffectSpace.cosine(degrees: orbitAngle) * 7.0
        )

        state.slots[0].height[8] += Float(Int.random(in: 0..<5) + 5)
        if state.slots[0].height[8] >= 360.0 {
            state.slots[0].height[8] -= 360.0
        }

        for index in 0..<4 {
            if index != 0 {
                state.slots[index].process += 1
            }
            guard state.slots[index].process > 0 else {
                continue
            }

            state.slots[index].fullDisplayAngle += 1
            if state.slots[index].fullDisplayAngle >= 360 {
                state.slots[index].fullDisplayAngle -= 360
            }

            state.slots[index].maxHeight *= 1.02
            if state.slots[index].maxHeight > 6.0 {
                state.slots[index].riseAngle -= 3
                if state.slots[index].riseAngle <= 0 {
                    state.slots[index].maxHeight = 3.0
                    state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
                    state.slots[index].riseAngle = 200
                }
            }

            let angle = Int(state.slots[index].fullDisplayAngle)
            let maxHeight = state.slots[index].maxHeight
            state.slots[index].height[12] = max(0, maxHeight * EffectSpace.sine(degrees: angle) * 0.1 + maxHeight * 0.9)
        }
    }

    /// Geometry submission for primitive `145`, rendering dual core billboards and 4 vertical pillar quads.
    func renderPillarSquares(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let primary = state.slots[0]
        guard primary.life == 1, primary.alphaB > 0 else {
            return
        }

        let rot0 = primary.alphaT
        let rot1 = state.slots[1].alphaT
        let wobble = primary.distance * EffectSpace.sine(degrees: Int(primary.height[8])) * 0.05

        let coreLayers: [(radius: Float, r: UInt8, g: UInt8, b: UInt8)] = [
            (wobble + primary.distance, 68, 42, 255),
            (wobble + primary.distance * 0.5, 155, 155, 255),
        ]

        for layer in coreLayers {
            let corners = Self.facingSquareCorners(radius: layer.radius, startAngle: 0, rot0: rot0, rot1: rot1)
            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: primary.alphaB,
                v1: corners.0 + primary.vecBNow,
                v2: corners.1 + primary.vecBNow,
                v3: corners.2 + primary.vecBNow,
                v4: corners.3 + primary.vecBNow,
                blendSelector: 0,
                textureIndex: 0,
                isWorldPosition: false,
                red: layer.r,
                green: layer.g,
                blue: layer.b
            )
        }

        let shades: [UInt8] = [105, 35, 75, 5]
        for index in 0..<4 {
            let angle = ((Int(state.slots[index].rotStart) % 360) + 360) % 360
            let opposite = angle < 180 ? angle + 180 : angle - 180
            let pillarHeight = state.slots[index].height[12]
            let half = pillarHeight * 0.5

            let tPre = SIMD3<Float>(
                EffectSpace.cosine(degrees: angle) * half,
                half,
                EffectSpace.sine(degrees: angle) * half
            ) + primary.vecBNow
            let tNow = SIMD3<Float>(
                EffectSpace.cosine(degrees: opposite) * half,
                half,
                EffectSpace.sine(degrees: opposite) * half
            ) + primary.vecBNow

            guard pillarHeight > 0 else {
                continue
            }

            let lowNow = SIMD3<Float>(tNow.x, tNow.y - pillarHeight, tNow.z)
            let lowPre = SIMD3<Float>(tPre.x, tPre.y - pillarHeight, tPre.z)
            let shade = shades[index]

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: state.slots[index].riseAngle,
                v1: tPre,
                v2: tNow,
                v3: lowNow,
                v4: lowPre,
                blendSelector: 0,
                textureIndex: 1,
                isWorldPosition: false,
                red: shade,
                green: shade,
                blue: 255
            )
        }
    }

    // MARK: - Primitive 150

    /// Motion update for primitive `150` rising/hovering petal particles at 60Hz.
    func primFallingPetals2(context: EffectTickContext) {
        faceCamera(world: context.world)

        for index in 0..<4 where state.slots[index].life == 1 {
            let angle = state.slots[index].fullDisplayAngle
            let scale = Float(state.slots[index].riseAngle) / 10.0
            let riseStep = state.slots[index].maxHeight
            let narrowFirst = state.slots[index].flag1[12] != 0

            Self.driftSlotAngles(&state.slots[index], count: 8)

            if state.slots[index].vecBPre.y < 0 {
                state.slots[index].vecBPre.x += EffectSpace.sine(degrees: Int(state.slots[index].height[0])) * 0.01
                state.slots[index].vecBPre.z += EffectSpace.sine(degrees: Int(state.slots[index].height[2])) * 0.01
                if state.slots[index].vecBPre.y < scale * -8.0 {
                    Self.respawnRotatedPoint(&state.slots[index].vecBPre, scale: scale, narrow: narrowFirst, angle: angle)
                }
            }
            state.slots[index].vecBPre.y -= riseStep

            if state.slots[index].vecBNow.y < 0 {
                state.slots[index].vecBNow.x -= EffectSpace.sine(degrees: Int(state.slots[index].height[4])) * 0.01
                state.slots[index].vecBNow.z -= EffectSpace.sine(degrees: Int(state.slots[index].height[6])) * 0.01
                if state.slots[index].vecBNow.y < scale * -8.0 {
                    Self.respawnRotatedPoint(&state.slots[index].vecBNow, scale: scale, narrow: false, angle: angle)
                }
            }
            state.slots[index].vecBNow.y -= riseStep

            if state.slots[index].vecTPre.y < 0 {
                state.slots[index].vecTPre.x += EffectSpace.sine(degrees: Int(state.slots[index].height[8])) * 0.01
                state.slots[index].vecTPre.z -= EffectSpace.sine(degrees: Int(state.slots[index].height[10])) * 0.01
                if state.slots[index].vecTPre.y < scale * -8.0 {
                    Self.respawnRotatedPoint(&state.slots[index].vecTPre, scale: scale, narrow: false, angle: angle)
                }
            }
            state.slots[index].vecTPre.y -= riseStep

            if state.slots[index].vecTNow.y < 0 {
                state.slots[index].vecTNow.x -= EffectSpace.sine(degrees: Int(state.slots[index].height[12])) * 0.01
                state.slots[index].vecTNow.z += EffectSpace.sine(degrees: Int(state.slots[index].height[14])) * 0.01
                if state.slots[index].vecTNow.y < scale * -8.0 {
                    Self.respawnRotatedPoint(&state.slots[index].vecTNow, scale: scale, narrow: false, angle: angle)
                }
            }
            state.slots[index].vecTNow.y -= riseStep
        }
    }

    /// Geometry submission for primitive `150`, rendering 4 hovering camera-facing squares with height-based fade.
    func renderHoverSquares(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1 else {
                continue
            }

            let red = UInt8(clamping: Int(Float(slot.flag1[10]) * 2.57))
            let green = UInt8(clamping: Int(Float(slot.flag1[11]) * 2.57))
            let blue = UInt8(clamping: Int(Float(slot.flag1[12]) * 2.57))
            let corners = Self.facingSquareCorners(radius: slot.distance, rot0: rot0, rot1: rot1)

            for center in [slot.vecBPre, slot.vecBNow, slot.vecTPre, slot.vecTNow] {
                let v1 = corners.0 + center
                guard v1.y <= 0 else {
                    continue
                }

                var alpha = 50
                if v1.y < -4.0 {
                    alpha = Int((v1.y + 4.0) * 15.0 + 50.0)
                }
                if v1.y > -0.5 {
                    alpha = Int(v1.y * -100.0)
                }

                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: Int16(max(0, alpha)),
                    v1: v1,
                    v2: corners.1 + center,
                    v3: corners.2 + center,
                    v4: corners.3 + center,
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

    // MARK: - Primitives 155 & 170

    /// Motion update for primitive `155` wandering flame billboards at 60Hz.
    func primWanderingFlames(context: EffectTickContext) {
        updateWanderingFlames(
            context: context,
            fadeInEnd: 10,
            fadeOutStart: 20,
            fullCircleRetarget: false
        )
    }

    /// Motion update for primitive `170` long-lived wandering flame billboards at 60Hz.
    func primWanderingFlames2(context: EffectTickContext) {
        updateWanderingFlames(
            context: context,
            fadeInEnd: 50,
            fadeOutStart: 60,
            fullCircleRetarget: true
        )
    }

    /// Geometry submission for primitives `155` and `170`, rendering twin glowing camera-facing squares.
    func renderTwinGlowSquares(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1 else {
                continue
            }

            let corners = Self.facingSquareCorners(radius: slot.distance, rot0: rot0, rot1: rot1)

            emitGlowSquarePair(
                into: &collector,
                assets: assets,
                corners: corners,
                center: slot.vecBPre,
                alpha: Int16(max(0, Int(slot.height[12]))),
                style: slot.flag1[0],
                isSecondPair: false
            )
            emitGlowSquarePair(
                into: &collector,
                assets: assets,
                corners: corners,
                center: slot.vecBNow,
                alpha: Int16(max(0, Int(slot.height[13]))),
                style: slot.flag1[0],
                isSecondPair: true
            )
        }
    }

    // MARK: - Primitive 157

    /// Motion update for primitive `157` orbiting fading glow squares at 60Hz.
    func primOrbitFade(context: EffectTickContext) {
        faceCamera(world: context.world)

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            if state.slots[index].process < 10 {
                state.slots[index].alphaB += 25
            }
            if state.slots[index].alphaB >= 255 {
                state.slots[index].alphaB = 255
            }

            if state.slots[index].vecBNow.y >= 0 {
                state.slots[index].alphaB -= 15
            } else {
                state.slots[index].vecBNow.y += state.slots[index].maxHeight
            }

            let angle = state.slots[index].fullDisplayAngle
            state.slots[index].vecBNow.x = state.slots[index].height[0] * EffectSpace.cosine(degrees: Int(angle))
            state.slots[index].vecBNow.z = state.slots[index].height[0] * EffectSpace.sine(degrees: Int(angle))

            if state.slots[index].alphaB < 0 {
                state.slots[index].alphaB = 0
                state.slots[index].life = 0
            }

            if angle >= 360 {
                state.slots[index].fullDisplayAngle = angle - 360
            }
        }
    }

    /// Geometry submission for primitive `157`, rendering a core billboard plus a `1.1x` red outer glow.
    func renderGlowSquare(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1 else {
                continue
            }

            let corners = Self.facingSquareCorners(radius: slot.distance, rot0: rot0, rot1: rot1)
            let alpha = max(Int16(0), slot.alphaB)

            if slot.flag1[0] == 0 || slot.flag1[0] == 1 || slot.flag1[0] == 2 {
                let tint: UInt8 = switch slot.flag1[0] {
                case 0: 255
                case 1: 160
                default: 90
                }
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: alpha,
                    v1: corners.0 + slot.vecBNow,
                    v2: corners.1 + slot.vecBNow,
                    v3: corners.2 + slot.vecBNow,
                    v4: corners.3 + slot.vecBNow,
                    blendSelector: 0,
                    textureIndex: 0,
                    isWorldPosition: false,
                    red: 255,
                    green: tint,
                    blue: tint,
                    extra: 1
                )
            }

            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: alpha,
                v1: corners.0 * 1.1 + slot.vecBNow,
                v2: corners.1 * 1.1 + slot.vecBNow,
                v3: corners.2 * 1.1 + slot.vecBNow,
                v4: corners.3 * 1.1 + slot.vecBNow,
                blendSelector: 0,
                textureIndex: 0,
                isWorldPosition: false,
                red: 255,
                green: 1,
                blue: 1,
                extra: 1
            )
        }
    }

    // MARK: - Primitive 161

    /// Motion update for primitive `161` twin spinning floor squares at 60Hz.
    func primTwinSpin() {
        followMaster()

        for index in 0..<2 {
            state.slots[index].process += 1
            state.slots[index].riseAngle += 3
            if state.slots[index].riseAngle >= 360 {
                state.slots[index].riseAngle -= 360
            }
            if state.slots[index].process > state.duration - 25 {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 8)
            }
        }
    }

    /// Geometry submission for primitives `26`, `28`, `39`, `67`, `88`, and `161`.
    func renderSizedSquare(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let size = state.size

        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1 else {
                continue
            }

            var angle = index * 23
            if size == 100.0 || size >= 110.0 || (size == 4.0 && slot.height[4] == 4.0) || size == 10.0 || size == 0.0 {
                angle = Int(slot.rotStart)
            }
            angle = ((angle % 360) + 360) % 360

            let radius = Float(
                (Double(EffectSpace.sine(degrees: Int(slot.riseAngle))) + 1.0) * Double(slot.distance * 0.1)
                    + Double(slot.distance) * 0.8
            )
            let y = slot.height[0]

            let a0 = angle
            let a1 = (a0 + 90) % 360
            let a2 = (a1 + 90) % 360
            let a3 = (a2 + 90) % 360

            let v1 = SIMD3<Float>(EffectSpace.cosine(degrees: a0) * radius, y, EffectSpace.sine(degrees: a0) * radius)
            let v2 = SIMD3<Float>(EffectSpace.cosine(degrees: a1) * radius, y, EffectSpace.sine(degrees: a1) * radius)
            let v3 = SIMD3<Float>(EffectSpace.cosine(degrees: a2) * radius, y, EffectSpace.sine(degrees: a2) * radius)
            let v4 = SIMD3<Float>(EffectSpace.cosine(degrees: a3) * radius, y, EffectSpace.sine(degrees: a3) * radius)

            func emit(pw: Int16 = 0, r: UInt8, g: UInt8, b: UInt8, extra: Int8 = 0) {
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: slot.alphaB,
                    v1: v1,
                    v2: v2,
                    v3: v3,
                    v4: v4,
                    blendSelector: pw,
                    textureIndex: 0,
                    isWorldPosition: false,
                    red: r,
                    green: g,
                    blue: b,
                    extra: extra
                )
            }

            switch size {
            case 101.0:
                emit(r: 255, g: 0, b: 0)
                emit(r: 255, g: 0, b: 0)
            case 102.0:
                emit(r: 255, g: 255, b: 0)
            case 111.0:
                emit(r: 55, g: 55, b: 255)
            case 112.0:
                emit(r: 105, g: 225, b: 105)
            case 100.0:
                emit(r: 255, g: 255, b: 255)
                emit(r: 255, g: 255, b: 255)
            case 110.0, 0.0:
                emit(pw: 1, r: 255, g: 255, b: 255)
            case 113.0:
                emit(r: 5, g: 5, b: 255, extra: 1)
            case 114.0:
                emit(r: 155, g: 5, b: 5, extra: 1)
            case 15.0:
                emit(r: 35, g: 255, b: 35)
            case 17.0:
                emit(r: 105, g: 105, b: 255)
            case 18.0:
                emit(r: 35, g: 35, b: 255)
            default:
                emit(r: 255, g: 255, b: 255)
            }
        }
    }

    // MARK: - Primitive 166

    /// Motion update for primitive `166` scrolling UV phase folding ribbons at 60Hz.
    func primFramePhase() {
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

            state.slots[index].height[9] += state.slots[index].height[2]
            if state.slots[index].height[9] >= 1.0 {
                state.slots[index].height[9] -= 1.0
            }
        }
    }

    /// Geometry submission for primitive `166`, rendering 6-part UV-scrolled folding ribbons per slot.
    func renderFoldingRibbon(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        for index in 0..<4 {
            let slot = state.slots[index]
            guard slot.life == 1, slot.alphaB > 0 else {
                continue
            }

            let shade: UInt8 = slot.height[3] == 1.0 ? 30 : 155
            let textureIndex = Int(slot.height[1])
            let phase = slot.height[9]
            let dist = slot.distance
            let edge = 12.0 - phase * 24.0
            let riseAngle = ((Int(slot.riseAngle) % 360) + 360) % 360
            let cs = EffectSpace.cosine(degrees: riseAngle)
            let sn = EffectSpace.sine(degrees: riseAngle)
            let angle = (riseAngle + 90) % 360
            let offsetX = EffectSpace.cosine(degrees: angle) * 12.0
            let offsetZ = EffectSpace.sine(degrees: angle) * 12.0
            let y = slot.height[0]

            func transform(_ x: Float, _ z: Float) -> SIMD3<Float> {
                SIMD3<Float>(x * cs - z * sn + offsetX, y, z * cs + x * sn + offsetZ)
            }

            // Base segment part 1
            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: transform(dist, -12.0),
                v2: transform(dist, edge),
                v3: transform(-dist, edge),
                v4: transform(-dist, -12.0),
                blendSelector: 0,
                textureIndex: textureIndex,
                isWorldPosition: false,
                red: shade,
                green: shade,
                blue: 255,
                u1Coord: phase,
                u2Coord: 1.0
            )

            // Base segment part 2
            var v0 = transform(dist, edge)
            var v1 = transform(dist, 12.0)
            var v2 = transform(-dist, 12.0)
            var v3 = transform(-dist, edge)
            renderTeiRect(
                into: &collector,
                assets: assets,
                alpha: slot.alphaB,
                v1: v0,
                v2: v1,
                v3: v2,
                v4: v3,
                blendSelector: 0,
                textureIndex: textureIndex,
                isWorldPosition: false,
                red: shade,
                green: shade,
                blue: 255,
                u1Coord: 0,
                u2Coord: phase
            )

            // Two consecutive 20-degree bent ribbon extensions
            var bend = angle
            for _ in 0..<2 {
                bend -= 20
                if bend < 0 {
                    bend += 360
                }
                let bendCos = EffectSpace.cosine(degrees: bend)
                let bendSin = EffectSpace.sine(degrees: bend)
                let rest = 1.0 - phase

                let mid1 = SIMD3<Float>(bendCos * (rest * 32.0) + v1.x, y, bendSin * (rest * 32.0) + v1.z)
                let mid2 = SIMD3<Float>(bendCos * (rest * 40.0) + v2.x, y, bendSin * (rest * 40.0) + v2.z)
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: slot.alphaB,
                    v1: v1,
                    v2: mid1,
                    v3: mid2,
                    v4: v2,
                    blendSelector: 0,
                    textureIndex: textureIndex,
                    isWorldPosition: false,
                    red: shade,
                    green: shade,
                    blue: 255,
                    u1Coord: phase,
                    u2Coord: 1.0
                )

                let end1 = SIMD3<Float>(bendCos * 32.0 + v1.x, y, bendSin * 32.0 + v1.z)
                let end2 = SIMD3<Float>(bendCos * 40.0 + v2.x, y, bendSin * 40.0 + v2.z)
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: slot.alphaB,
                    v1: mid1,
                    v2: end1,
                    v3: end2,
                    v4: mid2,
                    blendSelector: 0,
                    textureIndex: textureIndex,
                    isWorldPosition: false,
                    red: shade,
                    green: shade,
                    blue: 255,
                    u1Coord: 0,
                    u2Coord: phase
                )

                v0 = end1
                v3 = end2
                v1 = v0
                v2 = v3
            }
        }
    }

    // MARK: - Primitive 172

    /// Geometry submission for primitive `172`, rendering a full-screen-facing tinted overlay quad.
    func renderTintOverlay172(into collector: inout EffectPrimitiveBatchCollector, assets: EffectAssetStore?) {
        let slot = state.slots[0]
        guard slot.life == 1, slot.alphaB > 0 else {
            return
        }

        let red = UInt8(truncatingIfNeeded: state.argb)
        let green = UInt8(truncatingIfNeeded: state.argb >> 8)
        let blue = UInt8(truncatingIfNeeded: state.argb >> 16)

        var c0 = SIMD3<Float>(-200.0, -10.0, -200.0)
        var c1 = SIMD3<Float>(200.0, -10.0, -200.0)
        var c2 = SIMD3<Float>(200.0, -10.0, 200.0)
        var c3 = SIMD3<Float>(-200.0, -10.0, 200.0)
        Self.towardScreen(&c0, &c1, &c2, &c3, rot0: slot.alphaT, rot1: state.slots[1].alphaT)

        renderTeiRect(
            into: &collector,
            assets: assets,
            alpha: slot.alphaB,
            v1: c0,
            v2: c1,
            v3: c2,
            v4: c3,
            blendSelector: 1,
            textureIndex: 0,
            isWorldPosition: false,
            red: red,
            green: green,
            blue: blue
        )
    }

    // MARK: - Shared Panel & Billboard Helpers

    private func advanceTextureFrame() {
        let speed = max(1, state.animSpeed)
        guard state.stateCnt % speed == 0 else {
            return
        }
        let next = currentMotion + 1
        currentMotion = next
        if state.repeatAnim {
            let total = max(1, state.texturePaths.isEmpty ? state.totalTexture : state.texturePaths.count)
            currentMotion = next % total
        }
    }

    private func copySwirlTrail(from source: Int, to destination: Int, alphaDrop: Int16) {
        state.slots[destination].fullDisplayAngle = state.slots[source].fullDisplayAngle
        state.slots[destination].distance = state.slots[source].distance
        state.slots[destination].height[8] = state.slots[source].height[8]
        state.slots[destination].alphaB = max(0, state.slots[source].alphaB - alphaDrop)
        state.slots[destination].vecBNow = state.slots[source].vecBNow
        state.slots[destination].flag1[0] = state.slots[source].flag1[0]
    }

    /// Builds a camera-facing square of radius `radius` rotated by `startAngle`, transformed via `towardScreen`.
    static func facingSquareCorners(
        radius: Float,
        startAngle: Int = 45,
        rot0: Int16,
        rot1: Int16
    ) -> (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>) {
        let a0 = ((startAngle % 360) + 360) % 360
        let a1 = (a0 + 90) % 360
        let a2 = (a1 + 90) % 360
        let a3 = (a2 + 90) % 360

        var v0 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a0), 0, radius * EffectSpace.sine(degrees: a0))
        var v1 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a1), 0, radius * EffectSpace.sine(degrees: a1))
        var v2 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a2), 0, radius * EffectSpace.sine(degrees: a2))
        var v3 = SIMD3<Float>(radius * EffectSpace.cosine(degrees: a3), 0, radius * EffectSpace.sine(degrees: a3))

        towardScreen(&v0, &v1, &v2, &v3, rot0: rot0, rot1: rot1)
        return (v0, v1, v2, v3)
    }

    private func emitGlowSquarePair(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?,
        corners: (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>),
        center: SIMD3<Float>,
        alpha: Int16,
        style: Int8,
        isSecondPair: Bool
    ) {
        let v1 = corners.0 + center
        let v2 = corners.1 + center
        let v3 = corners.2 + center
        let v4 = corners.3 + center

        if style == 1 {
            renderTeiRect(into: &collector, assets: assets, alpha: alpha / 3, v1: v1, v2: v2, v3: v3, v4: v4, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 255, green: 255, blue: 255, extra: 1)
            renderTeiRect(into: &collector, assets: assets, alpha: alpha, v1: v1, v2: v2, v3: v3, v4: v4, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: 255, green: 50, blue: 50, extra: 1)
        } else if style == 2 {
            renderTeiRect(into: &collector, assets: assets, alpha: alpha, v1: v2, v2: v1, v3: v4, v4: v3, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: 255, green: 255, blue: 255, extra: 1)
        } else if style == 3 {
            if !isSecondPair {
                renderTeiRect(into: &collector, assets: assets, alpha: alpha, v1: v2, v2: v1, v3: v4, v4: v3, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: 255, green: 255, blue: 255, extra: 1)
            }
        } else {
            renderTeiRect(into: &collector, assets: assets, alpha: alpha / 3, v1: v1, v2: v2, v3: v3, v4: v4, blendSelector: 1, textureIndex: 0, isWorldPosition: false, red: 255, green: 255, blue: 255, extra: 1)
            renderTeiRect(into: &collector, assets: assets, alpha: alpha, v1: v1, v2: v2, v3: v3, v4: v4, blendSelector: 0, textureIndex: 0, isWorldPosition: false, red: 50, green: 50, blue: 255, extra: 1)
        }
    }

    private func updateWanderingFlames(
        context: EffectTickContext,
        fadeInEnd: Int,
        fadeOutStart: Int,
        fullCircleRetarget: Bool
    ) {
        faceCamera(world: context.world)

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            for pair in 0..<2 {
                let base = pair * 5
                let originAngle = state.slots[index].height[base]
                Self.stepTowardAngle(
                    in: &state.slots[index],
                    angleIndex: base + 2,
                    targetIndex: base + 1,
                    step: 2.0
                ) {
                    if fullCircleRetarget {
                        return originAngle + Float(Int.random(in: 0..<360))
                    } else {
                        return originAngle - 45.0 + Float(Int.random(in: 0..<91))
                    }
                }

                Self.stepTowardAngle(
                    in: &state.slots[index],
                    angleIndex: base + 4,
                    targetIndex: base + 3,
                    step: 1.0
                ) {
                    Float(Int.random(in: 0..<11) + 175)
                }
            }

            for angleIndex in 0..<10 {
                if state.slots[index].height[angleIndex] < 0 {
                    state.slots[index].height[angleIndex] += 360.0
                }
                if state.slots[index].height[angleIndex] >= 360.0 {
                    state.slots[index].height[angleIndex] -= 360.0
                }
            }

            for fade in 12..<14 {
                if process < fadeInEnd {
                    state.slots[index].height[fade] = min(255.0, state.slots[index].height[fade] + 25.0)
                } else if process > fadeOutStart {
                    state.slots[index].height[fade] -= 3.0
                    if state.slots[index].height[fade] < 0 {
                        state.slots[index].life = 0
                        state.slots[index].height[fade] = 0
                    }
                }
            }

            let speed = state.slots[index].maxHeight
            state.slots[index].vecBPre.x += speed * EffectSpace.cosine(degrees: Int(state.slots[index].height[2]))
            state.slots[index].vecBPre.z += speed * EffectSpace.sine(degrees: Int(state.slots[index].height[2]))
            state.slots[index].vecBPre.y -= speed * EffectSpace.sine(degrees: Int(state.slots[index].height[4]))
            state.slots[index].vecBNow.x += speed * EffectSpace.cosine(degrees: Int(state.slots[index].height[7]))
            state.slots[index].vecBNow.z += speed * EffectSpace.sine(degrees: Int(state.slots[index].height[7]))
            state.slots[index].vecBNow.y += speed * EffectSpace.sine(degrees: Int(state.slots[index].height[9]))
        }
    }

    private static func stepTowardAngle(
        in slot: inout EffectPrimitiveSlot,
        angleIndex: Int,
        targetIndex: Int,
        step: Float,
        retarget: () -> Float
    ) {
        let target = slot.height[targetIndex]
        let difference = slot.height[angleIndex] - target
        if difference < 180.0 && difference >= 0 {
            slot.height[angleIndex] -= step
            if slot.height[angleIndex] <= target {
                slot.height[targetIndex] = retarget()
            }
        } else if difference < -180.0 {
            slot.height[angleIndex] -= step
            if slot.height[angleIndex] <= target - 360.0 {
                slot.height[targetIndex] = retarget()
            }
        } else {
            slot.height[angleIndex] += step
            if slot.height[angleIndex] >= target {
                slot.height[targetIndex] = retarget()
            }
        }
    }

    static func driftSlotAngles(
        _ slot: inout EffectPrimitiveSlot,
        count: Int,
        rise: Float = 1.0,
        fall: Float = 1.0
    ) {
        for axis in stride(from: 0, to: count * 2, by: 2) {
            if slot.height[axis + 1] > slot.height[axis] {
                slot.height[axis] = min(359.0, slot.height[axis] + rise)
                if slot.height[axis] > slot.height[axis + 1] {
                    let upper = Int(slot.height[axis])
                    slot.height[axis + 1] = upper > 0 ? Float(Int.random(in: 0..<upper)) : 0
                }
            } else {
                slot.height[axis] = max(0, slot.height[axis] - fall)
                if slot.height[axis] <= slot.height[axis + 1] {
                    let upper = Int(slot.height[axis])
                    let roll = upper > 0 ? Int.random(in: 0..<upper) : 0
                    slot.height[axis + 1] = Float(359 - roll)
                }
            }
        }
    }

    private static func tickBlinkFlag(
        in slot: inout EffectPrimitiveSlot,
        alphaIndex: Int,
        phaseIndex: Int,
        triggerChance: Int
    ) {
        if Int.random(in: 0..<triggerChance) == 0 && slot.flag1[alphaIndex] > 100 && slot.flag1[phaseIndex] == 0 {
            slot.flag1[phaseIndex] = 1
        }
        guard slot.flag1[phaseIndex] >= 1 else {
            return
        }
        slot.flag1[phaseIndex] = slot.flag1[phaseIndex] &+ 1
        if slot.flag1[phaseIndex] <= 90 {
            slot.flag1[alphaIndex] = Int8(max(0, Int(slot.flag1[alphaIndex]) - 6))
        } else if slot.flag1[phaseIndex] < 120 {
            slot.flag1[alphaIndex] = Int8(min(120, Int(slot.flag1[alphaIndex]) + 4))
        } else {
            slot.flag1[phaseIndex] = 0
        }
    }

    private static func updateDriftingSubQuad(
        in slot: inout EffectPrimitiveSlot,
        positionKeyPath: WritableKeyPath<EffectPrimitiveSlot, SIMD3<Float>>,
        alphaIndex: Int,
        phaseIndex: Int,
        reachThreshold: Int,
        inclusiveThreshold: Bool
    ) {
        let position = slot[keyPath: positionKeyPath]
        let reach = max(abs(Int(position.x)), abs(Int(position.z)))
        let exceeded = inclusiveThreshold ? (reach >= reachThreshold) : (reach > reachThreshold)
        if exceeded {
            slot.flag1[alphaIndex] &-= 2
            if slot.flag1[alphaIndex] <= 1 {
                slot[keyPath: positionKeyPath].x = Float(Int.random(in: 0..<31) - 15)
                slot[keyPath: positionKeyPath].z = Float(Int.random(in: 0..<31) - 15)
            }
        } else {
            tickBlinkFlag(in: &slot, alphaIndex: alphaIndex, phaseIndex: phaseIndex, triggerChance: 125)
        }
    }

    private static func respawnRotatedPoint(
        _ point: inout SIMD3<Float>,
        scale: Float,
        narrow: Bool,
        angle: Int16
    ) {
        let rawX = narrow ? Float(Int.random(in: 0..<25) - 12) : Float(Int.random(in: 0..<45) - 22)
        let rawY = Float(Int.random(in: 0..<30))
        let rawZ = Float(Int.random(in: 0..<11) - 5)

        let scaledX = rawX * scale
        let scaledY = rawY * scale
        let scaledZ = rawZ * scale

        let cs = EffectSpace.cosine(degrees: Int(angle))
        let sn = EffectSpace.sine(degrees: Int(angle))
        point = SIMD3<Float>(
            cs * scaledX - sn * scaledZ,
            scaledY,
            sn * scaledX + cs * scaledZ
        )
    }

    // MARK: - Field Panel Renderer (PP_PARTICLE_UP (59) / PP_BOTTOM (47) / PP_BOTTOMOUT (49))

    /// Geometry submission for billboarded field panels (`PP_PARTICLE_UP` (59), `PP_BOTTOM` (47), `PP_BOTTOMOUT` (49)), mirroring `CEffectPrim::RenderFieldPanel`.
    func renderFieldPanel(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT
        let panelStyle = state.slots[0].flag1[2]
        let subStyle = state.slots[0].flag1[3]

        for index in 0..<4 {
            guard state.slots[index].life == 1, state.slots[index].alphaB > 0 else {
                continue
            }

            let slot = state.slots[index]
            let pulseAngle = (slot.height[8] >= 360 || slot.height[8] < 0) ? 0 : Int(slot.height[8])
            let rx = slot.distance * EffectSpace.sine(degrees: pulseAngle) * 0.05 + slot.distance

            let angle1 = ((Int(slot.fullDisplayAngle) % 360) + 360) % 360
            let angle2 = (angle1 + 90) % 360
            let angle3 = (angle2 + 90) % 360
            let angle4 = (angle3 + 90) % 360

            var vec1 = SIMD3<Float>(rx * EffectSpace.cosine(degrees: angle1), 0, rx * EffectSpace.sine(degrees: angle1))
            var vec2 = SIMD3<Float>(rx * EffectSpace.cosine(degrees: angle2), 0, rx * EffectSpace.sine(degrees: angle2))
            var vec3 = SIMD3<Float>(rx * EffectSpace.cosine(degrees: angle3), 0, rx * EffectSpace.sine(degrees: angle3))
            var vec4 = SIMD3<Float>(rx * EffectSpace.cosine(degrees: angle4), 0, rx * EffectSpace.sine(degrees: angle4))

            if slot.height[9] == 10.0 {
                vec1.x += 4.0
                vec2.x += 4.0
                vec3.x += 4.0
                vec4.x += 4.0
            }

            Self.towardScreen(&vec1, &vec2, &vec3, &vec4, rot0: rot0, rot1: rot1)

            vec1 += slot.vecBNow
            vec2 += slot.vecBNow
            vec3 += slot.vecBNow
            vec4 += slot.vecBNow

            let textureIndex = Int(UInt8(bitPattern: slot.flag1[0]))
            let alpha = slot.alphaB

            func submit(
                alpha: Int16 = alpha,
                v1: SIMD3<Float> = vec2,
                v2: SIMD3<Float> = vec1,
                v3: SIMD3<Float> = vec4,
                v4: SIMD3<Float> = vec3,
                pw: Int16,
                red: UInt8,
                green: UInt8,
                blue: UInt8
            ) {
                renderTeiRect(
                    into: &collector,
                    assets: assets,
                    alpha: alpha,
                    v1: v1,
                    v2: v2,
                    v3: v3,
                    v4: v4,
                    blendSelector: pw,
                    textureIndex: textureIndex,
                    isWorldPosition: true,
                    red: red,
                    green: green,
                    blue: blue
                )
            }

            switch panelStyle {
            case 0:
                submit(v1: vec1, v2: vec2, v3: vec3, v4: vec4, pw: 1, red: 255, green: 255, blue: 255)
            case 1:
                submit(v1: vec1, v2: vec2, v3: vec3, v4: vec4, pw: 0, red: 150, green: 150, blue: 250)
            case 2:
                submit(pw: 0, red: 130, green: 130, blue: 250)
            case 3:
                submit(pw: 0, red: 200, green: 200, blue: 100)
            case 4:
                submit(pw: 1, red: 255, green: 255, blue: 255)
            case 7, 23:
                submit(pw: 0, red: 255, green: 255, blue: 255)
            case 8:
                submit(pw: 1, red: 135, green: 255, blue: 135)
            case 9:
                switch subStyle {
                case 1:
                    submit(pw: 1, red: 255, green: 135, blue: 135)
                case 2:
                    submit(pw: 1, red: 255, green: 205, blue: 135)
                case 3:
                    submit(pw: 1, red: 255, green: 255, blue: 135)
                case 4:
                    submit(pw: 1, red: 255, green: 255, blue: 255)
                case 5:
                    submit(pw: 1, red: 135, green: 135, blue: 255)
                case 6:
                    submit(pw: 0, red: 255, green: 255, blue: 255)
                default:
                    break
                }
            case 10:
                submit(pw: 0, red: 250, green: 250, blue: 150)
            case 11:
                submit(pw: 0, red: 220, green: 250, blue: 220)
            case 12:
                submit(pw: 1, red: 252, green: 171, blue: 143)
            case 13:
                submit(pw: 0, red: 250, green: 100, blue: 100)
            case 14:
                submit(pw: 1, red: 94, green: 0, blue: 0)
            case 15:
                submit(v1: vec1, v2: vec2, v3: vec3, v4: vec4, pw: 1, red: 255, green: 200, blue: 255)
            case 16:
                submit(pw: 1, red: 0, green: 0, blue: 0)
            case 17:
                submit(pw: 1, red: 255, green: 180, blue: 180)
            case 18:
                submit(alpha: alpha / 2, pw: 0, red: 255, green: 255, blue: 255)
            case 24:
                submit(pw: 0, red: 63, green: 72, blue: 204)
            case 25:
                vec1.y -= 110.0
                vec2.y -= 110.0
                vec3.y -= 110.0
                vec4.y -= 110.0
                submit(v1: vec2, v2: vec1, v3: vec4, v4: vec3, pw: 0, red: 255, green: 255, blue: 255)
            default:
                break
            }
        }
    }
}
