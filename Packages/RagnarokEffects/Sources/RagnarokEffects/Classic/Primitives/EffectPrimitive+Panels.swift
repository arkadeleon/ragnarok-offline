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
    // RenderSizedSquare

    // MARK: - Primitive 28
    // RenderSizedSquare

    // MARK: - Primitive 32
    // PrimDriftingOrbs / RenderLayeredGlow

    // MARK: - Primitive 33
    // PrimFieldFireflies / RenderFieldPanel

    // MARK: - Primitive 39
    // RenderSizedSquare

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
    // RenderSizedSquare

    // MARK: - Primitive 79
    // RenderTeiRect

    // MARK: - Primitive 82
    // PrimAuraGlow / RenderTeiFacingSlots

    // MARK: - Primitive 87
    // PrimBubbleSwirl / RenderFieldPanel

    // MARK: - Primitive 88
    // PrimGrowFollow / RenderSizedSquare

    // MARK: - PP_EFFECTTEXTURE2 (95)
    // PrimEffectTexture2 / RenderTeiFacingSlots

    // MARK: - PP_EFFECTTEXTURE_ANI (128)
    // PrimEffectTexture_Ani / RenderTeiFacingSlots

    // MARK: - Primitive 129
    // PrimBobbing / RenderTeiRect

    // MARK: - Primitive 130
    // PrimDriftingSquares / RenderFacingQuads

    // MARK: - Primitive 132
    // RenderColorPanel

    // MARK: - Primitive 138
    // PrimCHOOKGI / RenderTwinFacingSquares

    // MARK: - Primitive 140
    // PrimFrameFade / RenderTeiFacingSlots

    // MARK: - Primitive 142
    // PrimWaterFall / RenderStandingPanels

    // MARK: - Primitive 145
    // PrimDriftingSparks / RenderPillarSquares

    // MARK: - Primitive 150
    // PrimFallingPetals2 / RenderHoverSquares

    // MARK: - Primitive 155
    // PrimWanderingFlames / RenderTwinGlowSquares

    // MARK: - Primitive 157
    // PrimOrbitFade / RenderGlowSquare

    // MARK: - Primitive 161
    // PrimTwinSpin / RenderSizedSquare

    // MARK: - Primitive 166
    // PrimFramePhase / RenderFoldingRibbon

    // MARK: - Primitive 170
    // PrimWanderingFlames2 / RenderTwinGlowSquares

    // MARK: - Primitive 172
    // PrimPoison / Tei_TowardScreen

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

            if state.slots[index].height[8] >= 360 || state.slots[index].height[8] < 0 {
                state.slots[index].height[8] = 0
            }

            let slot = state.slots[index]
            let rx = slot.distance * EffectSpace.sine(degrees: Int(slot.height[8])) * 0.05 + slot.distance

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
