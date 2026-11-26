//
//  RagEffect+TargetModifiers.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import simd

extension RagEffect {
    private var modifierTargetID: EffectTargetID? {
        targetObjectID ?? ownerObjectID
    }

    private static func normalizedRGB(_ rgb: SIMD3<Float>) -> SIMD4<Float> {
        let clamped = simd_clamp(rgb / 255.0, SIMD3<Float>(repeating: 0), SIMD3<Float>(repeating: 1))
        return SIMD4<Float>(clamped, 1)
    }

    /// Mirrors `CRagEffect::SpawnBlurAfterimage()` using `tintRGB` in 0...255 (or `-1` / `-2` sentinels).
    func spawnBlurAfterimage(tintRGB: SIMD3<Float>, context: EffectTickContext) {
        guard let targetID = modifierTargetID else {
            return
        }

        if stateCnt == 9998 {
            stateCnt = 0
        }

        if tintRGB.x == -1 {
            let gb: Float = Int.random(in: 0..<14) == 0 ? 250 : 200
            let color = Self.normalizedRGB(SIMD3<Float>(250, gb, gb))
            context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            return
        }

        if tintRGB.x == -2 {
            let color = Self.normalizedRGB(SIMD3<Float>(250, 250, 200))
            context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            return
        }

        let normalized = Self.normalizedRGB(tintRGB)
        context.world.applyTargetModifier(.tint(color: normalized, durationTicks: 2), to: targetID)

        if duration == 30 || stateCnt % 5 == 0 {
            context.world.applyTargetModifier(
                .afterimage(style: .blur, tint: normalized, durationTicks: 15),
                to: targetID
            )
        }
    }

    /// Mirrors `CRagEffect::SpawnHallucinationOnce()`.
    func spawnHallucinationOnce(tintRGB: SIMD3<Float>, context: EffectTickContext) {
        guard let targetID = modifierTargetID else {
            return
        }

        let normalized = Self.normalizedRGB(tintRGB)
        context.world.applyTargetModifier(.tint(color: normalized, durationTicks: 2), to: targetID)

        if stateCnt == 9998 {
            stateCnt = 0
        } else if stateCnt != 0 {
            return
        }

        context.world.applyTargetModifier(
            .afterimage(style: .hallucination, tint: normalized, durationTicks: 30),
            to: targetID
        )
    }

    /// Mirrors `CRagEffect::SpawnHallucinationTrail()`.
    func spawnHallucinationTrail(tintRGB: SIMD3<Float>? = nil, context: EffectTickContext) {
        guard let targetID = modifierTargetID else {
            return
        }

        let normalizedTint = tintRGB.map(Self.normalizedRGB)
        if let normalizedTint {
            context.world.applyTargetModifier(.tint(color: normalizedTint, durationTicks: 2), to: targetID)
        }

        if stateCnt == 9998 {
            stateCnt = 0
        }

        guard duration == 30 || stateCnt % 5 == 0 else {
            return
        }

        context.world.applyTargetModifier(
            .afterimage(style: .hallucination, tint: normalizedTint, durationTicks: 20),
            to: targetID
        )
    }

    /// Mirrors `CRagEffect::SpawnActorHallucination()`.
    func spawnTargetHallucination(tintRGB: SIMD3<Float>, context: EffectTickContext) {
        guard let targetID = modifierTargetID else {
            return
        }

        let normalized = Self.normalizedRGB(tintRGB)
        context.world.applyTargetModifier(.tint(color: normalized, durationTicks: 2), to: targetID)

        if stateCnt == 9998 {
            stateCnt = 0
        }

        guard duration == 41 || stateCnt % 20 == 0 else {
            return
        }

        context.world.applyTargetModifier(
            .afterimage(style: .hallucination, tint: normalized, durationTicks: 30),
            to: targetID
        )
    }

    /// Mirrors `CRagEffect::SpawnPaleBlur()`.
    func spawnPaleBlur(context: EffectTickContext) {
        guard let targetID = modifierTargetID else {
            return
        }

        let normalized = Self.normalizedRGB(SIMD3<Float>(155, 155, 255))
        context.world.applyTargetModifier(.tint(color: normalized, durationTicks: 2), to: targetID)

        if stateCnt == 9998 {
            stateCnt = 0
        } else if stateCnt % 20 != 0 {
            return
        }

        context.world.applyTargetModifier(
            .afterimage(style: .paleBlur, tint: normalized, durationTicks: 20),
            to: targetID
        )
    }

    /// Mirrors `CRagEffect::SpawnLightBlur()`.
    func spawnLightBlur(context: EffectTickContext) {
        guard let targetID = modifierTargetID else {
            return
        }

        let normalized = Self.normalizedRGB(SIMD3<Float>(225, 225, 255))
        context.world.applyTargetModifier(.tint(color: normalized, durationTicks: 2), to: targetID)

        if stateCnt == 9998 {
            stateCnt = 0
        } else if stateCnt % 10 != 0 {
            return
        }

        context.world.applyTargetModifier(
            .afterimage(style: .lightBlur, tint: normalized, durationTicks: 20),
            to: targetID
        )
    }

    /// Mirrors `CRagEffect::AssassinCloaking()`.
    func assassinCloaking(context: EffectTickContext) {
        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\assasin_cloaking.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        guard let targetID = modifierTargetID else {
            return
        }
        context.world.applyTargetModifier(.cloaking(alpha: 50.0 / 255.0), to: targetID)
    }

    /// Mirrors `CRagEffect::AssassinCloakingClear()`.
    func assassinCloakingClear(context: EffectTickContext) {
        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\assasin_cloaking.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        guard let targetID = modifierTargetID else {
            return
        }
        context.world.applyTargetModifier(.cloaking(alpha: 50.0 / 255.0), to: targetID)
        context.world.applyTargetModifier(.tint(color: SIMD4<Float>(0, 0, 0, 1), durationTicks: 2), to: targetID)
    }

    /// Mirrors `CRagEffect::ColoredFlash()`.
    func coloredFlash(flag: Int8, red: UInt8, green: UInt8, blue: UInt8, context: EffectTickContext) {
        if stateCnt == 99_999_998 {
            stateCnt = 0
            duration = 99_999_999
        } else if stateCnt != 0 {
            return
        }

        let texturePath = "effect\\white02.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitiveID = EffectPrimitiveID(rawValue: 172)
        let primitive = launchPrimitive(primitiveID)
        primitive.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        position.y -= 9.0

        for index in 0..<EffectPrimitiveState.slotCount {
            primitive.state.slots[index].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].maxHeight = 0
        primitive.state.slots[0].alphaB = 0
        primitive.state.argb = UInt32(red) | (UInt32(green) << 8) | (UInt32(blue) << 16)
        primitive.state.slots[0].flag1[10] = flag
    }

    // MARK: - Body Modifier Helpers

    static func shrinkPulseScale(phase: Int) -> Float {
        let index = max(phase * 4 + 90, 90)
        guard index < 270 else {
            return 0.5
        }
        return (EffectSpace.sine(degrees: index) + 1.0) * 0.25 + 0.5
    }

    static func growPulseScale(phase: Int) -> Float {
        let index = max(phase * 4 + 90, 90)
        guard index < 270 else {
            return 1.5
        }
        return 1.5 - (EffectSpace.sine(degrees: index) + 1.0) * 0.25
    }

    static func swingRollAndOffset(phase: Int, radius: Float = 10.0) -> (degrees: Float, offset: SIMD2<Float>) {
        guard phase <= 36 else {
            return (0, .zero)
        }
        var angle = 180.0 - EffectSpace.sine(degrees: 90 + phase * 5) * 180.0
        if angle >= 360.0 {
            angle -= 360.0
        }
        let angleIndex = Int(angle)
        let offsetX = EffectSpace.sine(degrees: angleIndex) * radius
        let offsetY = radius * (1.0 - EffectSpace.cosine(degrees: angleIndex))
        return (angle, SIMD2<Float>(offsetX, offsetY))
    }

    static func tintedOverlayAlpha(phase: Int) -> Float? {
        if phase <= 10 {
            return Float(phase * 15) / 255.0
        } else if phase <= 20 {
            return 160.0 / 255.0
        } else if phase <= 50 {
            return Float((51 - phase) * 5) / 255.0
        } else {
            return nil
        }
    }

    /// Spawns `PP_3DTEXTURE` (15) skill aura (`effect\fashasha.tga`) used by body and skill aura effects.
    func texturedSkillAura(type: Int8, context: EffectTickContext) {
        if stateCnt == 0 {
            let soundName: String? = switch type {
            case 0: "effect\\hunter_detecting.wav"
            case 2: "effect\\priest_benedictio.wav"
            case 4: "effect\\cru_grand cross.wav"
            case 5: "effect\\ANALYZE.wav"
            default: nil
            }
            if let soundName {
                context.world.playSound(
                    named: soundName,
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
        }

        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\fashasha.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_3dtexture)
        primitive.state.duration = 57
        primitive.state.widthSpeed = 1.5
        primitive.state.heightSpeed = 1.5
        primitive.state.widthAccel = primitive.state.widthSpeed / 14.0
        primitive.state.heightAccel = primitive.state.heightSpeed / 14.0
        primitive.state.deltaPos2.y = -5.0
        primitive.state.speed3d.y = -0.5
        primitive.state.roll = 90.0
        primitive.state.changePoint = (type == 3 || type == 6) ? 10 : 17
        primitive.state.fadeOutCnt = (type == 3 || type == 6) ? 30 : 40

        switch type {
        case 4:
            primitive.state.red = 0xFF
            primitive.state.green = 0x8C
            primitive.state.blue = 0x8C
        case 5:
            primitive.state.red = 0xD2
            primitive.state.green = 0xFA
            primitive.state.blue = 0xD2
        case 6:
            primitive.state.red = 10
            primitive.state.green = 10
            primitive.state.blue = 10
        case 7:
            primitive.state.red = 0xFA
            primitive.state.green = 0xD2
            primitive.state.blue = 0x8C
        case 8:
            primitive.state.red = 0x8C
            primitive.state.green = 0xFF
            primitive.state.blue = 0x8C
        default:
            break
        }

        primitive.state.changeWidthSpeed = 0.1
        primitive.state.changeHeightSpeed = 0.1
        primitive.state.changeWidthAccel = primitive.state.changeWidthSpeed / 30.0
        primitive.state.changeHeightAccel = primitive.state.changeHeightSpeed / 30.0
        primitive.state.texturePaths = [texturePath]
    }
}
