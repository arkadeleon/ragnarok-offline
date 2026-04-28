//
//  WaterRenderer.swift
//  RagnarokMetalRendering
//
//  Created by Leon Li on 2020/7/15.
//

import Metal
import RagnarokShaders
import simd

public final class WaterRenderer {
    let device: any MTLDevice
    let renderPipelineState: any MTLRenderPipelineState
    let depthStencilState: (any MTLDepthStencilState)?

    public init(device: any MTLDevice) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "waterVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "waterFragmentShader")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Formats.colorPixelFormat
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.depthAttachmentPixelFormat = Formats.depthPixelFormat
        renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    public func render(
        resource: WaterRenderResource,
        atTime time: CFTimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4
    ) {
        let frame = Float(time * 60)

        guard resource.vertexCount > 0, !resource.textures.isEmpty else {
            return
        }

        var vertexUniforms = WaterVertexUniforms(
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            waveHeight: resource.waveHeight,
            wavePitch: resource.wavePitch,
            waterOffset: (frame * resource.waveSpeed).truncatingRemainder(dividingBy: 360) - 180
        )

        var fragmentUniforms = WaterFragmentUniforms(
            lightAmbient: resource.light.ambient,
            lightDiffuse: resource.light.diffuse,
            lightOpacity: resource.light.opacity,
            opacity: resource.waterOpacity
        )

        let texture = resource.textures[Int(frame / resource.waterAnimationSpeed) % resource.textures.count]

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        renderCommandEncoder.setVertexBuffer(resource.vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBytes(&vertexUniforms, length: MemoryLayout<WaterVertexUniforms>.stride, index: 1)

        renderCommandEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<WaterFragmentUniforms>.stride, index: 0)
        renderCommandEncoder.setFragmentTexture(texture, index: 0)

        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: resource.vertexCount)
    }
}
