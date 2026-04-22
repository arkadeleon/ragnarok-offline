//
//  MetalSpriteRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokShaders
import simd

@MainActor
final class MetalSpriteRenderer {
    private let device: any MTLDevice
    private let renderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: (any MTLDepthStencilState)?

    init(device: any MTLDevice) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "spriteVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "spriteFragmentShader")
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
        drawables: [SpriteLayerDrawable],
        atTime time: CFTimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        matrices: MetalMapRenderer.RenderMatrices
    ) {
        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        for drawable in drawables {
            guard drawable.isVisible else {
                continue
            }

            var vertices = drawable.vertices

            guard let vertexBuffer = device.makeBuffer(
                bytes: &vertices,
                length: vertices.count * MemoryLayout<SpriteVertex>.stride,
                options: []
            ) else {
                continue
            }

            var uniforms = SpriteVertexUniforms(
                viewMatrix: matrices.viewMatrix,
                projectionMatrix: matrices.projectionMatrix,
                spriteWorldPosition: SIMD4<Float>(drawable.worldPosition, 0)
            )
            guard let uniformsBuffer = device.makeBuffer(
                bytes: &uniforms,
                length: MemoryLayout<SpriteVertexUniforms>.stride,
                options: []
            ) else {
                continue
            }

            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderCommandEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)
            renderCommandEncoder.setFragmentTexture(drawable.texture, index: 0)
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        }
    }
}
