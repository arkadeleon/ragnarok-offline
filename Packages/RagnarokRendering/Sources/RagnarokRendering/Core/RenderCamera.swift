//
//  RenderCamera.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/8/12.
//

import simd

/// The camera a single view is drawn from.
///
/// On iOS and macOS a renderer derives this from its own camera through
/// `Renderer.makeCamera(atTime:viewport:)`. On visionOS it comes from the device pose.
public struct RenderCamera {
    public var viewMatrix: simd_float4x4
    public var projectionMatrix: simd_float4x4
    public var position: SIMD3<Float>
    public var azimuth: Float
    public var elevation: Float

    public init(
        viewMatrix: simd_float4x4 = matrix_identity_float4x4,
        projectionMatrix: simd_float4x4 = matrix_identity_float4x4,
        position: SIMD3<Float> = .zero,
        azimuth: Float = 0,
        elevation: Float = 0
    ) {
        self.viewMatrix = viewMatrix
        self.projectionMatrix = projectionMatrix
        self.position = position
        self.azimuth = azimuth
        self.elevation = elevation
    }
}
