//
//  RendererCommon.swift
//  RagnarokMetalRendering
//
//  Created by Leon Li on 2020/6/29.
//

import Metal
import simd

struct Light {
    var opacity: Float
    var ambient: SIMD3<Float>
    var diffuse: SIMD3<Float>
    var direction: SIMD3<Float>
}

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
