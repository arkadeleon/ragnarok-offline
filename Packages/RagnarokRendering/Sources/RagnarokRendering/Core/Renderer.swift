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
    var colorPixelFormat: MTLPixelFormat { get }
    var depthStencilPixelFormat: MTLPixelFormat { get }

    func render(frame: RenderFrame)
}

extension Renderer {
    public var colorPixelFormat: MTLPixelFormat {
        .bgra8Unorm
    }

    public var depthStencilPixelFormat: MTLPixelFormat {
        .depth32Float
    }
}
