//
//  Ray.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/8/12.
//

import CoreGraphics
import simd

/// A ray through the world, used to find what the user is pointing at.
///
/// iOS and macOS build one from the tapped point through `RenderCamera.ray(through:in:)`.
/// visionOS builds one from where the user is looking or pinching.
public struct Ray {
    public var origin: SIMD3<Float>
    public var direction: SIMD3<Float>

    /// World-space width of one view point, at one unit of distance along the ray.
    ///
    /// Hit testing grows targets smaller than a comfortable tap by this much, so that a
    /// distant sprite stays as reachable as a nearby one.
    public var pointWidth: Float

    public init(origin: SIMD3<Float>, direction: SIMD3<Float>, pointWidth: Float = 0) {
        self.origin = origin
        self.direction = direction
        self.pointWidth = pointWidth
    }

    public func point(atDistance distance: Float) -> SIMD3<Float> {
        origin + direction * distance
    }
}

extension RenderCamera {
    /// The ray through `point` of a view covering `bounds`.
    public func ray(through point: CGPoint, in bounds: CGRect) -> Ray? {
        guard bounds.width > 0, bounds.height > 0 else {
            return nil
        }

        let inverse = (projectionMatrix * viewMatrix).inverse
        if inverse[0][0].isNaN {
            return nil
        }

        // Screen (top-left origin) → NDC [-1, 1]; Y is flipped because NDC +Y is up.
        let ndcX = Float((point.x - bounds.minX) / bounds.width) * 2 - 1
        let ndcY = 1 - Float((point.y - bounds.minY) / bounds.height) * 2

        let near = inverse * SIMD4<Float>(ndcX, ndcY, 0, 1)
        let far = inverse * SIMD4<Float>(ndcX, ndcY, 1, 1)

        let nearPosition = SIMD3<Float>(near.x, near.y, near.z) / near.w
        let farPosition = SIMD3<Float>(far.x, far.y, far.z) / far.w

        // One point spans 2 / bounds.height of NDC, which the projection stretches by
        // 1 / projectionMatrix[1][1] for every unit of distance.
        let focalLength = projectionMatrix[1][1]
        let pointWidth = focalLength > 0 ? 2 / (focalLength * Float(bounds.height)) : 0

        return Ray(
            origin: nearPosition,
            direction: simd_normalize(farPosition - nearPosition),
            pointWidth: pointWidth
        )
    }
}
