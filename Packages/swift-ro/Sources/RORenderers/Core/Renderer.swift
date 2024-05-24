//
//  Renderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/5/23.
//

import Metal

public protocol Renderer {
    var device: MTLDevice { get }
    var colorPixelFormat: MTLPixelFormat { get }
    var depthStencilPixelFormat: MTLPixelFormat { get }

    func render(atTime time: CFTimeInterval, viewport: CGRect, commandBuffer: MTLCommandBuffer, renderPassDescriptor: MTLRenderPassDescriptor)
}

extension Renderer {
    public var colorPixelFormat: MTLPixelFormat {
        .bgra8Unorm
    }

    public var depthStencilPixelFormat: MTLPixelFormat {
        .depth32Float
    }
}
