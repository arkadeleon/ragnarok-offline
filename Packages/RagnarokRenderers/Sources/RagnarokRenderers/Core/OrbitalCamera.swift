//
//  OrbitalCamera.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/5/15.
//

import CoreGraphics
import RagnarokCore
import simd

public class OrbitalCamera {
    public var azimuth: Float = 0
    public var elevation: Float = 0
    public var distance: Float
    public var minimumDistance: Float = 0
    public var maximumDistance: Float = .infinity
    public var target: SIMD3<Float> = .zero

    public var fovy: Float = 70
    public var nearZ: Float = 0.1
    public var farZ: Float = 100.0
    public var sensitivity: Float = 0.1
    public var animationDuration: CFTimeInterval = 0.25

    public private(set) var aspectRatio: Float = 1.0

    private let defaultDistance: Float

    private struct TargetAnimation {
        var startTarget: SIMD3<Float>
        var endTarget: SIMD3<Float>
        var startTime: CFTimeInterval?
        var duration: CFTimeInterval
    }

    private var targetAnimation: TargetAnimation?

    public var viewMatrix: simd_float4x4 {
        let orientation =
            simd_quatf(angle: -azimuth, axis: [0, 1, 0]) *
            simd_quatf(angle: -elevation, axis: [1, 0, 0])
        let cameraPosition = target + orientation.act([0, 0, distance])
        let cameraUp = orientation.act([0, 1, 0])
        return lookAt(cameraPosition, target, cameraUp)
    }

    public var projectionMatrix: simd_float4x4 {
        perspective(radians(fovy), aspectRatio, nearZ, farZ)
    }

    public var panOffset: CGPoint {
        CGPoint(x: CGFloat(-target.x / sensitivity), y: CGFloat(-target.z / sensitivity))
    }

    public init(distance: Float) {
        self.distance = distance
        self.defaultDistance = distance
    }

    public func update(size: CGSize) {
        aspectRatio = Float(size.width / size.height)
    }

    public func update(atTime time: CFTimeInterval) {
        guard var animation = targetAnimation else { return }
        if animation.startTime == nil {
            animation.startTime = time
            targetAnimation = animation
        }
        guard let startTime = animation.startTime else { return }
        let progress = min(Float((time - startTime) / animation.duration), 1)
        let eased = 1 - pow(1 - progress, 3)
        target = animation.startTarget + (animation.endTarget - animation.startTarget) * eased
        if progress >= 1 {
            targetAnimation = nil
        }
    }

    public func pan(offset: CGPoint) {
        targetAnimation = nil
        target.x = -Float(offset.x) * sensitivity
        target.z = -Float(offset.y) * sensitivity
    }

    public func zoom(magnification: CGFloat) {
        var d = defaultDistance / Float(magnification)
        d = max(minimumDistance, min(d, maximumDistance))
        distance = d
    }

    public func animatePan(to newTarget: SIMD3<Float>) {
        targetAnimation = TargetAnimation(
            startTarget: target,
            endTarget: newTarget,
            startTime: nil,
            duration: animationDuration
        )
    }
}
