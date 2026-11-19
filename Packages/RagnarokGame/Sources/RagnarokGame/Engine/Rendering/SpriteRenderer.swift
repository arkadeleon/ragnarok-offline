//
//  SpriteRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokRendering
import RagnarokShaders
import simd

final class SpriteRenderer {
    struct RenderPayload {
        let drawable: SpriteDrawable
        let fog: Fog
        let modelMatrix: simd_float4x4
    }

    let device: any MTLDevice
    let configuration: RenderConfiguration

    private let renderPipelineState: any MTLRenderPipelineState
    private let waterClippedRenderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: (any MTLDepthStencilState)?

    init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device
        self.configuration = configuration

        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "spriteVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "spriteFragmentShader")
        renderPipelineDescriptor.maxVertexAmplificationCount = configuration.amplificationCount
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = configuration.colorPixelFormat
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat
        renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "waterClippedSpriteFragmentShader")
        waterClippedRenderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = configuration.depthCompareFunction
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    func submit<Payload>(
        drawables: [SpriteDrawable],
        fog: Fog,
        modelMatrix: simd_float4x4,
        into queue: RenderQueue<Payload>,
        transform: (SpriteRenderer.RenderPayload) -> Payload
    ) {
        for drawable in drawables {
            guard drawable.isVisible, !drawable.layers.isEmpty else {
                continue
            }

            let payload = SpriteRenderer.RenderPayload(
                drawable: drawable,
                fog: fog,
                modelMatrix: modelMatrix
            )
            queue.submit(
                bucket: .translucent,
                translucentPasses: .all,
                worldCenter: drawable.worldPosition,
                modelMatrix: modelMatrix,
                payload: transform(payload)
            )
        }
    }

    func render(
        payload: SpriteRenderer.RenderPayload,
        viewport: MTLViewport,
        camera: RenderCamera,
        waterClipMode: Int32 = 0,
        waterDepthTexture: (any MTLTexture)? = nil,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        if waterClipMode != 0, let waterDepthTexture {
            renderCommandEncoder.setRenderPipelineState(waterClippedRenderPipelineState)
            renderCommandEncoder.setFragmentTexture(waterDepthTexture, index: 1)
        } else {
            renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        }
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        let drawable = payload.drawable
        let fog = payload.fog
        var uniforms = SpriteVertexUniforms(
            modelMatrix: payload.modelMatrix,
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix,
            spriteWorldPosition: SIMD4<Float>(drawable.worldPosition, 0),
            cameraPosition: SIMD4<Float>(camera.position, 1),
            viewport: SIMD4<Float>(
                Float(viewport.originX),
                Float(viewport.originY),
                Float(viewport.width),
                Float(viewport.height)
            ),
            shadow: drawable.shadow,
            fogUse: fog.isEnabled ? 1 : 0,
            fogNear: fog.near,
            fogFar: fog.far,
            fogColor: fog.color,
            waterClipMode: waterClipMode,
            isDepthReversed: configuration.isDepthReversed ? 1 : 0
        )

        renderCommandEncoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<SpriteVertexUniforms>.stride,
            index: 1
        )
        renderCommandEncoder.setFragmentBytes(
            &uniforms,
            length: MemoryLayout<SpriteVertexUniforms>.stride,
            index: 0
        )

        for layer in drawable.layers {
            layer.vertices.withUnsafeBytes { bytes in
                renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
            }
            renderCommandEncoder.setFragmentTexture(layer.texture, index: 0)
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        }
    }
}
