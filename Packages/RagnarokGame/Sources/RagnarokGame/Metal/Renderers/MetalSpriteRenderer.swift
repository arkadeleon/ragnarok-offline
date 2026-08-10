//
//  MetalSpriteRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokRenderers
import RagnarokShaders
import simd

@MainActor
final class MetalSpriteRenderer {
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

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    func render(
        drawables: [SpriteLayerDrawable],
        framebufferSize: SIMD2<Float>,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        cameraParameters: CameraParameters
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
                viewMatrix: cameraParameters.viewMatrix,
                projectionMatrix: cameraParameters.projectionMatrix,
                spriteWorldPosition: SIMD4<Float>(drawable.worldPosition, 0),
                cameraPosition: SIMD4<Float>(cameraParameters.cameraPosition, 1),
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
