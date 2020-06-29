//
//  Renderable.swift
//  RagnarokOnlineWorld
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

protocol Renderable {

    var vertexFunctionName: String { get }
    var fragmentFunctionName: String { get }

    func render(encoder: MTLRenderCommandEncoder,
                modelviewMatrix: Matrix4x4<Float>,
                projectionMatrix: Matrix4x4<Float>,
                normalMatrix: Matrix3x3<Float>,
                fog: Fog,
                light: Light)
}
