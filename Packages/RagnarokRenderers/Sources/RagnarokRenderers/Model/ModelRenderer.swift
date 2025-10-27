//
//  ModelRenderer.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2020/6/29.
//

import Metal
import RagnarokShaders
import simd

class ModelRenderer {
    let renderPipelineState: any MTLRenderPipelineState
    let depthStencilState: (any MTLDepthStencilState)?

    let models: [Model]
    let textures: [String : any MTLTexture]

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

    init(device: any MTLDevice, library: any MTLLibrary, models: [Model], textures: [String : any MTLTexture]) throws {
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

        self.models = models
        self.textures = textures
    }

    func render(
        atTime time: CFTimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4,
        normalMatrix: simd_float3x3
    ) {
        let device = renderCommandEncoder.device

        var vertexUniforms = ModelVertexUniforms(
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
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

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        renderCommandEncoder.setVertexBuffer(vertexUniformsBuffer, offset: 0, index: 1)

        renderCommandEncoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

        for model in models {
            for mesh in model.meshes where mesh.vertices.count > 0 {
                guard let vertexBuffer = device.makeBuffer(bytes: mesh.vertices, length: mesh.vertices.count * MemoryLayout<ModelVertex>.stride, options: []) else {
                    continue
                }

                renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

                let texture = textures[mesh.textureName]
                renderCommandEncoder.setFragmentTexture(texture, index: 0)

                renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: mesh.vertices.count)
            }
        }
    }
}
