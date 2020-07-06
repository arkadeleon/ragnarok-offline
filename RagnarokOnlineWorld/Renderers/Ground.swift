//
//  Ground.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/3.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal
import SGLMath

class Ground: Renderable {

    let vertices: [GroundVertex]
    let texture: MTLTexture?

    let vertexFunctionName = "groundVertexShader"
    let fragmentFunctionName = "groundFragmentShader"

    init(vertices: [GroundVertex], texture: MTLTexture?) {
        self.vertices = vertices
        self.texture = texture
    }

    func render(encoder: MTLRenderCommandEncoder,
                modelviewMatrix: Matrix4x4<Float>,
                projectionMatrix: Matrix4x4<Float>,
                normalMatrix: Matrix3x3<Float>,
                fog: Fog,
                light: Light) {

        var vertexUniforms = GroundVertexUniforms(
            modelViewMat: modelviewMatrix.simd,
            projectionMat: projectionMatrix.simd,
            lightDirection: light.direction.simd,
            normalMat: normalMatrix.simd
        )

        guard let vertexUniformsBuffer = encoder.device.makeBuffer(bytes: &vertexUniforms, length: MemoryLayout<GroundVertexUniforms>.stride, options: []) else {
            return
        }

        encoder.setVertexBuffer(vertexUniformsBuffer, offset: 0, index: 1)

        var fragmentUniforms = GroundFragmentUniforms(
            lightMapUse: 1,
            fogUse: fog.use && fog.exist ? 1 : 0,
            fogNear: fog.near,
            fogFar: fog.far,
            fogColor: fog.color.simd,
            lightAmbient: light.ambient.simd,
            lightDiffuse: light.diffuse.simd,
            lightOpacity: light.opacity
        )

        guard let fragmentUniformsBuffer = encoder.device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<GroundFragmentUniforms>.stride, options: []) else {
            return
        }
        
        encoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

        guard vertices.count > 0 else {
            return
        }

        guard let vertexBuffer = encoder.device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<GroundVertex>.stride, options: []) else {
            return
        }

        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        encoder.setFragmentTexture(texture, index: 0)
        encoder.setFragmentTexture(texture, index: 1)
        encoder.setFragmentTexture(texture, index: 2)

        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}
