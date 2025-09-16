//
//  RendererCommon.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/29.
//

import Metal
import simd

struct Fog {
    var use: Bool
    var exist: Bool
    var far: Float
    var near: Float
    var factor: Float
    var color: SIMD3<Float>
}

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
