//
//  RendererCommon.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/29.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal

struct Fog {
    var use: Bool
    var exist: Bool
    var far: Float
    var near: Float
    var factor: Float
    var color: simd_float3
}

struct Light {
    var opacity: Float
    var ambient: simd_float3
    var diffuse: simd_float3
    var direction: simd_float3
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
