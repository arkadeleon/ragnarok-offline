//
//  MapObjectEffectModifiers.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokEffects
import simd

struct MapObjectEffectModifiers: Sendable {
    struct Timed<Value: Sendable>: Sendable {
        var value: Value
        var remainingTime: TimeInterval
        var totalTime: TimeInterval
    }

    struct AfterimageRequest: Sendable, Equatable {
        let style: EffectAfterimageStyle
        let tint: SIMD4<Float>?
        let duration: TimeInterval
    }

    struct Outline: Sendable, Equatable {
        let color: SIMD4<Float>
        let spread: Float
        let layers: Int
    }

    struct FourWaySplit: Sendable, Equatable {
        let spread: Float
        let alpha: Float
    }

    var tint: Timed<SIMD4<Float>>?
    var flash: Timed<SIMD4<Float>>?
    var alpha: Timed<Float>?
    var cloakingAlpha: Timed<Float>?
    var scale: Timed<SIMD3<Float>>?
    var facingYawDegrees: Timed<Float>?
    var spriteRollDegrees: Timed<Float>?
    var spriteOffset: Timed<SIMD2<Float>>?
    var outline: Timed<Outline>?
    var fourWaySplit: Timed<FourWaySplit>?
    var shake: Timed<Float>?

    private var shakeElapsedTime: TimeInterval = 0
    private(set) var pendingAfterimages: [AfterimageRequest] = []

    var isEmpty: Bool {
        tint == nil
            && flash == nil
            && alpha == nil
            && cloakingAlpha == nil
            && scale == nil
            && facingYawDegrees == nil
            && spriteRollDegrees == nil
            && spriteOffset == nil
            && outline == nil
            && fourWaySplit == nil
            && shake == nil
            && pendingAfterimages.isEmpty
    }

    var effectiveTintColor: SIMD3<Float> {
        var color = SIMD3<Float>(repeating: 1)
        if let tint {
            color *= SIMD3<Float>(tint.value.x, tint.value.y, tint.value.z)
        }
        if let flash {
            let ratio = Float(flash.remainingTime / max(flash.totalTime, 1e-6))
            let weight = min(max(flash.value.w, 0), 1) * min(max(ratio, 0), 1)
            let flashRGB = SIMD3<Float>(flash.value.x, flash.value.y, flash.value.z)
            color = simd_mix(color, flashRGB, SIMD3<Float>(repeating: weight))
        }
        return color
    }

    var effectiveAlphaMultiplier: Float {
        var multiplier: Float = 1
        if let alpha {
            multiplier *= min(max(alpha.value, 0), 1)
        }
        if let cloakingAlpha {
            multiplier *= min(max(cloakingAlpha.value, 0), 1)
        }
        return min(max(multiplier, 0), 1)
    }

    var effectiveScale: SIMD2<Float> {
        if let scale {
            [scale.value.x, scale.value.y]
        } else {
            .one
        }
    }

    var effectiveFacingYawDegrees: Float {
        facingYawDegrees?.value ?? 0
    }

    var effectiveSpriteRollRadians: Float {
        (spriteRollDegrees?.value ?? 0) * .pi / 180
    }

    var effectiveSpriteOffset: SIMD2<Float> {
        spriteOffset?.value ?? .zero
    }

    var effectiveOutline: Outline? {
        outline?.value
    }

    var effectiveFourWaySplit: FourWaySplit? {
        fourWaySplit?.value
    }

    var effectiveWorldOffset: SIMD3<Float> {
        guard let shake else {
            return .zero
        }
        let decay = Float(shake.remainingTime / max(shake.totalTime, 1e-6))
        let magnitude = shake.value * max(decay, 0) * 0.05
        let elapsed = Float(shakeElapsedTime)
        return [sin(elapsed * 60) * magnitude, 0, cos(elapsed * 47) * magnitude]
    }

    mutating func apply(_ modifier: EffectTargetModifier) {
        switch modifier {
        case .tint(let color, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            tint = Timed(value: color, remainingTime: duration, totalTime: duration)
        case .flash(let color, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            flash = Timed(value: color, remainingTime: duration, totalTime: duration)
        case .alpha(let value, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            let clamped = min(max(value, 0), 1)
            alpha = Timed(value: clamped, remainingTime: duration, totalTime: duration)
        case .cloaking(let value):
            let duration = Self.duration(fromTicks: 2)
            let clamped = min(max(value, 0), 1)
            cloakingAlpha = Timed(value: clamped, remainingTime: duration, totalTime: duration)
        case .scale(let value, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            let clamped = simd_max(value, SIMD3<Float>(repeating: 0.01))
            scale = Timed(value: clamped, remainingTime: duration, totalTime: duration)
        case .facingYaw(let degrees, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            facingYawDegrees = Timed(value: degrees, remainingTime: duration, totalTime: duration)
        case .spriteRoll(let degrees, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            spriteRollDegrees = Timed(value: degrees, remainingTime: duration, totalTime: duration)
        case .spriteOffset(let offset, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            spriteOffset = Timed(value: offset, remainingTime: duration, totalTime: duration)
        case .outline(let color, let spread, let layers, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            let value = Outline(color: color, spread: max(spread, 0), layers: max(layers, 1))
            outline = Timed(value: value, remainingTime: duration, totalTime: duration)
        case .fourWaySplit(let spread, let alpha, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            let value = FourWaySplit(spread: max(spread, 0), alpha: min(max(alpha, 0), 1))
            fourWaySplit = Timed(value: value, remainingTime: duration, totalTime: duration)
        case .shake(let amplitude, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            shake = Timed(value: amplitude, remainingTime: duration, totalTime: duration)
        case .afterimage(let style, let tint, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            pendingAfterimages.append(AfterimageRequest(style: style, tint: tint, duration: duration))
        }
    }

    mutating func update(deltaTime: TimeInterval) {
        guard deltaTime > 0 else {
            return
        }

        Self.decay(&tint, by: deltaTime)
        Self.decay(&flash, by: deltaTime)
        Self.decay(&alpha, by: deltaTime)
        Self.decay(&cloakingAlpha, by: deltaTime)
        Self.decay(&scale, by: deltaTime)
        Self.decay(&facingYawDegrees, by: deltaTime)
        Self.decay(&spriteRollDegrees, by: deltaTime)
        Self.decay(&spriteOffset, by: deltaTime)
        Self.decay(&outline, by: deltaTime)
        Self.decay(&fourWaySplit, by: deltaTime)
        Self.decay(&shake, by: deltaTime)

        if shake != nil {
            shakeElapsedTime += deltaTime
        } else {
            shakeElapsedTime = 0
        }
    }

    mutating func takePendingAfterimages() -> [AfterimageRequest] {
        guard !pendingAfterimages.isEmpty else {
            return []
        }
        let requests = pendingAfterimages
        pendingAfterimages.removeAll(keepingCapacity: true)
        return requests
    }

    private static let tickRate: TimeInterval = 60.0

    private static func duration(fromTicks ticks: Int) -> TimeInterval {
        TimeInterval(max(1, ticks)) / tickRate
    }

    private static func decay<Value>(_ channel: inout Timed<Value>?, by deltaTime: TimeInterval) {
        guard var current = channel else {
            return
        }
        current.remainingTime -= deltaTime
        channel = current.remainingTime > 0 ? current : nil
    }
}
