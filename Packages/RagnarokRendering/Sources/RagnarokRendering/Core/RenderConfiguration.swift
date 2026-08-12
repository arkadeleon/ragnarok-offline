//
//  RenderConfiguration.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/8/12.
//

import Metal

/// The pixel formats and vertex amplification a renderer's pipeline states are built with.
///
/// iOS and macOS use `.default`, which is what `MTKView` is configured with. visionOS
/// builds one from its `LayerRenderer` configuration instead.
public struct RenderConfiguration: Sendable {
    public static let `default` = RenderConfiguration(
        colorPixelFormat: .bgra8Unorm,
        depthStencilPixelFormat: .depth32Float
    )

    public var colorPixelFormat: MTLPixelFormat
    public var depthStencilPixelFormat: MTLPixelFormat

    /// Number of views a single draw call writes at once through vertex amplification.
    public var amplificationCount: Int

    /// Whether depth runs from 1 at the near plane down to 0 at the far plane.
    ///
    /// Compositor Services only supports reversed depth; iOS and macOS use the ordinary
    /// direction.
    public var isDepthReversed: Bool

    /// The value to clear the depth attachment to, which is the far plane.
    public var clearDepth: Double {
        isDepthReversed ? 0 : 1
    }

    /// The comparison that keeps the fragment nearer to the camera.
    public var depthCompareFunction: MTLCompareFunction {
        isDepthReversed ? .greaterEqual : .lessEqual
    }

    public init(
        colorPixelFormat: MTLPixelFormat,
        depthStencilPixelFormat: MTLPixelFormat,
        amplificationCount: Int = 1,
        isDepthReversed: Bool = false
    ) {
        self.colorPixelFormat = colorPixelFormat
        self.depthStencilPixelFormat = depthStencilPixelFormat
        self.amplificationCount = amplificationCount
        self.isDepthReversed = isDepthReversed
    }
}
