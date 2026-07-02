//
//  SPREffectRenderer.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/7/2.
//

import Foundation
import Metal
import RagnarokShaders
import simd

final class SPREffectRenderer {
    let device: any MTLDevice

    private let renderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: (any MTLDepthStencilState)?

    init(device: any MTLDevice) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "sprEffectVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "sprEffectFragmentShader")
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
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    func render(
        resource: SPREffectRenderResource,
        atTime time: TimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4
    ) {
        guard let texture = resource.texture(atTime: time) else {
            return
        }

        var vertexUniforms = SPREffectVertexUniforms(
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            worldPosition: resource.worldPosition,
            size: resource.frameSize,
            zIndex: 0
        )

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        resource.vertices.withUnsafeBytes { bytes in
            renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
        }
        renderCommandEncoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout<SPREffectVertexUniforms>.stride,
            index: 1
        )
        renderCommandEncoder.setFragmentTexture(texture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: resource.vertices.count)
    }
}
