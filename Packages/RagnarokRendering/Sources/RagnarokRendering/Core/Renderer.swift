//
//  Renderer.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2023/5/23.
//

import Foundation
import Metal

@MainActor
public protocol Renderer {
    var device: any MTLDevice { get }
    var configuration: RenderConfiguration { get }

    /// The camera to draw `viewport` from, advanced to `time`.
    ///
    /// iOS and macOS ask the renderer for this and pass it back through `RenderView`.
    /// visionOS builds the camera from the device pose instead and never calls this.
    func makeCamera(atTime time: TimeInterval, viewport: MTLViewport) -> RenderCamera

    func render(frame: RenderFrame)
}
