//
//  RenderView.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/8/12.
//

import CoreGraphics
import Metal
import simd

/// A single view to be drawn within a frame.
///
/// iOS and macOS draw one view per frame. visionOS draws one per eye, each with its own
/// viewport and matrices derived from the device pose.
public struct RenderView {
    /// Region of the render target this view draws into, in pixels.
    public var viewport: MTLViewport

    /// View matrix from the visionOS device pose, or `nil` on iOS and macOS to let the
    /// renderer's own camera decide.
    public var viewMatrix: simd_float4x4?

    /// Projection matrix from the visionOS device pose, or `nil` on iOS and macOS to let
    /// the renderer's own camera decide.
    public var projectionMatrix: simd_float4x4?

    /// Size of `viewport`, in pixels.
    public var size: CGSize {
        CGSize(width: viewport.width, height: viewport.height)
    }

    public init(
        viewport: MTLViewport,
        viewMatrix: simd_float4x4? = nil,
        projectionMatrix: simd_float4x4? = nil
    ) {
        self.viewport = viewport
        self.viewMatrix = viewMatrix
        self.projectionMatrix = projectionMatrix
    }

    /// A view covering the whole of a render target of `size` pixels.
    public init(size: CGSize) {
        let viewport = MTLViewport(
            originX: 0,
            originY: 0,
            width: size.width,
            height: size.height,
            znear: 0,
            zfar: 1
        )
        self.init(viewport: viewport)
    }
}
