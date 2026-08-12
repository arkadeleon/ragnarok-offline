//
//  RenderView.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/8/12.
//

import CoreGraphics
import Metal

/// A single view to be drawn within a frame.
///
/// iOS and macOS draw one view per frame. visionOS draws one per eye, each with its own
/// viewport and camera derived from the device pose.
public struct RenderView {
    /// Region of the render target this view draws into, in pixels.
    public var viewport: MTLViewport

    /// The camera this view is drawn from.
    public var camera: RenderCamera

    public init(viewport: MTLViewport, camera: RenderCamera) {
        self.viewport = viewport
        self.camera = camera
    }
}

extension MTLViewport {
    /// A viewport covering the whole of a render target of `size` pixels.
    public init(size: CGSize) {
        self.init(
            originX: 0,
            originY: 0,
            width: size.width,
            height: size.height,
            znear: 0,
            zfar: 1
        )
    }

    /// Size of the viewport, in pixels.
    public var size: CGSize {
        CGSize(width: width, height: height)
    }
}
