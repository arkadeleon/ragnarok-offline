//
//  STREffectRenderer.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2023/11/24.
//

import Foundation
import Metal
import RagnarokCore
import RagnarokRenderAssets
import RagnarokShaders
import simd

public final class STREffectRenderer {
    public let device: any MTLDevice
    public let configuration: RenderConfiguration

    private var renderPipelineStates: [SIMD2<Int32> : any MTLRenderPipelineState] = [:]
    private let depthStencilState: (any MTLDepthStencilState)?

    public init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device
        self.configuration = configuration

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = configuration.depthCompareFunction
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)

        let commonBlendKey = SIMD2<Int32>(5, 6)
        renderPipelineStates[commonBlendKey] = try makeRenderPipelineState(for: commonBlendKey)
    }

    public func render(
        resource: STREffectRenderResource,
        elapsedTime: TimeInterval,
        spritePosition: SIMD3<Float>,
        fog: Fog,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        guard let frame = resource.effect.frame(atElapsedTime: elapsedTime) else {
            return
        }

        renderCommandEncoder.setDepthStencilState(depthStencilState)

        for sprite in frame.sprites {
            guard !sprite.vertices.isEmpty else {
                continue
            }

            let blendKey = SIMD2(sprite.sourceAlpha, sprite.destinationAlpha)
            guard let renderPipelineState = renderPipelineState(for: blendKey) else {
                continue
            }

            var vertexUniforms = STREffectVertexUniforms(
                modelMatrix: modelMatrix,
                viewMatrix: camera.viewMatrix,
                projectionMatrix: camera.projectionMatrix,
                spriteAngle: matrix_rotate(matrix_identity_float4x4, radians(-sprite.angle), [0, 0, 1]),
                spritePosition: spritePosition,
                spriteOffset: sprite.position - [320, 320]
            )

            // D3DBLEND_ONE as the destination means the sprite adds to what is behind
            // it, and blending the fog color in would only brighten it.
            let isAdditive = sprite.destinationAlpha == 2

            var fragmentUniforms = STREffectFragmentUniforms(
                spriteColor: sprite.color,
                fogUse: fog.isEnabled && !isAdditive ? 1 : 0,
                fogNear: fog.near,
                fogFar: fog.far,
                fogColor: fog.color
            )

            renderCommandEncoder.setRenderPipelineState(renderPipelineState)

            sprite.vertices.withUnsafeBytes { bytes in
                renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
            }
            renderCommandEncoder.setVertexBytes(
                &vertexUniforms,
                length: MemoryLayout<STREffectVertexUniforms>.stride,
                index: 1
            )
            renderCommandEncoder.setFragmentBytes(
                &fragmentUniforms,
                length: MemoryLayout<STREffectFragmentUniforms>.stride,
                index: 0
            )
            renderCommandEncoder.setFragmentTexture(resource.textures[sprite.textureName], index: 0)
            renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: sprite.vertices.count)
        }
    }

    private func renderPipelineState(for blendKey: SIMD2<Int32>) -> (any MTLRenderPipelineState)? {
        if let renderPipelineState = renderPipelineStates[blendKey] {
            return renderPipelineState
        }

        guard let renderPipelineState = try? makeRenderPipelineState(for: blendKey) else {
            return nil
        }

        renderPipelineStates[blendKey] = renderPipelineState
        return renderPipelineState
    }

    private func makeRenderPipelineState(for blendKey: SIMD2<Int32>) throws -> any MTLRenderPipelineState {
        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "strEffectVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "strEffectFragmentShader")
        renderPipelineDescriptor.maxVertexAmplificationCount = configuration.amplificationCount
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = configuration.colorPixelFormat
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = mtlBlendFactor(blendKey.x)
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = mtlBlendFactor(blendKey.x)
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = mtlBlendFactor(blendKey.y)
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = mtlBlendFactor(blendKey.y)
        renderPipelineDescriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat

        return try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    }

    private func mtlBlendFactor(_ d3dBlend: Int32) -> MTLBlendFactor {
        switch d3dBlend {
        case 1:  .zero
        case 2:  .one
        case 3:  .sourceColor
        case 4:  .oneMinusSourceColor
        case 5:  .sourceAlpha
        case 6:  .oneMinusSourceAlpha
        case 7:  .destinationAlpha
        case 8:  .oneMinusDestinationAlpha
        case 9:  .destinationColor
        case 10: .oneMinusDestinationColor
        case 11: .sourceAlphaSaturated
        case 14: .blendColor
        case 15: .oneMinusBlendAlpha
        default: .sourceAlpha
        }
    }
}
