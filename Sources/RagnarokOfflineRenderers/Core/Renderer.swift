//
//  Renderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/5/23.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import MetalKit

public protocol Renderer: MTKViewDelegate {
    var device: MTLDevice { get }
    var colorPixelFormat: MTLPixelFormat { get }
    var depthStencilPixelFormat: MTLPixelFormat { get }
}

extension Renderer {
    public var colorPixelFormat: MTLPixelFormat {
        .bgra8Unorm
    }

    public var depthStencilPixelFormat: MTLPixelFormat {
        .depth32Float
    }
}
