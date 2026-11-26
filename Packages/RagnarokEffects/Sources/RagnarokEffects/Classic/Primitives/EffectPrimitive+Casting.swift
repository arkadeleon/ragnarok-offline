//
//  EffectPrimitive+Casting.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

import Foundation
import simd

extension EffectPrimitive {

    // MARK: - PP_3DCASTING (23)

    /// Motion update for `PP_3DCASTING` (23) rising casting rings at 60Hz.
    func prim3DCasting() {
        followMaster()

        var index = 0
        while index < 4 {
            if state.size == 3.0 && index < 3 {
                index = 3
            }

            guard state.slots[index].life == 1 else {
                index += 1
                continue
            }

            state.slots[index].process += 1
            let process = state.slots[index].process

            if index < 3 {
                state.slots[index].rotStart += Int16(index + 3)
            }
            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            if process >= state.duration - 40 {
                state.slots[index].alphaB -= index < 3 ? 5 : 2
                if state.slots[index].alphaB < 0 {
                    state.slots[index].alphaB = 0
                }
            } else if process < 20 && state.slots[index].alphaT != 1 {
                if index == 3 {
                    state.slots[3].alphaB = min(60, state.slots[3].alphaB + 8)
                } else {
                    state.slots[index].alphaB = min(180, state.slots[index].alphaB + 10)
                }
            }

            let maxHeight = state.slots[index].maxHeight
            for sample in 0..<21 where state.slots[index].flag1[sample] == 0 {
                let sampleSine = EffectSpace.sine(degrees: sample * 9)
                if process <= 90 {
                    state.slots[index].height[sample] = maxHeight * sampleSine * EffectSpace.sine(degrees: process)
                }

                let maximum = maxHeight * sampleSine
                if state.slots[index].height[sample] > maximum {
                    state.slots[index].height[sample] = maximum
                    state.slots[index].flag1[sample] = 1
                }
                if state.slots[index].height[sample] < 0 {
                    state.slots[index].height[sample] = 0
                }
            }

            index += 1
        }
    }

    // MARK: - PP_3DCASTING_2 (24)

    /// Motion update for `PP_3DCASTING_2` (24) oscillating wave casting rings at 60Hz.
    func prim3DCasting2() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            if index == 0 || index == 2 {
                state.slots[index].rotStart += 1
            } else {
                state.slots[index].rotStart += 2
            }
            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            if process < state.duration - 20 {
                if process < 100 {
                    state.slots[index].alphaB = min(80, state.slots[index].alphaB + 1)
                }
            } else {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 5)
            }

            let maxHeight = state.slots[index].maxHeight
            let angle = index * 45 < 90 ? process + index * 90 : (process + index * 45) * 2
            let waveSine = EffectSpace.sine(degrees: angle % 360)
            for sample in 0..<21 {
                let base = maxHeight * EffectSpace.sine(degrees: sample * 9)
                state.slots[index].height[sample] = base * 0.3 * waveSine + base
            }
        }
    }

    // MARK: - PP_3DCASTING_3 (25)

    /// Motion update for `PP_3DCASTING_3` (25) pulsing wave casting rings at 60Hz.
    func prim3DCasting3() {
        followMaster()

        var index = 0
        while index < 4 {
            if state.size == 3.0 && index < 3 {
                index = 3
            }

            guard state.slots[index].life == 1 else {
                index += 1
                continue
            }

            state.slots[index].process += 1
            let process = state.slots[index].process

            if index < 3 {
                state.slots[index].rotStart += Int16(index + 3)
            }
            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            if process >= state.duration - 40 {
                state.slots[index].alphaB -= index < 3 ? 5 : 3
                if state.slots[index].alphaB < 0 {
                    state.slots[index].alphaB = 0
                }
            } else if process < 20 {
                if index == 3 {
                    state.slots[3].alphaB = min(100, state.slots[3].alphaB + 8)
                } else {
                    state.slots[index].alphaB = min(180, state.slots[index].alphaB + 10)
                }
            }

            let maxHeight = state.slots[index].maxHeight
            if index < 3 {
                for sample in 0..<21 where state.slots[index].flag1[sample] == 0 {
                    let sampleSine = EffectSpace.sine(degrees: sample * 9)
                    if process <= 90 {
                        state.slots[index].height[sample] = maxHeight * sampleSine * EffectSpace.sine(degrees: process)
                    }

                    let maximum = maxHeight * sampleSine
                    if state.slots[index].height[sample] > maximum {
                        state.slots[index].height[sample] = maximum
                        state.slots[index].flag1[sample] = 1
                    }
                    if state.slots[index].height[sample] < 0 {
                        state.slots[index].height[sample] = 0
                    }
                }
            } else {
                let phaseSine = EffectSpace.sine(degrees: process % 360)
                for sample in 0..<21 {
                    let sampleSine = EffectSpace.sine(degrees: sample * 9)
                    if state.slots[index].flag1[sample] == 0 {
                        let value: Float
                        if process <= 90 {
                            value = maxHeight * sampleSine * EffectSpace.sine(degrees: process)
                            state.slots[index].height[sample] = value
                        } else {
                            state.slots[index].flag1[sample] = 1
                            value = state.slots[index].height[sample]
                        }

                        if value > maxHeight * sampleSine {
                            state.slots[index].flag1[sample] = 1
                        }
                        if state.slots[index].height[sample] < 0 {
                            state.slots[index].height[sample] = 0
                        }
                    } else {
                        let base = maxHeight * sampleSine * 0.55
                        state.slots[index].height[sample] = maxHeight * sampleSine * 0.45 * phaseSine + base
                    }
                }
            }

            index += 1
        }
    }

    // MARK: - Primitive 30

    /// Motion update for primitive `30` expanding wave casting rings at 60Hz.
    func primCasting30() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            state.slots[index].distance += 0.07
            state.slots[index].riseAngle -= 1
            if state.slots[index].riseAngle < 10 {
                state.slots[index].riseAngle = 10
                state.slots[index].alphaB = 0
            }

            if state.slots[index].distance < 4.0 {
                state.slots[index].alphaB += state.slots[index].alphaT == 22 ? 5 : 10
            } else {
                state.slots[index].alphaB -= 3
                if state.slots[index].alphaB < 1 {
                    state.slots[index].alphaB = 0
                    if process < state.duration - 30 {
                        state.slots[index].distance = 3.37
                        state.slots[index].riseAngle = state.slots[index].alphaT == 22 ? 64 : 74
                    }
                }
            }

            applyWaveSlotHeightsFixed(slotIndex: index, amplitude: 0.3)
        }
    }

    // MARK: - Primitive 31

    /// Motion update for primitive `31` spinning wave casting rings at 60Hz.
    func primWaveSpin() {
        followMaster()

        let fast = state.accel != 99.0
        for index in 0..<4 where state.slots[index].life == 1 {
            let process = state.slots[index].process + 1
            state.slots[index].process = process

            var rot = state.slots[index].rotStart + (fast ? 5 : 3)
            if rot >= 360 {
                rot -= 360
            }
            state.slots[index].rotStart = rot

            state.slots[index].distance += fast ? 0.3 : 0.1
            state.slots[index].riseAngle -= 1
            let minRise: Int16 = fast ? 40 : 30
            if state.slots[index].riseAngle < minRise {
                state.slots[index].riseAngle = minRise
            }

            if process > 10 {
                let step: Int16 = switch state.slots[index].alphaT {
                case 2: 8
                case 3, 4: 5
                case 5: 4
                default: 2
                }
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - step)
            } else {
                state.slots[index].alphaB += state.slots[index].alphaT == 1 ? 10 : 20
            }

            let phase = index * 90
            let waveSin = EffectSpace.sine(degrees: (phase + process) % 360)
            let maxHeight = state.slots[index].maxHeight
            for point in 0..<21 {
                let base = EffectSpace.sine(degrees: 9 * point) * maxHeight
                state.slots[index].height[point] = base + base * 0.15 * waveSin
            }
        }
    }

    // MARK: - PP_GI_3 (34)

    /// Motion update for `PP_GI_3` (34) tilted quadrant casting rings at 60Hz.
    func primGI3() {
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            state.slots[index].distance -= 0.01

            let process = state.slots[index].process
            if process >= 10 {
                state.slots[index].alphaB -= 1
                if state.slots[index].alphaB <= 0 {
                    state.slots[index].alphaB = 0
                    if process > 30 {
                        state.slots[index].life = 0
                    }
                    state.slots[index].distance = 20.0
                    state.slots[index].riseAngle = 90
                }
            } else {
                state.slots[index].alphaB += 10
            }

            let height = state.slots[index].maxHeight * EffectSpace.sine(degrees: process)
            for sample in 0..<21 {
                state.slots[index].height[sample] = height
            }
        }
    }

    /// Geometry submission for `PP_GI_3` (34) tilted quadrant casting rings.
    func render3DCasting2(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        for ec in 0..<4 where state.slots[ec].life == 1 {
            let fullDisplayAngle = Int(state.slots[ec].fullDisplayAngle)
            let basicAngle = fullDisplayAngle / 9
            guard basicAngle > 0 else {
                continue
            }

            var order = 0
            var count = 0
            while count < fullDisplayAngle {
                var angle = (Int(state.slots[ec].rotStart) + count) % 360
                if angle < 0 {
                    angle += 360
                }
                if fullDisplayAngle == 360 && order == 20 {
                    angle = Int(state.slots[ec].rotStart)
                }

                var cs1 = EffectSpace.cosine(degrees: angle)
                var sn1 = EffectSpace.sine(degrees: angle)
                let base = SIMD3<Float>(
                    cs1 * state.slots[ec].distance,
                    0,
                    sn1 * state.slots[ec].distance
                )
                state.slots[ec].vecBNow = base

                let height = state.slots[ec].height[order]
                var rx = EffectSpace.cosine(degrees: Int(state.slots[ec].riseAngle)) * height
                let ry = EffectSpace.sine(degrees: Int(state.slots[ec].riseAngle)) * height

                if ec == 2 {
                    angle = 90 - angle
                } else if ec == 1 {
                    angle = 270 - angle
                } else if ec == 0 {
                    angle = 450 - angle
                } else {
                    angle = 630 - angle
                }
                if angle >= 360 {
                    angle -= 360
                }

                sn1 = EffectSpace.sine(degrees: angle)
                cs1 = EffectSpace.cosine(degrees: angle)
                let rz = sn1 * rx
                rx = cs1 * rx

                let top = SIMD3<Float>(base.x + rx, -ry, base.z + rz)
                state.slots[ec].vecTNow = top

                let offsetX = Float(state.slots[ec].flag1[0])
                let offsetZ = Float(state.slots[ec].flag1[1])
                let offset = SIMD3<Float>(offsetX, 0, offsetZ)

                let vec1 = top + offset
                let vec2 = base + offset
                let vec3 = state.slots[ec].vecTPre + offset
                let vec4 = state.slots[ec].vecBPre + offset

                if order > 0 {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        texPart: order - 1,
                        alphaB: state.slots[ec].alphaB,
                        alphaT: state.slots[ec].alphaB,
                        v1: vec4,
                        v2: vec2,
                        v3: vec1,
                        v4: vec3,
                        textureIndex: 0
                    )
                }

                order += 1
                if order >= 21 {
                    order = 20
                }

                state.slots[ec].vecTPre = top
                state.slots[ec].vecBPre = base
                count += basicAngle
            }
        }
    }

    // MARK: - Primitive 36

    /// Motion update for primitive `36` low-polygon expanding wave rings at 60Hz.
    func primCasting36() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            state.slots[index].distance += 0.04
            state.slots[index].riseAngle -= 1
            if state.slots[index].riseAngle < 10 {
                state.slots[index].riseAngle = 10
                state.slots[index].alphaB = 0
            }

            if state.slots[index].distance < 2.5 {
                state.slots[index].alphaB += 20
            } else {
                state.slots[index].alphaB -= 2
                if state.slots[index].alphaB < 1 {
                    state.slots[index].alphaB = 0
                    state.slots[index].distance = 2.1399999
                    state.slots[index].riseAngle = 74
                }
            }

            applyWaveSlotHeightsFixed(slotIndex: index, amplitude: 0.3)
        }
    }

    // MARK: - Primitive 41

    /// Motion update for primitive `41` delayed rising casting ring at 60Hz.
    func primCasting41() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            state.slots[index].rotStart += 1
            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            if state.slots[index].alphaT == 1 && process > 250 {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 1)
            }

            if process >= 800 {
                state.slots[index].maxHeight = max(0, state.slots[index].maxHeight - 1.0)
            }

            let maxHeight = state.slots[index].maxHeight
            let value: Float = if process < 200 {
                0
            } else if process <= 290 {
                max(0, EffectSpace.sine(degrees: process - 200) * maxHeight)
            } else {
                max(0, maxHeight)
            }
            for sample in 0..<21 {
                state.slots[index].height[sample] = value
            }
        }
    }

    // MARK: - Primitive 50

    /// Motion update for primitive `50` oscillating-radius casting ring at 60Hz.
    func primCasting50() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            state.slots[index].alphaT += 1
            if state.slots[index].alphaT >= 360 {
                state.slots[index].alphaT -= 360
            }

            state.slots[index].distance = EffectSpace.sine(degrees: Int(state.slots[index].alphaT)) + 3.0
            state.slots[index].rotStart += 3
            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            let phase = index * 45
            let angle = phase < 90 ? process + index * 90 : (process + phase) * 2
            let waveSin = EffectSpace.sine(degrees: angle % 360)
            let maxHeight = state.slots[index].maxHeight
            for sample in 0..<21 {
                let base = EffectSpace.sine(degrees: sample * 9) * maxHeight
                state.slots[index].height[sample] = base + base * 0.3 * waveSin
            }
        }
    }

    // MARK: - Primitive 57

    /// Motion update for primitive `57` sine-arch casting ring at 60Hz.
    func primCasting57() {
        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            state.slots[index].rotStart += Int16(5 - index)
            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            guard process > 0 else {
                continue
            }

            if state.slots[index].flag1[0] == 0 {
                if process * 2 < 180 {
                    if process * 2 > 134 {
                        state.slots[index].alphaB = max(0, state.slots[index].alphaB - 1)
                    }
                } else {
                    state.slots[index].flag1[0] = 1
                }
                state.slots[index].maxHeight = Float(state.slots[index].flag1[1]) * EffectSpace.sine(degrees: process * 2)
            } else {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 10)
            }

            let phase = index * 90
            let angle = phase < 180 ? process + phase : (process + index * 30) * 3
            let waveSin = EffectSpace.sine(degrees: angle % 360)
            let maxHeight = state.slots[index].maxHeight
            for sample in 0..<21 {
                state.slots[index].height[sample] = maxHeight + EffectSpace.sine(degrees: sample * 9) * maxHeight * 0.3 * waveSin
            }
        }
    }

    // MARK: - Primitive 60

    /// Motion update for primitive `60` and `PP_HEAL_LOW` (110) pulsing casting columns at 60Hz.
    func primPulsingColumns(context: EffectTickContext) {
        if state.slots[0].flag1[0] == 33 {
            let yaw = Int(context.world.cameraYawDegrees)
            state.slots[2].alphaT = Int16(((360 - yaw) % 360 + 360) % 360)
        }

        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            let mode = state.slots[index].flag1[0]
            if mode == 1 {
                state.slots[index].rotStart += Int16(index + 8)
            } else if mode == 2 {
                state.slots[index].rotStart += Int16(index < 2 ? index + 4 : index + 2)
            } else if mode == 3 {
                state.slots[index].rotStart += Int16(index + 6)
            }

            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            if process < Int(state.slots[index].alphaT) || state.slots[index].alphaT < 0 {
                if process < 16 {
                    if mode == 2 {
                        state.slots[index].alphaB += 3
                    } else if mode == 3 {
                        state.slots[index].alphaB += 2
                    } else {
                        state.slots[index].alphaB += 5
                    }

                    if state.slots[index].alphaB > 180 {
                        state.slots[index].alphaB = 180
                    }
                }
            } else {
                state.slots[index].alphaB -= 2
                if state.slots[index].alphaB < 0 {
                    state.slots[index].alphaB = 0
                }
            }

            let maxHeight = state.slots[index].maxHeight
            for column in 0..<21 {
                let kind = state.slots[index].flag1[column]
                if kind == 0 || kind == 33 {
                    let phase: Int
                    if index == 0 {
                        phase = column * 34 + process * 4
                    } else if index == 1 {
                        phase = column * 34 + process * 3
                    } else {
                        phase = (process + column * 17) * 2
                    }

                    var height = maxHeight * 0.25 * EffectSpace.sine(degrees: phase % 360) + maxHeight * 0.75
                    if process <= 90 {
                        height *= EffectSpace.sine(degrees: process)
                    }
                    state.slots[index].height[column] = max(0, height)
                } else if kind == 1 || kind == 3 {
                    var height = maxHeight
                    if process <= 90 {
                        height *= EffectSpace.sine(degrees: process)
                    }
                    state.slots[index].height[column] = height
                } else if kind == 2 {
                    if process <= 45 {
                        state.slots[index].height[column] = maxHeight * EffectSpace.sine(degrees: process * 4)
                    } else {
                        state.slots[index].height[column] = 0
                    }
                }
            }
        }
    }

    // MARK: - Primitive 63

    /// Motion update for primitive `63` concentric ripple rings at 60Hz.
    func primRippleRings() {
        followMaster()

        let mode = state.slots[3].alphaT
        for index in 0..<3 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            if index == 0 {
                state.slots[3].process += 1
            }

            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            if mode == 3 {
                state.slots[index].distance -= 0.25
                if state.slots[index].distance < 7.0 {
                    if state.slots[index].distance < 0 {
                        state.slots[index].distance = 0
                    }
                    state.slots[index].alphaB -= 7
                    if state.slots[index].alphaB < 0 {
                        state.slots[index].alphaB = 0
                        if state.slots[3].process > 1400 {
                            state.slots[index].life = 0
                        } else {
                            state.slots[index].process = 0
                            state.slots[index].distance = 14.0
                        }
                    }
                }
            } else {
                state.slots[index].distance += 0.5
                if state.slots[index].distance > 7.0 {
                    let decay: Int16 = switch mode {
                    case 4: 5
                    case 5: 8
                    default: 15
                    }
                    state.slots[index].alphaB -= decay
                    if state.slots[index].alphaB < 0 {
                        state.slots[index].alphaB = 0
                        if (state.slots[3].process > 120 && (mode == 1 || mode == 4 || mode == 5)) || state.slots[3].process > 1400 {
                            state.slots[index].life = 0
                        } else {
                            state.slots[index].process = 0
                            state.slots[index].distance = 0
                        }
                    }
                }
            }

            let updatedProcess = state.slots[index].process
            if mode != 3 {
                if updatedProcess < 10 {
                    if mode == 4 {
                        state.slots[index].alphaB = min(40, state.slots[index].alphaB + 4)
                    } else {
                        let limit: Int16 = mode == 5 ? 120 : 240
                        state.slots[index].alphaB = min(limit, state.slots[index].alphaB + 24)
                    }
                }
            } else if updatedProcess < 20 {
                state.slots[index].alphaB = min(240, state.slots[index].alphaB + 12)
            }

            var height = state.slots[index].maxHeight
            if updatedProcess <= 10 {
                height *= EffectSpace.sine(degrees: updatedProcess * 9)
            }
            for column in 0..<21 {
                state.slots[index].height[column] = height
            }
        }
    }

    // MARK: - PP_3DCASTING_4 (65)

    /// Motion update for `PP_3DCASTING_4` (65) inward-shrinking casting rings at 60Hz.
    func prim3DCasting4() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            state.slots[index].distance -= 0.05

            if state.slots[index].distance <= 0 {
                state.slots[index].distance = 10.0
                state.slots[index].alphaB = 0
            }

            state.slots[index].riseAngle = Int16(90.0 - state.slots[index].distance * 9.0)
            state.slots[index].maxHeight = state.slots[index].distance

            if state.slots[index].process >= state.duration - 40 {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 3)
            } else if state.slots[index].alphaB < 70 {
                state.slots[index].alphaB += 1
            }

            let height = max(0, state.slots[index].maxHeight)
            for sample in 0..<21 where state.slots[index].flag1[sample] == 0 {
                state.slots[index].height[sample] = height
            }
        }
    }

    // MARK: - PP_ASURACASTING (68)

    /// Motion update for `PP_ASURACASTING` (68) layered billboard halos at 60Hz.
    func primAsuraCasting(context: EffectTickContext) {
        faceCamera(world: context.world)

        if state.slots[0].flag1[4] == 1 {
            followMaster()
        }

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            let mode = state.slots[index].flag1[4]
            if mode == 2 {
                if process < 20 {
                    for layer in 1...10 {
                        let cap = Float(10 + layer * 23)
                        state.slots[index].height[layer] = min(cap, state.slots[index].height[layer] + 13.0)
                    }
                } else {
                    for layer in 1..<9 {
                        state.slots[index].height[layer] = max(0, state.slots[index].height[layer] - 2.0)
                    }
                    if process > 100 {
                        shrinkHaloLayer(slotIndex: index, layer: 9, growth: 1.005)
                        shrinkHaloLayer(slotIndex: index, layer: 10, growth: 1.005)
                    }
                }
                continue
            }

            if process < 20 {
                for layer in 1...10 {
                    let cap = Float(50 + layer * 20)
                    state.slots[index].height[layer] = min(cap, state.slots[index].height[layer] + 13.0)
                }
            } else {
                for layer in 1..<10 {
                    state.slots[index].height[layer] = max(0, state.slots[index].height[layer] - 5.0)
                }
                if process > (mode != 4 ? 140 : 25) {
                    shrinkHaloLayer(slotIndex: index, layer: 10, growth: 1.01)
                }
            }

            if process < 50 && mode != 4 {
                state.slots[index].distance -= 0.1
            }
        }
    }

    // MARK: - PP_3DCASTING_5 (107)

    /// Motion update for `PP_3DCASTING_5` (107) outward-expanding wave rings at 60Hz.
    func prim3DCasting5() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            state.slots[index].distance += 0.1

            if state.slots[index].distance >= 13.0 {
                state.slots[index].distance = 3.0
                state.slots[index].alphaB = 0
                if state.slots[index].process > 50 {
                    state.slots[index].life = 0
                }
            }

            var maxHeight = state.slots[index].distance - 3.0
            if maxHeight > 5.0 {
                maxHeight = 10.0 - maxHeight
                if state.slots[index].alphaB > 0 {
                    state.slots[index].alphaB -= 2
                }
            } else {
                state.slots[index].alphaB += 2
            }

            maxHeight *= 2.0
            state.slots[index].maxHeight = maxHeight
            state.slots[index].riseAngle = Int16(90.0 - (state.slots[index].distance - 3.0) * 5.0)

            let height = max(0, maxHeight)
            for sample in 0..<21 where state.slots[index].flag1[sample] == 0 {
                state.slots[index].height[sample] = height
            }
        }
    }

    // MARK: - PP_FLOWERCAST (108)

    /// Motion update for `PP_FLOWERCAST` (108) undulating petal casting rings at 60Hz.
    func primFlowerCast() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            let sinWave = EffectSpace.sine(degrees: (process % 90) * 4) * 2.5
            state.slots[index].maxHeight = state.slots[index].vecTNow.y + sinWave

            if state.slots[index].riseAngle >= 360 {
                state.slots[index].riseAngle -= 360
            }
            if state.slots[index].riseAngle < 0 {
                state.slots[index].riseAngle += 360
            }

            if process > 110 {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 1)
            } else if process < 20 {
                state.slots[index].alphaB = min(180, state.slots[index].alphaB + 5)
            }

            let maxHeight = state.slots[index].maxHeight
            for sample in 0..<21 where state.slots[index].flag1[sample] == 0 {
                let sinLimit = sample * 9
                let limitHeight = maxHeight * EffectSpace.sine(degrees: sinLimit)
                var value = process <= 90 ? limitHeight * EffectSpace.sine(degrees: process) : limitHeight
                if value > limitHeight {
                    value = limitHeight
                    state.slots[index].flag1[sample] = 1
                }
                state.slots[index].height[sample] = max(0, value)
            }
        }
    }

    // MARK: - PP_HEAL_LOW (110)

    /// Geometry submission for `PP_HEAL_LOW` (110) 10-segment low-polygon casting rings.
    func render3DCastingLowPolygon(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let heartAngle = Int(state.slots[2].alphaT)
        let heartCos = EffectSpace.cosine(degrees: heartAngle)
        let heartSin = EffectSpace.sine(degrees: heartAngle)

        for slot in state.slots where slot.life == 1 {
            let fullDisplayAngle = Int(slot.fullDisplayAngle)
            let basicAngle = fullDisplayAngle / 10
            guard basicAngle > 0 else {
                continue
            }

            let riseAngle = Int(slot.riseAngle)
            let riseCos = EffectSpace.cosine(degrees: riseAngle)
            let riseSin = EffectSpace.sine(degrees: riseAngle)

            var order = 0
            var vec1 = SIMD3<Float>.zero
            var vec3 = SIMD3<Float>.zero

            var count = 0
            while count <= fullDisplayAngle {
                var angle = (Int(slot.rotStart) + count) % 360
                if angle < 0 {
                    angle += 360
                }
                if fullDisplayAngle == 360 && order == 10 {
                    angle = Int(slot.rotStart)
                }

                let cs1 = EffectSpace.cosine(degrees: angle)
                let sn1 = EffectSpace.sine(degrees: angle)

                var vec2 = SIMD3<Float>(
                    cs1 * slot.distance,
                    0,
                    sn1 * slot.distance
                )

                let height = slot.height[order]
                let rx = riseCos * height
                let ry = riseSin * height

                var vec4 = SIMD3<Float>(
                    vec2.x + cs1 * rx,
                    -ry,
                    vec2.z + sn1 * rx
                )

                if slot.vecBNow.y == 1234.5 {
                    let lx = slot.vecBNow.x
                    let lz = slot.vecBNow.z
                    let offsetX = heartCos * lx - heartSin * lz
                    let offsetZ = heartSin * lx + heartCos * lz
                    vec2.x += offsetX
                    vec4.x += offsetX
                    vec2.z += offsetZ
                    vec4.z += offsetZ
                }

                if order > 0 {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        texPart: order - 1,
                        alphaB: slot.alphaB,
                        alphaT: slot.alphaB,
                        v1: vec1,
                        v2: vec2,
                        v3: vec4,
                        v4: vec3,
                        textureIndex: 0
                    )
                }

                order += 1
                if order > 10 {
                    order = 10
                }

                vec1 = vec2
                vec3 = vec4
                count += basicAngle
            }
        }
    }

    // MARK: - Primitive 113

    /// Motion update for primitive `113` contracting rotating casting rings at 60Hz.
    func primCasting113() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            state.slots[index].rotStart += 4
            if state.slots[index].rotStart > 359 {
                state.slots[index].rotStart -= 360
            }

            if process < 31 {
                state.slots[index].alphaB = min(160, state.slots[index].alphaB + 8)
            }

            state.slots[index].distance -= 0.2

            let maxHeight = state.slots[index].maxHeight
            for sample in 0..<21 where state.slots[index].flag1[sample] == 0 {
                let limitHeight = EffectSpace.sine(degrees: sample * 9) * maxHeight
                if process < 91 {
                    state.slots[index].height[sample] = limitHeight * EffectSpace.sine(degrees: process)
                }
                if state.slots[index].height[sample] > limitHeight {
                    state.slots[index].height[sample] = limitHeight
                    state.slots[index].flag1[sample] = 1
                }
                if state.slots[index].height[sample] < 0 {
                    state.slots[index].height[sample] = 0
                }
            }
        }
    }

    // MARK: - PP_ACIDDEMON (118)

    /// Motion update for `PP_ACIDDEMON` (118) accelerating expanding casting rings at 60Hz.
    func primAcidDemon() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process

            let deltaRot: Int16 = index == 3 ? Int16(2 + Int.random(in: 0..<2)) : Int16(4 + Int.random(in: 0..<3))
            state.slots[index].rotStart += deltaRot
            if state.slots[index].rotStart >= 360 {
                state.slots[index].rotStart -= 360
            }

            if process >= 40 {
                state.slots[index].alphaB = max(0, state.slots[index].alphaB - 15)
            } else if process < 20 {
                state.slots[index].alphaB = min(80, state.slots[index].alphaB + 5)
            }

            state.slots[index].maxHeight *= index == 3 ? 1.025 : 1.005
            let maxHeight = state.slots[index].maxHeight

            for sample in 0..<21 {
                let limitHeight = EffectSpace.sine(degrees: sample * 9) * maxHeight
                if process <= 90 {
                    state.slots[index].height[sample] = limitHeight * EffectSpace.sine(degrees: process)
                } else {
                    state.slots[index].flag1[sample] = 1
                }
                if state.slots[index].height[sample] > limitHeight {
                    state.slots[index].flag1[sample] = 1
                }
                if state.slots[index].height[sample] < 0 {
                    state.slots[index].height[sample] = 0
                }
            }
        }
    }

    // MARK: - Primitive 139

    /// Motion update for primitive `139` color-cycling breathing wave rings at 60Hz.
    func primBreathingWave() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            switch process % 100 {
            case 0: state.size = 4.0
            case 25: state.size = 6.0
            case 50: state.size = 7.0
            case 75: state.size = 8.0
            default: break
            }

            guard process > 0 else {
                continue
            }

            state.slots[index].riseAngle -= 1
            state.slots[index].distance += 0.07
            if state.slots[index].riseAngle < 10 {
                state.slots[index].riseAngle = 10
                state.slots[index].alphaB = 0
            }

            if state.slots[index].distance >= 4.0 {
                state.slots[index].alphaB -= 3
                if state.slots[index].alphaB <= 0 {
                    state.slots[index].alphaB = 0
                    if process < state.duration - 30 {
                        state.slots[index].distance = 3.37
                        state.slots[index].riseAngle = state.slots[index].alphaT == 22 ? 64 : 74
                    }
                }
            } else {
                state.slots[index].alphaB += state.slots[index].alphaT == 22 ? 5 : 10
            }

            applyWaveSlotHeightsFixed(slotIndex: index, amplitude: 0.3)
        }
    }

    // MARK: - Primitive 147

    /// Motion update for primitive `147` rising fan halo layers at 60Hz.
    func primRisingFan(context: EffectTickContext) {
        faceCamera(world: context.world)

        if state.slots[0].flag1[4] == 1 {
            followMaster()
        }

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            let process = state.slots[index].process
            guard process > 0 else {
                continue
            }

            if process < 20 {
                for layer in 1...10 {
                    let cap = Float(50 + layer * 20)
                    state.slots[index].height[layer] = min(cap, state.slots[index].height[layer] + 10.0)
                }
            } else {
                for layer in 1..<10 {
                    state.slots[index].height[layer] = max(0, state.slots[index].height[layer] - 4.0)
                }
                let mode = state.slots[index].flag1[4]
                if (mode == 6 || mode == 7) && process > 90 {
                    shrinkHaloLayer(slotIndex: index, layer: 10, growth: 1.01)
                }
            }

            if process < 50 {
                state.slots[index].distance -= 0.2
            }
        }
    }

    // MARK: - Primitive 169

    /// Motion update for primitive `169` low-polygon offset expanding wave rings at 60Hz.
    func primCasting169() {
        followMaster()

        for index in 0..<4 where state.slots[index].life == 1 {
            state.slots[index].process += 1
            state.slots[index].distance += 0.04
            state.slots[index].riseAngle -= 1
            if state.slots[index].riseAngle < 10 {
                state.slots[index].riseAngle = 10
                state.slots[index].alphaB = 0
            }

            let baseDistance = state.slots[index].vecTNow.x
            if state.slots[index].distance < baseDistance + 1.0 {
                state.slots[index].alphaB = min(200, state.slots[index].alphaB + 10)
            } else {
                state.slots[index].alphaB -= 2
                if state.slots[index].alphaB < 1 {
                    state.slots[index].alphaB = 0
                    state.slots[index].distance = baseDistance
                    state.slots[index].riseAngle = 74
                }
            }

            applyWaveSlotHeightsFixed(slotIndex: index, amplitude: 0.3)
        }
    }

    // MARK: - Shared Halo Renderer & Helpers

    /// Geometry submission for `PP_ASURACASTING` (68) and primitive `147` layered billboard halos.
    func renderHaloLayers(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        let rot0 = state.slots[0].alphaT
        let rot1 = state.slots[1].alphaT

        for ec in 0..<4 where state.slots[ec].life == 1 {
            let mode = state.slots[ec].flag1[4]
            let textureIndex = Int(UInt8(bitPattern: state.slots[ec].flag1[0]))
            let isWide = (mode == 6 || mode == 7)
            let angle1 = isWide ? 35 : 45
            let angle2 = isWide ? 145 : 135
            let angle3 = (angle2 + (isWide ? 70 : 90)) % 360
            let angle4 = (angle3 + (isWide ? 110 : 90)) % 360
            let lift: Float = (mode == 2 || mode == 4 || isWide) ? 40.0 : 30.0
            let shiftX = state.slots[ec].height[0]

            for i in stride(from: 10, through: 1, by: -1) {
                var step = 10 - i
                if mode != 2 && mode != 4 && mode != 5 {
                    step *= 3
                }
                let radius = Float(step) + state.slots[ec].distance

                var bPre = SIMD3<Float>(radius * EffectSpace.cosine(degrees: angle1), 0, EffectSpace.sine(degrees: angle1) * radius)
                var bNow = SIMD3<Float>(radius * EffectSpace.cosine(degrees: angle2), 0, EffectSpace.sine(degrees: angle2) * radius)
                var tNow = SIMD3<Float>(radius * EffectSpace.cosine(degrees: angle3), 0, EffectSpace.sine(degrees: angle3) * radius)
                var tPre = SIMD3<Float>(radius * EffectSpace.cosine(degrees: angle4), 0, EffectSpace.sine(degrees: angle4) * radius)
                state.slots[ec].vecBPre = bPre
                state.slots[ec].vecBNow = bNow
                state.slots[ec].vecTNow = tNow
                state.slots[ec].vecTPre = tPre

                var vec1 = SIMD3<Float>(shiftX + bPre.x, 0, bPre.z)
                var vec2 = SIMD3<Float>(shiftX + bNow.x, 0, bNow.z)
                var vec3 = SIMD3<Float>(shiftX + tNow.x, 0, tNow.z)
                var vec4 = SIMD3<Float>(shiftX + tPre.x, 0, tPre.z)
                Self.towardScreen(&vec1, &vec2, &vec3, &vec4, rot0: rot0, rot1: rot1)
                vec1.y -= lift
                vec2.y -= lift
                vec3.y -= lift
                vec4.y -= lift

                let alpha = Int(state.slots[ec].height[i])
                if alpha > 0 {
                    let clampedAlpha = Int16(clamping: alpha)
                    switch mode {
                    case 0:
                        renderTeiRect(into: &collector, assets: assets, alpha: clampedAlpha, v1: vec2, v2: vec1, v3: vec4, v4: vec3, blendSelector: 1, textureIndex: textureIndex, isWorldPosition: false, red: 0, green: 0, blue: 0)
                    case 3:
                        if i == 10 {
                            renderTeiRect(into: &collector, assets: assets, alpha: clampedAlpha / 2, v1: vec2, v2: vec1, v3: vec4, v4: vec3, blendSelector: 1, textureIndex: textureIndex, isWorldPosition: false, red: 10, green: 10, blue: 10)
                        }
                        renderTeiRect(into: &collector, assets: assets, alpha: clampedAlpha, v1: vec2, v2: vec1, v3: vec4, v4: vec3, blendSelector: 1, textureIndex: textureIndex, isWorldPosition: false, red: 10, green: 10, blue: 10)
                    case 6, 7:
                        renderTeiRect(into: &collector, assets: assets, alpha: clampedAlpha, v1: vec2, v2: vec1, v3: vec4, v4: vec3, blendSelector: 0, textureIndex: textureIndex, isWorldPosition: false, red: 255, green: 255, blue: 255)
                    default:
                        renderTeiRect(into: &collector, assets: assets, alpha: clampedAlpha, v1: vec2, v2: vec1, v3: vec4, v4: vec3, blendSelector: 1, textureIndex: textureIndex, isWorldPosition: false, red: 255, green: 255, blue: 255)
                    }
                }

                if mode == 5 || isWide {
                    bPre *= 1.1
                    bNow *= 1.1
                    tPre *= 1.1
                    tNow *= 1.1
                    state.slots[ec].vecBPre = bPre
                    state.slots[ec].vecBNow = bNow
                    state.slots[ec].vecTPre = tPre
                    state.slots[ec].vecTNow = tNow

                    vec1 = SIMD3<Float>(bPre.x + shiftX, bPre.y, bPre.z)
                    vec2 = SIMD3<Float>(bNow.x + shiftX, bNow.y, bNow.z)
                    vec3 = SIMD3<Float>(tNow.x + shiftX, tNow.y, tNow.z)
                    vec4 = SIMD3<Float>(tPre.x + shiftX, tPre.y, tPre.z)
                    Self.towardScreen(&vec1, &vec2, &vec3, &vec4, rot0: rot0, rot1: rot1)
                    let outerLift: Float = mode == 5 ? 30.0 : 40.0
                    vec1.y -= outerLift
                    vec2.y -= outerLift
                    vec3.y -= outerLift
                    vec4.y -= outerLift

                    if alpha > 0 {
                        let clampedAlpha = Int16(clamping: alpha)
                        let (red, green, blue): (UInt8, UInt8, UInt8) = mode == 7 ? (255, 5, 5) : (5, 5, 255)
                        renderTeiRect(into: &collector, assets: assets, alpha: clampedAlpha, v1: vec2, v2: vec1, v3: vec4, v4: vec3, blendSelector: 0, textureIndex: textureIndex, isWorldPosition: false, red: red, green: green, blue: blue)
                    }
                }
            }
        }
    }

    private func shrinkHaloLayer(slotIndex: Int, layer: Int, growth: Float) {
        let height = state.slots[slotIndex].height[layer] - 5.0
        if height > 0 {
            state.slots[slotIndex].distance *= growth
        }
        state.slots[slotIndex].height[layer] = max(0, height)
    }

    private func applyWaveSlotHeightsFixed(slotIndex index: Int, amplitude: Float) {
        let process = state.slots[index].process
        let offset = index * 45
        let angle = offset < 90 ? process + index * 90 : (process + offset) * 2
        let waveSin = EffectSpace.sine(degrees: angle % 360)
        let maxHeight = state.slots[index].maxHeight
        for sample in 0..<21 {
            state.slots[index].height[sample] = maxHeight + EffectSpace.sine(degrees: sample * 9) * maxHeight * amplitude * waveSin
        }
    }

    // MARK: - Shared Renderers

    /// Geometry submission for `PP_3DCASTING` (23) .. `PP_3DCASTING_5` (107) and primitive `60` 20-segment casting rings.
    func render3DCasting(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        for slot in state.slots where slot.life == 1 {
            let fullDisplayAngle = Int(slot.fullDisplayAngle)
            let basicAngle = fullDisplayAngle / 20
            guard basicAngle > 0 else {
                continue
            }

            let baseY: Float
            if slot.maxHeight == 6.001 {
                baseY = -2.0
            } else if slot.maxHeight == 24.001 {
                baseY = -1.0
            } else {
                baseY = 0.0
            }

            let riseAngle = Int(slot.riseAngle)
            let riseCos = EffectSpace.cosine(degrees: riseAngle)
            let riseSin = EffectSpace.sine(degrees: riseAngle)

            var order = 0
            var vec1 = SIMD3<Float>.zero
            var vec3 = SIMD3<Float>.zero

            var count = 0
            while count <= fullDisplayAngle {
                var angle = (count + Int(slot.rotStart)) % 360
                if angle < 0 {
                    angle += 360
                }
                if fullDisplayAngle == 360 && order == 20 {
                    angle = Int(slot.rotStart)
                }

                let cs1 = EffectSpace.cosine(degrees: angle)
                let sn1 = EffectSpace.sine(degrees: angle)

                let vec2 = SIMD3<Float>(
                    cs1 * slot.distance,
                    baseY,
                    sn1 * slot.distance
                )

                let height = slot.height[order]
                let rx = riseCos * height
                let ry = riseSin * height

                let vec4 = SIMD3<Float>(
                    vec2.x + cs1 * rx,
                    baseY - ry,
                    vec2.z + sn1 * rx
                )

                if order > 0 {
                    renderTeiRect(
                        into: &collector,
                        assets: assets,
                        texPart: order - 1,
                        alphaB: slot.alphaB,
                        alphaT: slot.alphaB,
                        v1: vec1,
                        v2: vec2,
                        v3: vec4,
                        v4: vec3,
                        textureIndex: 0
                    )
                }

                order += 1
                if order >= 21 {
                    order = 20
                }

                vec1 = vec2
                vec3 = vec4
                count += basicAngle
            }
        }
    }
}
