//
//  MetalCombatTextRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/7/15.
//

import Metal
import RagnarokShaders
import simd

@MainActor
final class MetalCombatTextRenderer {
    let device: any MTLDevice

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

        // Combat text is always visible.
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .always
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    func render(
        resources: [CombatTextRenderResource],
        renderCommandEncoder: any MTLRenderCommandEncoder,
        matrices: MetalMapRenderer.RenderMatrices
    ) {
        guard !resources.isEmpty else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        let now = ContinuousClock.now
        for resource in resources {
            guard let snapshot = resource.snapshot(at: now, cameraAzimuth: matrices.cameraAzimuth) else {
                continue
            }

            var uniforms = SpriteVertexUniforms(
                viewMatrix: matrices.viewMatrix,
                projectionMatrix: matrices.projectionMatrix,
                spriteWorldPosition: SIMD4<Float>(snapshot.worldPosition, 0),
                cameraPosition: SIMD4<Float>(matrices.cameraPosition, 0),
                framebufferSize: .zero
            )

            snapshot.vertices.withUnsafeBytes { bytes in
                renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
            }
            renderCommandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<SpriteVertexUniforms>.stride, index: 1)
            renderCommandEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<SpriteVertexUniforms>.stride, index: 0)
            renderCommandEncoder.setFragmentTexture(snapshot.texture, index: 0)
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        }
    }
}
