//
//  RSMModelRenderer.swift
//  RagnarokMetalRendering
//
//  Created by Leon Li on 2020/6/29.
//

import Metal
import RagnarokShaders
import simd

public final class RSMModelRenderer {
    let device: any MTLDevice
    let renderPipelineState: any MTLRenderPipelineState
    let depthStencilState: (any MTLDepthStencilState)?

    public init(device: any MTLDevice) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

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
        renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    public func render(
        resource: RSMModelRenderResource,
        atTime time: CFTimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4,
        normalMatrix: simd_float3x3
    ) {
        var vertexUniforms = ModelVertexUniforms(
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            lightDirection: resource.light.direction,
            normalMatrix: normalMatrix
        )

        var fragmentUniforms = ModelFragmentUniforms(
            lightAmbient: resource.light.ambient,
            lightDiffuse: resource.light.diffuse,
            lightOpacity: resource.light.opacity
        )

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        renderCommandEncoder.setVertexBytes(&vertexUniforms, length: MemoryLayout<ModelVertexUniforms>.stride, index: 1)
        renderCommandEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<ModelFragmentUniforms>.stride, index: 0)

        for mesh in resource.meshes where mesh.vertexCount > 0 {
            renderCommandEncoder.setVertexBuffer(mesh.vertexBuffer, offset: 0, index: 0)
            renderCommandEncoder.setFragmentTexture(mesh.texture, index: 0)

            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: mesh.vertexCount)
        }
    }
}
