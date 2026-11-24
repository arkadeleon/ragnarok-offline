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
}
