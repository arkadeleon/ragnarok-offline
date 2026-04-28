//
//  MetalTileSelectorRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import QuartzCore
import RagnarokShaders
import simd

@MainActor
final class MetalTileSelectorRenderer {
    private let device: any MTLDevice
    private let renderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: (any MTLDepthStencilState)?

    init(device: any MTLDevice) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "tileVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "tileFragmentShader")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    func render(
        resource: TileSelectorRenderResource,
        atTime time: CFTimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        matrices: MetalMapRenderer.RenderMatrices
    ) {
        guard resource.vertexCount > 0 else {
            return
        }

        guard time - resource.selectionShowTime < 0.5 else {
            return
        }

        var uniforms = TileVertexUniforms(
            viewMatrix: matrices.viewMatrix,
            projectionMatrix: matrices.projectionMatrix
        )

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)
        renderCommandEncoder.setVertexBuffer(resource.vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<TileVertexUniforms>.stride, index: 1)
        renderCommandEncoder.setFragmentTexture(resource.selectionTexture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: resource.vertexCount)
    }
}
