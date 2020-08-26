//
//  RendererCommon.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/29.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal
import SGLMath

struct Fog {

    var use: Bool
    var exist: Bool
    var far: Float
    var near: Float
    var factor: Float
    var color: Vector3<Float>
}

struct Light {

    var opacity: Float
    var ambient: Vector3<Float>
    var diffuse: Vector3<Float>
    var direction: Vector3<Float>
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
