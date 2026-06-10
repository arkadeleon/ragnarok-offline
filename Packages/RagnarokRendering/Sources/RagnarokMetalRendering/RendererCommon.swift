//
//  RendererCommon.swift
//  RagnarokMetalRendering
//
//  Created by Leon Li on 2020/6/29.
//

import Metal

enum Formats {
}

extension Formats {
    static var colorPixelFormat: MTLPixelFormat {
        .bgra8Unorm
    }

    static var depthPixelFormat: MTLPixelFormat {
        .depth32Float
    }
}
