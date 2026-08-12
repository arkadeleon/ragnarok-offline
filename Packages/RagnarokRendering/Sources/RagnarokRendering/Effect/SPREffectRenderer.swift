//
//  SPREffectRenderer.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/7/2.
//

import Foundation
import Metal
import RagnarokShaders
import simd

public final class SPREffectRenderer {
    public let device: any MTLDevice

    private let renderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: (any MTLDepthStencilState)?

    public init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "sprEffectVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "sprEffectFragmentShader")
        renderPipelineDescriptor.maxVertexAmplificationCount = configuration.amplificationCount
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = configuration.colorPixelFormat
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat
        renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    public func render(
        resource: SPREffectRenderResource,
        elapsedTime: TimeInterval,
        worldPosition: SIMD3<Float>,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        guard let texture = resource.texture(elapsedTime: elapsedTime) else {
            return
        }

        let worldPosition = resource.adjustedWorldPosition(worldPosition)
        var vertexUniforms = SPREffectVertexUniforms(
            modelMatrix: modelMatrix,
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix,
            worldPosition: worldPosition,
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
