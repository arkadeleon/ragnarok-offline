//
//  MetalCombatTextRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/7/15.
//

import Metal
import RagnarokRendering
import RagnarokShaders
import simd

@MainActor
final class MetalCombatTextRenderer {
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

        // Combat text is always visible.
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .always
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    func render(
        resources: [CombatTextRenderResource],
        renderCommandEncoder: any MTLRenderCommandEncoder,
        cameraParameters: CameraParameters
    ) {
        guard !resources.isEmpty else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        let now = ContinuousClock.now
        for resource in resources {
            guard let sample = resource.sample(for: now, cameraAzimuth: cameraParameters.cameraAzimuth) else {
                continue
            }

            var uniforms = SpriteVertexUniforms(
                viewMatrix: cameraParameters.viewMatrix,
                projectionMatrix: cameraParameters.projectionMatrix,
                spriteWorldPosition: SIMD4<Float>(sample.worldPosition, 0),
                cameraPosition: SIMD4<Float>(cameraParameters.cameraPosition, 0),
                framebufferSize: .zero
            )

            sample.vertices.withUnsafeBytes { bytes in
                renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
            }
            renderCommandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<SpriteVertexUniforms>.stride, index: 1)
            renderCommandEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<SpriteVertexUniforms>.stride, index: 0)
            renderCommandEncoder.setFragmentTexture(sample.texture, index: 0)
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        }
    }
}
