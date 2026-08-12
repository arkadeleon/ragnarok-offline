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

    public init(
        colorPixelFormat: MTLPixelFormat,
        depthStencilPixelFormat: MTLPixelFormat,
        amplificationCount: Int = 1
    ) {
        self.colorPixelFormat = colorPixelFormat
        self.depthStencilPixelFormat = depthStencilPixelFormat
        self.amplificationCount = amplificationCount
    }
}
