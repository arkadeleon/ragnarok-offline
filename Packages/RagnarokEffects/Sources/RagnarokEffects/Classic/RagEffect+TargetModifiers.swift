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
}
