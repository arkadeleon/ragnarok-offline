//
//  EffectPrimitive+Casting.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

import Foundation
import simd

extension EffectPrimitive {
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

    // MARK: - 3D Casting Motion Variants (`pp_3dcasting` .. `pp_3dcasting_5`, `pp_gi_3`)

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
}
