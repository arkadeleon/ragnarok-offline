//
//  GroundRenderer.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/3.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal
import MetalKit
import SGLMath

class GroundRenderer {

    let renderPipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState?
    let vertices: [GroundVertex]
    let texture: MTLTexture?

    let fog = Fog(
        use: false,
        exist: true,
        far: 30,
        near: 80,
        factor: 1,
        color: [1, 1, 1]
    )

    let light = Light(
        opacity: 1,
        ambient: [1, 1, 1],
        diffuse: [0, 0, 0],
        direction: [0, 1, 0]
    )

    init(device: MTLDevice, library: MTLLibrary, vertices: [GroundVertex], texture: Data?) throws {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()

        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "groundVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "groundFragmentShader")

        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Formats.colorPixelFormat
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        renderPipelineDescriptor.depthAttachmentPixelFormat = Formats.depthPixelFormat

        self.renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true

        self.depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)

        self.vertices = vertices

        let textureLoader = MTKTextureLoader(device: device)
        self.texture = try texture.flatMap { try textureLoader.newTexture(data: $0, options: nil) }
    }

    func render(atTime time: CFTimeInterval,
                device: MTLDevice,
                commandBuffer: MTLCommandBuffer,
                renderPassDescriptor: MTLRenderPassDescriptor,
                modelviewMatrix: Matrix4x4<Float>,
                projectionMatrix: Matrix4x4<Float>,
                normalMatrix: Matrix3x3<Float>) {

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        var vertexUniforms = GroundVertexUniforms(
            modelViewMat: modelviewMatrix.simd,
            projectionMat: projectionMatrix.simd,
            lightDirection: light.direction.simd,
            normalMat: normalMatrix.simd
        )

        guard let vertexUniformsBuffer = device.makeBuffer(bytes: &vertexUniforms, length: MemoryLayout<GroundVertexUniforms>.stride, options: []) else {
            return
        }

        renderCommandEncoder.setVertexBuffer(vertexUniformsBuffer, offset: 0, index: 1)

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

        guard let fragmentUniformsBuffer = device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<GroundFragmentUniforms>.stride, options: []) else {
            return
        }
        
        renderCommandEncoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

        guard vertices.count > 0 else {
            return
        }

        guard let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<GroundVertex>.stride, options: []) else {
            return
        }

        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        renderCommandEncoder.setFragmentTexture(texture, index: 0)
        renderCommandEncoder.setFragmentTexture(texture, index: 1)
        renderCommandEncoder.setFragmentTexture(texture, index: 2)

        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)

        renderCommandEncoder.endEncoding()
    }
}
