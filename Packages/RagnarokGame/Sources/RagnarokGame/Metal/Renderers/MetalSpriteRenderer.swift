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
        damageEffects: [DamageEffectRenderResource],
        renderCommandEncoder: any MTLRenderCommandEncoder,
        matrices: MetalMapRenderer.RenderMatrices
    ) {
        guard !drawables.isEmpty || !damageEffects.isEmpty else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        for drawable in drawables {
            guard drawable.isVisible else {
                continue
            }
            encode(
                vertices: drawable.vertices,
                worldPosition: drawable.worldPosition,
                texture: drawable.texture,
                renderCommandEncoder: renderCommandEncoder,
                matrices: matrices
            )
        }

        let now = ContinuousClock.now
        for resource in damageEffects {
            guard let snapshot = resource.snapshot(at: now) else {
                continue
            }
            encode(
                vertices: snapshot.vertices,
                worldPosition: snapshot.worldPosition,
                texture: snapshot.texture,
                renderCommandEncoder: renderCommandEncoder,
                matrices: matrices
            )
        }
    }

    private func encode(
        vertices: [SpriteVertex],
        worldPosition: SIMD3<Float>,
        texture: any MTLTexture,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        matrices: MetalMapRenderer.RenderMatrices
    ) {
        var uniforms = SpriteVertexUniforms(
            viewMatrix: matrices.viewMatrix,
            projectionMatrix: matrices.projectionMatrix,
            spriteWorldPosition: SIMD4<Float>(worldPosition, 0)
        )

        vertices.withUnsafeBytes { bytes in
            renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
        }
        renderCommandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<SpriteVertexUniforms>.stride, index: 1)
        renderCommandEncoder.setFragmentTexture(texture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    }
}
