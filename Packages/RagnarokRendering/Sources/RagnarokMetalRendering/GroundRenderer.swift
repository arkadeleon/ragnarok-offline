//
//  GroundRenderer.swift
//  RagnarokMetalRendering
//
//  Created by Leon Li on 2020/7/3.
//

import Metal
import RagnarokShaders
import simd

public final class GroundRenderer {
    let device: any MTLDevice
    let renderPipelineState: any MTLRenderPipelineState
    let depthStencilState: (any MTLDepthStencilState)?

    public init(device: any MTLDevice) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

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
        renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    public func render(
        resource: GroundRenderResource,
        atTime time: CFTimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4,
        normalMatrix: simd_float3x3
    ) {
        guard resource.vertexCount > 0 else {
            return
        }

        var vertexUniforms = GroundVertexUniforms(
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            lightDirection: resource.light.direction,
            normalMatrix: normalMatrix
        )

        var fragmentUniforms = GroundFragmentUniforms(
            lightMapUse: resource.lightmapTexture == nil ? 0 : 1,
            lightAmbient: resource.light.ambient,
            lightDiffuse: resource.light.diffuse,
            lightOpacity: resource.light.opacity
        )

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        renderCommandEncoder.setVertexBuffer(resource.vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBytes(&vertexUniforms, length: MemoryLayout<GroundVertexUniforms>.stride, index: 1)

        renderCommandEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<GroundFragmentUniforms>.stride, index: 0)
        renderCommandEncoder.setFragmentTexture(resource.baseColorTexture, index: 0)
        renderCommandEncoder.setFragmentTexture(resource.lightmapTexture, index: 1)
        renderCommandEncoder.setFragmentTexture(resource.tileColorTexture, index: 2)

        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: resource.vertexCount)
    }
}
