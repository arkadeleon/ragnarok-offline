//
//  STREffectRenderer.swift
//  RagnarokRenderers
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

    private var renderPipelineStates: [SIMD2<Int32> : any MTLRenderPipelineState] = [:]
    private let depthStencilState: (any MTLDepthStencilState)?

    public init(device: any MTLDevice) throws {
        self.device = device

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)

        let commonBlendKey = SIMD2<Int32>(5, 6)
        renderPipelineStates[commonBlendKey] = try makeRenderPipelineState(for: commonBlendKey)
    }

    public func render(
        resource: STREffectRenderResource,
        elapsedTime: TimeInterval,
        spritePosition: SIMD3<Float>,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4
    ) {
        guard let frame = resource.effect.frame(atElapsedTime: elapsedTime) else {
            return
        }

        renderCommandEncoder.setDepthStencilState(depthStencilState)

        for sprite in frame.sprites {
            guard sprite.vertices.count > 0, let vertexBuffer = device.makeBuffer(bytes: sprite.vertices, length: sprite.vertices.count * MemoryLayout<STREffectVertex>.stride, options: []) else {
                continue
            }

            let blendKey = SIMD2(sprite.sourceAlpha, sprite.destinationAlpha)
            guard let renderPipelineState = renderPipelineState(for: blendKey) else {
                continue
            }

            var vertexUniforms = STREffectVertexUniforms(
                modelMatrix: modelMatrix,
                viewMatrix: viewMatrix,
                projectionMatrix: projectionMatrix,
                spriteAngle: matrix_rotate(matrix_identity_float4x4, radians(-sprite.angle), [0, 0, 1]),
                spritePosition: spritePosition,
                spriteOffset: sprite.position - [320, 320]
            )
            guard let vertexUniformsBuffer = device.makeBuffer(bytes: &vertexUniforms, length: MemoryLayout<STREffectVertexUniforms>.stride, options: []) else {
                continue
            }

            var fragmentUniforms = STREffectFragmentUniforms(
                spriteColor: sprite.color
            )
            guard let fragmentUniformsBuffer = device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<STREffectFragmentUniforms>.stride, options: []) else {
                continue
            }

            renderCommandEncoder.setRenderPipelineState(renderPipelineState)

            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderCommandEncoder.setVertexBuffer(vertexUniformsBuffer, offset: 0, index: 1)

            renderCommandEncoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

            let texture = resource.textures[sprite.textureName]
            renderCommandEncoder.setFragmentTexture(texture, index: 0)

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

        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Formats.colorPixelFormat
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = mtlBlendFactor(blendKey.x)
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = mtlBlendFactor(blendKey.x)
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = mtlBlendFactor(blendKey.y)
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = mtlBlendFactor(blendKey.y)

        renderPipelineDescriptor.depthAttachmentPixelFormat = Formats.depthPixelFormat

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
