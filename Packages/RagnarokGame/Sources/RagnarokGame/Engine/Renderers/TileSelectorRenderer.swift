//
//  TileSelectorRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import Foundation
import Metal
import QuartzCore
import RagnarokRendering
import RagnarokShaders
import simd

final class TileSelectorRenderer {
    let device: any MTLDevice

    private let renderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: (any MTLDepthStencilState)?

    init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "tileVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "tileFragmentShader")
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
        depthStencilDescriptor.depthCompareFunction = configuration.depthCompareFunction
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    func render(
        resource: TileSelectorRenderResource,
        atTime time: TimeInterval,
        fog: Fog,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        guard resource.vertexCount > 0 else {
            return
        }

        guard time - resource.selectionShowTime < 0.5 else {
            return
        }

        var vertexUniforms = TileVertexUniforms(
            modelMatrix: modelMatrix,
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix
        )

        var fragmentUniforms = TileFragmentUniforms(
            fogUse: fog.isEnabled ? 1 : 0,
            fogNear: fog.near,
            fogFar: fog.far,
            fogColor: fog.color
        )

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        renderCommandEncoder.setVertexBuffer(resource.vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout<TileVertexUniforms>.stride,
            index: 1
        )
        renderCommandEncoder.setFragmentBytes(
            &fragmentUniforms,
            length: MemoryLayout<TileFragmentUniforms>.stride,
            index: 0
        )
        renderCommandEncoder.setFragmentTexture(resource.selectionTexture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: resource.vertexCount)
    }
}
