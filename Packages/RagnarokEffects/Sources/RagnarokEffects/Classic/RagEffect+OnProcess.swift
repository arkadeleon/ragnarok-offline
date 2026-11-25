//
//  RagEffect+OnProcess.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

import Foundation
import simd

extension RagEffect {
    public nonisolated static let supportedEffectIDs: [EffectID] = [
        .ef_entry,
        .ef_grandcross2,
        .ef_guard,
        .ef_heal,
        .ef_heal3,
        .ef_waterball3,
    ]

    private nonisolated static let supportedEffectIDSet: Set<EffectID> = Set(supportedEffectIDs)

    public nonisolated static func supports(_ effectID: EffectID) -> Bool {
        supportedEffectIDSet.contains(effectID)
    }

    static func make(id: UUID, request: EffectSpawnRequest) -> RagEffect? {
        guard supports(request.effectID) else {
            return nil
        }

        return RagEffect(id: id, request: request) { effect, context in
            effect.processClassicEffect(context: context)
        }
    }

    func processClassicEffect(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_entry:
            entry(context: context)
        case .ef_grandcross2:
            grandCrossRings(angle: 0, kind: 1, context: context)
            grandCross2(flag: 1, context: context)
        case .ef_guard:
            kyrieGuard(texturePath: "effect\\guardK.tga", kind: 0, context: context)
        case .ef_heal:
            healBurst(texturePath: "effect\\alpha_down.tga", flag: 0, context: context)
        case .ef_heal3:
            healBurst(texturePath: "effect\\alpha_down.tga", flag: 1, context: context)
        case .ef_waterball3:
            waterBallBurst(context: context)
        default:
            return false
        }
        return true
    }

    private func kyrieGuard(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\kyrie_guard.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let secondaryTexture = "effect\\guardK2.tga"
        _ = context.assets?.texture(atPath: texturePath)
        _ = context.assets?.texture(atPath: secondaryTexture)

        let primitive = launchPrimitive(.pp_guard)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 2
        primitive.state.texturePaths = [texturePath, secondaryTexture]
        primitive.state.size = 11.0
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].maxHeight = 7.8
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].distance = 1.0
        primitive.state.slots[0].height[0] = 0
        primitive.state.slots[1].life = 0
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0

        if kind == 2 || kind == 3 || kind == 4 || kind == 5 {
            primitive.state.slots[0].flag1[0] = kind
        } else {
            primitive.state.slots[0].flag1[0] = 0
        }
    }

    private func grandCrossRings(angle: Int16, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\cru_grand cross.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = kind == 0 ? "effect\\ring_white.tga" : "effect\\ring_black.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_gi_3)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = kind == 0 ? 1.0 : 12.0

        let configs: [(rotStart: Int16, offsetX: Int8, offsetZ: Int8)] = [
            (180, 23, 23),
            (90, 23, -23),
            (0, -23, -23),
            (270, -23, 23),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 90
            primitive.state.slots[index].maxHeight = 120.0
            primitive.state.slots[index].alphaB = angle
            primitive.state.slots[index].distance = 19.9
            primitive.state.slots[index].riseAngle = 90
            primitive.state.slots[index].flag1[4] = kind
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].flag1[0] = config.offsetX
            primitive.state.slots[index].flag1[1] = config.offsetZ
        }
    }

    private func grandCross2(flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = flag == 0 ? "effect\\ring_yellow.tga" : "effect\\ring_black.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_grandcross2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 1.0

        for index in 0..<2 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = 60.0
            primitive.state.slots[index].rotStart = Int16(index * 90)
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].height[0] = 24.0
            primitive.state.slots[index].height[1] = 3.2
            primitive.state.slots[index].height[2] = 0
        }
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0
    }

    private func entry(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\ring_blue.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let outer = launchPrimitive(.pp_3dcylinder)
        outer.state.duration = 55
        let outerRotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(outer.state.latitude)))
        let outerRotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(outer.state.longitude)))
        outer.state.transform = outerRotY * outerRotX
        outer.state.accel = -0.00007
        outer.state.longSpeed = -10.0
        outer.state.outerSize = 6.0
        outer.state.outerSpeed = 0.08
        outer.state.innerSize = 5.0
        outer.state.heightSize = 6.5
        outer.state.heightSpeed = -0.1
        outer.state.alpha = 5.0
        outer.state.maxAlpha = 245.0
        outer.state.alphaSpeed = 10.0
        outer.state.fadeOutCnt = outer.state.duration - outer.state.duration / 5
        outer.state.texturePaths = [texturePath]

        let inner = launchPrimitive(.pp_3dcylinder)
        inner.state.duration = 55
        inner.state.arcAngle = 45.0
        inner.state.longSpeed = 10.0
        inner.state.outerSize = 4.5
        inner.state.innerSize = 4.5
        inner.state.heightSpeed = 2.5
        let accel = -(inner.state.heightSpeed / Float(inner.state.duration))
        inner.state.heightAccel = accel + accel
        inner.state.alpha = 160.0
        inner.state.fadeOutCnt = inner.state.duration - inner.state.duration / 3
        inner.state.texturePaths = [texturePath]
    }

    private func waterBallBurst(context: EffectTickContext) {
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

    private func healBurst(texturePath: String, flag: Int8, context: EffectTickContext) {
        let limit = flag != 0 ? 25 : 50

        if stateCnt == 0 {
            let primitive = launchPrimitive(EffectPrimitiveID(rawValue: 60))
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = [texturePath]
            _ = context.assets?.texture(atPath: texturePath)

            if flag == 0 {
                primitive.state.size = 9.0
            } else if flag == 1 {
                primitive.state.size = 5.0
            }

            primitive.state.slots[0].life = 1
            primitive.state.slots[0].process = 0
            primitive.state.slots[0].fullDisplayAngle = 360
            primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[0].alphaB = 0
            primitive.state.slots[0].riseAngle = 90
            primitive.state.slots[0].vecBNow.y = 0

            if flag == 0 {
                primitive.state.slots[0].alphaT = 60
                primitive.state.slots[0].maxHeight = 40.0
                primitive.state.slots[0].distance = 4.6
            } else if flag == 1 {
                primitive.state.slots[0].alphaT = 30
                primitive.state.slots[0].maxHeight = Float(Int.random(in: 0..<20)) + 40.0
                primitive.state.slots[0].distance = 4.5 + Float(Int.random(in: 0..<100)) * 0.005
            }

            for i in 0..<21 {
                primitive.state.slots[0].height[i] = 0
                primitive.state.slots[0].flag1[i] = 0
            }

            primitive.state.slots[1].life = 1
            primitive.state.slots[1].process = 0
            primitive.state.slots[1].fullDisplayAngle = 360
            primitive.state.slots[1].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[1].alphaB = 0
            primitive.state.slots[1].riseAngle = 90
            primitive.state.slots[1].vecBNow.y = 0

            if flag == 0 {
                primitive.state.slots[1].alphaT = 60
                primitive.state.slots[1].maxHeight = 40.0
                primitive.state.slots[1].distance = 4.8
            } else if flag == 1 {
                primitive.state.slots[1].alphaT = 30
                primitive.state.slots[1].maxHeight = primitive.state.slots[0].maxHeight
                primitive.state.slots[1].distance = primitive.state.slots[0].distance + 0.2
            }

            for i in 0..<21 {
                primitive.state.slots[1].height[i] = 0
                primitive.state.slots[1].flag1[i] = 0
            }

            primitive.state.slots[2].life = 0
            primitive.state.slots[3].life = 0

            context.world.playSound(
                named: "_heal_effect.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
            return
        }

        guard stateCnt <= limit, stateCnt % 6 == 0 else {
            return
        }

        if flag == 0 {
            let primitive = launchPrimitive(.pp_particle_up)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = ["effect\\pok1.tga"]
            _ = context.assets?.texture(atPath: "effect\\pok1.tga")
            primitive.state.size = 0
            primitive.position = position

            for i in 0..<4 {
                primitive.state.slots[i].life = 1
                primitive.state.slots[i].process = 0
                primitive.state.slots[i].distance = Float(Int.random(in: 0..<10)) * 0.1 + 2.0
                primitive.state.slots[i].height[8] = 0
                primitive.state.slots[i].alphaB = 0
                primitive.state.slots[i].vecBNow.x = Float(Int.random(in: 0..<13)) + position.x - 6.0
                primitive.state.slots[i].vecBNow.z = Float(Int.random(in: 0..<13)) + position.z - 6.0
                primitive.state.slots[i].vecBNow.y = position.y
                primitive.state.slots[i].rotStart = 0
                primitive.state.slots[i].height[1] = 0
                primitive.state.slots[i].height[2] = Float(Int.random(in: 0..<40)) * 0.01 + 0.3
                primitive.state.slots[i].fullDisplayAngle = 0
                primitive.state.slots[i].flag1[0] = 0
                primitive.state.slots[i].flag1[1] = 0
                primitive.state.slots[i].flag1[2] = 11
                primitive.state.slots[i].height[7] = 0
            }
            return
        }

        if flag == 1 {
            let primitive = launchPrimitive(.pp_particle_up)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = ["effect\\pok1.tga", "effect\\pok3.tga"]
            _ = context.assets?.texture(atPath: "effect\\pok1.tga")
            _ = context.assets?.texture(atPath: "effect\\pok3.tga")
            primitive.state.size = 0
            primitive.position = position

            for i in 0..<4 {
                primitive.state.slots[i].life = 1
                primitive.state.slots[i].process = 0
                primitive.state.slots[i].distance = Float(Int.random(in: 0..<10)) * 0.1 + 2.0
                primitive.state.slots[i].height[8] = 0
                primitive.state.slots[i].alphaB = 0
                primitive.state.slots[i].vecBNow.x = Float(Int.random(in: 0..<13)) + position.x - 6.0
                primitive.state.slots[i].vecBNow.z = Float(Int.random(in: 0..<13)) + position.z - 6.0
                primitive.state.slots[i].vecBNow.y = position.y
                primitive.state.slots[i].rotStart = 0
                primitive.state.slots[i].height[1] = 0
                primitive.state.slots[i].height[2] = Float(Int.random(in: 0..<40)) * 0.01 + 0.4
                primitive.state.slots[i].fullDisplayAngle = 0
                primitive.state.slots[i].flag1[0] = 0
                primitive.state.slots[i].flag1[1] = 1
                primitive.state.slots[i].flag1[2] = 11
                primitive.state.slots[i].height[7] = 0
            }
        }
    }
}
