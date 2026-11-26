//
//  RagEffect+Process0700To0799.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs0700To0799: [EffectID] = [
        .ef_infraredscan,
    ]

    func process0700To0799(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_infraredscan:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\INFRAREDSCAN.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            electricFan(fade: 0, context: context)
            electricFan(fade: 1, context: context)
        default:
            return false
        }
        return true
    }

    // MARK: - EF_INFRAREDSCAN (794)

    /// Spawns primitive `135` sweeping electric jitter arcs for `EF_INFRAREDSCAN` (794).
    func electricFan(fade: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\elec1.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(135)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let facingDegrees = (targetObjectID ?? ownerObjectID)
            .flatMap { context.world.targetState(for: $0)?.facingAngle } ?? 0
        var initialAngle = Int16(Int(facingDegrees) - 90)
        if initialAngle < 0 {
            initialAngle += 360
        }

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = 0.1
            primitive.state.slots[index].alphaB = index == 0 ? 250 : Int16(140 - index * 30)
            primitive.state.slots[index].riseAngle = initialAngle
            primitive.state.slots[index].distance = 20.0
            primitive.state.slots[index].height[0] = 0
            primitive.state.slots[index].vecTNow.x = Float(Int.random(in: 0..<11)) * 0.01
            primitive.state.slots[index].vecBNow = SIMD3<Float>(position.x, position.y - 10.0, position.z)
            primitive.state.slots[index].vecTNow.y = 20.0
            for step in 1...20 {
                primitive.state.slots[index].height[step] = 0
                primitive.state.slots[index].flag1[step] = 0
            }
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].alphaT = fade
            primitive.state.slots[index].fullDisplayAngle = 0
        }
    }
}
