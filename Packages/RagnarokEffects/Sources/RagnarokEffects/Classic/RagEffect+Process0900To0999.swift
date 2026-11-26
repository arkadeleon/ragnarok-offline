//
//  RagEffect+Process0900To0999.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs0900To0999: [EffectID] = [
        .ef_selfscroll,
        .ef_waterball3,
        .ef_graybody,
    ]

    func process0900To0999(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_selfscroll:
            texturedDoubleSpiral(texturePath: "effect\\shockwave_c.bmp", context: context)
        case .ef_waterball3:
            waterBallBurst(context: context)
        case .ef_graybody:
            if let targetID = targetObjectID ?? ownerObjectID {
                let gray: Float = 105.0 / 255.0
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(gray, gray, gray, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        default:
            return false
        }
        return true
    }

    // MARK: - EF_SELFSCROLL (900)

    /// Spawns dual-layer primitive `166` folding ribbons for `EF_SELFSCROLL` (900).
    func texturedDoubleSpiral(texturePath: String, context: EffectTickContext) {
        guard stateCnt <= 1 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let layers: [(distance: Float, alphaB: Int16, phaseSpeed: Float, shadeFlag: Float)] = [
            (6.0, 205, 0.01, 0.0),
            (10.5, 255, 0.015, 1.0),
        ]

        for layer in layers {
            let primitive = launchPrimitive(166)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.totalTexture = 1
            primitive.state.texturePaths = [texturePath]

            for index in 0..<4 {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = 0
                primitive.state.slots[index].distance = layer.distance
                primitive.state.slots[index].alphaB = layer.alphaB
                primitive.state.slots[index].riseAngle = Int16((stateCnt * 4 + index) * 45)
                primitive.state.slots[index].rotStart = 0
                primitive.state.slots[index].height[0] = -5.0
                primitive.state.slots[index].height[1] = 0
                primitive.state.slots[index].height[9] = 0
                primitive.state.slots[index].height[2] = layer.phaseSpeed
                primitive.state.slots[index].height[3] = layer.shadeFlag
            }
        }
    }

    // MARK: - EF_WATERBALL3 (942)

    /// Spawns `PP_3DCIRCLE` (12) rings and a `PP_3DSPHERE` (14) burst for `EF_WATERBALL3` (942).
    func waterBallBurst(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\wizard_waterball_chulung.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let ringTexture = "effect\\ring_blue.tga"
        let iceTexture = "effect\\ice.tga"
        _ = context.assets?.texture(atPath: ringTexture)
        _ = context.assets?.texture(atPath: iceTexture)

        let firstRing = launchPrimitive(.pp_3dcircle)
        firstRing.state.duration = 30
        firstRing.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
        firstRing.state.latitude = 90.0
        firstRing.state.radiusSpeed = 1.75
        firstRing.state.radiusAccel = -(firstRing.state.radiusSpeed / Float(firstRing.state.duration)) * 0.5
        firstRing.state.innerSize = 12.0
        firstRing.state.alpha = 0
        firstRing.state.alphaSpeed = firstRing.state.maxAlpha / 15.0
        firstRing.state.fadeOutCnt = 10
        firstRing.initSegment()
        firstRing.state.texturePaths = [ringTexture]

        let sphere = launchPrimitive(.pp_3dsphere)
        sphere.state.duration = 30
        sphere.state.radiusSpeed = 1.15
        sphere.state.radiusAccel = -(sphere.state.radiusSpeed / Float(sphere.state.duration)) * 0.5
        sphere.state.longSpeed = 3.0
        sphere.state.alpha = 0
        sphere.state.alphaSpeed = sphere.state.maxAlpha / 15.0
        sphere.state.fadeOutCnt = 10
        sphere.state.texturePaths = [iceTexture]

        let secondRing = launchPrimitive(.pp_3dcircle)
        secondRing.state.duration = 20
        secondRing.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
        secondRing.state.latitude = 90.0
        secondRing.state.radiusSpeed = 1.75
        secondRing.state.radiusAccel = -(secondRing.state.radiusSpeed / Float(secondRing.state.duration)) * 0.5
        secondRing.state.innerSize = 12.0
        secondRing.state.alpha = 0
        secondRing.state.alphaSpeed = secondRing.state.maxAlpha / 15.0
        secondRing.state.fadeOutCnt = 10
        secondRing.initSegment()
        secondRing.state.texturePaths = [ringTexture]
    }
}
