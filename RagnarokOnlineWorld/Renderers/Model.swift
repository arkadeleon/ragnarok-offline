//
//  Model.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/29.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal
import SGLMath

class Model: Renderable {

    let meshes: [[[ModelVertex]]]
    let textures: [MTLTexture?]
    let boundingBox: RSMBoundingBox

    let vertexFunctionName = "modelVertexShader"
    let fragmentFunctionName = "modelFragmentShader"

    init(meshes: [[[ModelVertex]]], textures: [MTLTexture?], boundingBox: RSMBoundingBox) {
        self.meshes = meshes
        self.textures = textures
        self.boundingBox = boundingBox
    }

    func render(encoder: MTLRenderCommandEncoder,
                modelviewMatrix: Matrix4x4<Float>,
                projectionMatrix: Matrix4x4<Float>,
                normalMatrix: Matrix3x3<Float>,
                fog: Fog,
                light: Light) {

        var vertexUniforms = ModelVertexUniforms(
            modelViewMat: modelviewMatrix.simd,
            projectionMat: projectionMatrix.simd,
            lightDirection: [0, 1, 0],
            normalMat: normalMatrix.simd
        )

        guard let vertexUniformsBuffer = encoder.device.makeBuffer(bytes: &vertexUniforms, length: MemoryLayout<ModelVertexUniforms>.stride, options: []) else {
            return
        }

        encoder.setVertexBuffer(vertexUniformsBuffer, offset: 0, index: 1)

        var fragmentUniforms = ModelFragmentUniforms(
            fogUse: fog.use ? 1 : 0,
            fogNear: fog.near,
            fogFar: fog.far,
            fogColor: fog.color.simd,
            lightAmbient: light.ambient.simd,
            lightDiffuse: light.diffuse.simd,
            lightOpacity: light.opacity
        )
        guard let fragmentUniformsBuffer = encoder.device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<ModelFragmentUniforms>.stride, options: []) else {
            return
        }
        encoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

        for mesh in meshes {
            for (i, vertices) in mesh.enumerated() where vertices.count > 0 {
                guard let vertexBuffer = encoder.device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<ModelVertex>.stride, options: []) else {
                    continue
                }

                encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

                let texture = textures[i]
                encoder.setFragmentTexture(texture, index: 0)

                encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
            }
        }
    }
}
