//
//  EffectRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/24.
//

import Metal
import simd
import ROShaders

class EffectRenderer {
    let renderPipelineState: any MTLRenderPipelineState
    let depthStencilState: (any MTLDepthStencilState)?

    let effect: Effect
    let textures: [String : any MTLTexture]

    let fog = Fog(
        use: false,
        exist: true,
        far: 30,
        near: 80,
        factor: 1,
        color: [1, 1, 1]
    )

    init(device: any MTLDevice, library: any MTLLibrary, effect: Effect, textures: [String : any MTLTexture]) throws {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()

        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "effectVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "effectFragmentShader")

        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Formats.colorPixelFormat
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        renderPipelineDescriptor.depthAttachmentPixelFormat = Formats.depthPixelFormat

        self.renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true

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

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        for sprite in frame.sprites {
            guard sprite.vertices.count > 0, let vertexBuffer = device.makeBuffer(bytes: sprite.vertices, length: sprite.vertices.count * MemoryLayout<EffectVertex>.stride, options: []) else {
                return
            }

            var vertexUniforms = EffectVertexUniforms(
                modelMatrix: modelMatrix,
                viewMatrix: viewMatrix,
                projectionMatrix: projectionMatrix,
                spriteAngle: matrix_identity_float4x4,
                spritePosition: .zero,
                spriteOffset: sprite.position
            )
            guard let vertexUniformsBuffer = device.makeBuffer(bytes: &vertexUniforms, length: MemoryLayout<EffectVertexUniforms>.stride, options: []) else {
                return
            }

            var fragmentUniforms = EffectFragmentUniforms(
                spriteColor: sprite.color,
                fogUse: fog.use && fog.exist ? 1 : 0,
                fogNear: fog.near,
                fogFar: fog.far,
                fogColor: fog.color
            )
            guard let fragmentUniformsBuffer = device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<EffectFragmentUniforms>.stride, options: []) else {
                return
            }

            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderCommandEncoder.setVertexBuffer(vertexUniformsBuffer, offset: 0, index: 1)

            renderCommandEncoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

            let texture = textures[sprite.textureName]
            renderCommandEncoder.setFragmentTexture(texture, index: 0)

            renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: sprite.vertices.count)
        }
    }
}
