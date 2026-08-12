//
//  RenderFrame.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/8/12.
//

import CoreGraphics
import Foundation
import Metal

/// Everything a renderer needs to draw one frame.
public struct RenderFrame {
    public var time: TimeInterval
    public var commandBuffer: any MTLCommandBuffer
    public var renderPassDescriptor: MTLRenderPassDescriptor

    /// The views making up this frame, in the order they should be drawn.
    public var views: [RenderView]

    /// Region of the view the frame covers, in points.
    ///
    /// Renderers that hit test against user input work in this space. visionOS has no such
    /// space and leaves it `.zero`.
    public var bounds: CGRect

    public init(
        time: TimeInterval,
        commandBuffer: any MTLCommandBuffer,
        renderPassDescriptor: MTLRenderPassDescriptor,
        views: [RenderView],
        bounds: CGRect = .zero
    ) {
        self.time = time
        self.commandBuffer = commandBuffer
        self.renderPassDescriptor = renderPassDescriptor
        self.views = views
        self.bounds = bounds
    }
}
