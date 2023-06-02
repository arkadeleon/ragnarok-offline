//
//  ModelRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/29.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal

class ModelRenderer {

    let renderPipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState?
    let meshes: [[ModelVertex]]
    let textures: [MTLTexture?]

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

    init(device: MTLDevice, library: MTLLibrary, meshes: [[ModelVertex]], textures: [Data?]) throws {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()

        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "modelVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "modelFragmentShader")

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

        self.meshes = meshes

        let textureLoader = TextureLoader(device: device)
        self.textures = textures.map { data -> MTLTexture? in
            return data.flatMap { textureLoader.newTexture(data: $0) }
        }
    }

    func render(atTime time: CFTimeInterval,
                device: MTLDevice,
                renderPassDescriptor: MTLRenderPassDescriptor,
                commandBuffer: MTLCommandBuffer,
                modelviewMatrix: simd_float4x4,
                projectionMatrix: simd_float4x4,
                normalMatrix: simd_float3x3) {

        var vertexUniforms = ModelVertexUniforms(
            modelviewMatrix: modelviewMatrix,
            projectionMatrix: projectionMatrix,
            lightDirection: [0, 1, 0],
            normalMatrix: normalMatrix
        )
        guard let vertexUniformsBuffer = device.makeBuffer(bytes: &vertexUniforms, length: MemoryLayout<ModelVertexUniforms>.stride, options: []) else {
            return
        }

        var fragmentUniforms = ModelFragmentUniforms(
            fogUse: fog.use ? 1 : 0,
            fogNear: fog.near,
            fogFar: fog.far,
            fogColor: fog.color,
            lightAmbient: light.ambient,
            lightDiffuse: light.diffuse,
            lightOpacity: light.opacity
        )
        guard let fragmentUniformsBuffer = device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<ModelFragmentUniforms>.stride, options: []) else {
            return
        }

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        renderCommandEncoder.setVertexBuffer(vertexUniformsBuffer, offset: 0, index: 1)

        renderCommandEncoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

        for (i, vertices) in meshes.enumerated() where vertices.count > 0 {
            guard let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<ModelVertex>.stride, options: []) else {
                continue
            }

            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

            let texture = textures[i]
            renderCommandEncoder.setFragmentTexture(texture, index: 0)

            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        }

        renderCommandEncoder.endEncoding()
    }
}
