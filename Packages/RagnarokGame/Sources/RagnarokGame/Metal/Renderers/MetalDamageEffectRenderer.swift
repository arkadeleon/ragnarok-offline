//
//  MetalDamageEffectRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/4.
//

import Metal
import RagnarokShaders
import simd

@MainActor
final class MetalDamageEffectRenderer {
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
        resource: DamageEffectRenderResource,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        matrices: MetalMapRenderer.RenderMatrices
    ) {
        let now = ContinuousClock.now

        guard let texture = resource.texture else {
            return
        }

        let elapsed = now - resource.creationTime
        guard elapsed >= resource.delay else {
            return
        }

        let t = Float((elapsed - resource.delay).timeInterval / resource.duration.timeInterval)
        guard t >= 0, t < 1 else {
            return
        }

        let scale: Float
        let worldPosition: SIMD3<Float>
        switch resource.kind {
        case .miss:
            scale = 0.5
            worldPosition = [
                resource.startPosition.x,
                resource.startPosition.y + 3.5 + 7 * t,
                resource.startPosition.z,
            ]
        case .damage:
            scale = 4 * (1 - t)
            worldPosition = [
                resource.startPosition.x + 4 * t,
                resource.startPosition.y + 2 + sin(-.pi / 2 + (.pi * (0.5 + 1.5 * t))) * 5,
                resource.startPosition.z - 4 * t,
            ]
        }

        guard scale > 0 else {
            return
        }

        let frameWidth = resource.frameWidth * resource.spriteScale.x * scale
        let frameHeight = resource.frameHeight * resource.spriteScale.y * scale
        let halfW = frameWidth / 2
        let halfH = frameHeight / 2
        var color = resource.color
        color.w *= 1 - t

        let vertices: [SpriteVertex] = [
            SpriteVertex(position: [-halfW, -halfH], textureCoordinate: [0, 1], color: color),
            SpriteVertex(position: [ halfW, -halfH], textureCoordinate: [1, 1], color: color),
            SpriteVertex(position: [-halfW,  halfH], textureCoordinate: [0, 0], color: color),
            SpriteVertex(position: [ halfW, -halfH], textureCoordinate: [1, 1], color: color),
            SpriteVertex(position: [ halfW,  halfH], textureCoordinate: [1, 0], color: color),
            SpriteVertex(position: [-halfW,  halfH], textureCoordinate: [0, 0], color: color),
        ]

        var uniforms = SpriteVertexUniforms(
            viewMatrix: matrices.viewMatrix,
            projectionMatrix: matrices.projectionMatrix,
            spriteWorldPosition: SIMD4<Float>(worldPosition, 0)
        )

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        vertices.withUnsafeBytes { bytes in
            renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
        }
        renderCommandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<SpriteVertexUniforms>.stride, index: 1)
        renderCommandEncoder.setFragmentTexture(texture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    }
}
