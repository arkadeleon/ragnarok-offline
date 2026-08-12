//
//  MetalSpriteRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokRendering
import RagnarokShaders
import simd

@MainActor
final class MetalSpriteRenderer {
    let device: any MTLDevice

    private let renderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: (any MTLDepthStencilState)?

    init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "spriteVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "spriteFragmentShader")
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
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    func render(
        drawables: [SpriteLayerDrawable],
        framebufferSize: SIMD2<Float>,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        guard !drawables.isEmpty else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        for drawable in drawables {
            guard drawable.isVisible else {
                continue
            }

            var uniforms = SpriteVertexUniforms(
                viewMatrix: camera.viewMatrix,
                projectionMatrix: camera.projectionMatrix,
                spriteWorldPosition: SIMD4<Float>(drawable.worldPosition, 0),
                cameraPosition: SIMD4<Float>(camera.position, 1),
                framebufferSize: framebufferSize
            )

            drawable.vertices.withUnsafeBytes { bytes in
                renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
            }
            renderCommandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<SpriteVertexUniforms>.stride, index: 1)
            renderCommandEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<SpriteVertexUniforms>.stride, index: 0)
            renderCommandEncoder.setFragmentTexture(drawable.texture, index: 0)
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        }
    }
}
