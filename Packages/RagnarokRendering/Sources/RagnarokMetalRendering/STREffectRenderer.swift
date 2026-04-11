//
//  STREffectRenderer.swift
//  RagnarokMetalRendering
//
//  Created by Leon Li on 2023/11/24.
//

import Metal
import RagnarokRenderAssets
import RagnarokShaders
import simd

func mtlBlendFactor(_ d3dBlend: Int32) -> MTLBlendFactor {
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

class STREffectRenderer {
    let renderPipelineStates: [SIMD2<Int32> : any MTLRenderPipelineState]
    let depthStencilState: (any MTLDepthStencilState)?

    let effect: STREffect
    let textures: [String : any MTLTexture]

    init(device: any MTLDevice, library: any MTLLibrary, effect: STREffect, textures: [String : any MTLTexture]) throws {
        var blendKeys: Set<SIMD2<Int32>> = []
        for frame in effect.frames {
            for sprite in frame.sprites {
                let blendKey = SIMD2(sprite.sourceAlpha, sprite.destinationAlpha)
                blendKeys.insert(blendKey)
            }
        }

        var renderPipelineStates: [SIMD2<Int32> : any MTLRenderPipelineState] = [:]
        for blendKey in blendKeys {
            let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
            renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "effectVertexShader")
            renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "effectFragmentShader")

            renderPipelineDescriptor.colorAttachments[0].pixelFormat = Formats.colorPixelFormat
            renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
            renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = mtlBlendFactor(blendKey.x)
            renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = mtlBlendFactor(blendKey.x)
            renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = mtlBlendFactor(blendKey.y)
            renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = mtlBlendFactor(blendKey.y)

            renderPipelineDescriptor.depthAttachmentPixelFormat = Formats.depthPixelFormat

            renderPipelineStates[blendKey] = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        }
        self.renderPipelineStates = renderPipelineStates

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = false

        self.depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)

        self.effect = effect
        self.textures = textures
    }

    func render(
        atTime time: CFTimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4
    ) {
        let device = renderCommandEncoder.device

        let frameIndex = Int(time * CFTimeInterval(effect.fps)) % effect.frames.count
        let frame = effect.frames[frameIndex]

        renderCommandEncoder.setDepthStencilState(depthStencilState)

        for sprite in frame.sprites {
            guard sprite.vertices.count > 0, let vertexBuffer = device.makeBuffer(bytes: sprite.vertices, length: sprite.vertices.count * MemoryLayout<EffectVertex>.stride, options: []) else {
                continue
            }

            let blendKey = SIMD2(sprite.sourceAlpha, sprite.destinationAlpha)
            guard let renderPipelineState = renderPipelineStates[blendKey] else {
                continue
            }

            var vertexUniforms = EffectVertexUniforms(
                modelMatrix: modelMatrix,
                viewMatrix: viewMatrix,
                projectionMatrix: projectionMatrix,
                spriteAngle: matrix_identity_float4x4,
                spritePosition: .zero,
                spriteOffset: sprite.position - [320, 320]
            )
            guard let vertexUniformsBuffer = device.makeBuffer(bytes: &vertexUniforms, length: MemoryLayout<EffectVertexUniforms>.stride, options: []) else {
                continue
            }

            var fragmentUniforms = EffectFragmentUniforms(
                spriteColor: sprite.color
            )
            guard let fragmentUniformsBuffer = device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<EffectFragmentUniforms>.stride, options: []) else {
                continue
            }

            renderCommandEncoder.setRenderPipelineState(renderPipelineState)

            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderCommandEncoder.setVertexBuffer(vertexUniformsBuffer, offset: 0, index: 1)

            renderCommandEncoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

            let texture = textures[sprite.textureName]
            renderCommandEncoder.setFragmentTexture(texture, index: 0)

            renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: sprite.vertices.count)
        }
    }
}
