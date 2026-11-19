//
//  WaterRenderer.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2020/7/15.
//

import Foundation
import Metal
import RagnarokShaders
import simd

public final class WaterRenderer {
    public let device: any MTLDevice

    private let renderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: (any MTLDepthStencilState)?
    private let depthRenderPipelineState: any MTLRenderPipelineState
    private let depthWriteStencilState: (any MTLDepthStencilState)?

    public init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "waterVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "waterFragmentShader")
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
        depthStencilDescriptor.depthCompareFunction = configuration.depthCompareFunction
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)

        let depthPipelineDescriptor = MTLRenderPipelineDescriptor()
        depthPipelineDescriptor.vertexFunction = library.makeFunction(name: "waterVertexShader")
        depthPipelineDescriptor.fragmentFunction = nil
        depthPipelineDescriptor.maxVertexAmplificationCount = configuration.amplificationCount
        depthPipelineDescriptor.colorAttachments[0].pixelFormat = .invalid
        depthPipelineDescriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat
        depthRenderPipelineState = try device.makeRenderPipelineState(descriptor: depthPipelineDescriptor)

        let depthWriteDescriptor = MTLDepthStencilDescriptor()
        depthWriteDescriptor.depthCompareFunction = configuration.depthCompareFunction
        depthWriteDescriptor.isDepthWriteEnabled = true
        depthWriteStencilState = device.makeDepthStencilState(descriptor: depthWriteDescriptor)
    }

    public func renderDepth(
        resource: WaterRenderResource,
        atTime time: TimeInterval,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        guard resource.vertexCount > 0 else {
            return
        }

        var vertexUniforms = makeVertexUniforms(
            resource: resource,
            atTime: time,
            modelMatrix: modelMatrix,
            camera: camera
        )

        renderCommandEncoder.setRenderPipelineState(depthRenderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthWriteStencilState)
        renderCommandEncoder.setVertexBuffer(resource.vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout<WaterVertexUniforms>.stride,
            index: 1
        )
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: resource.vertexCount)
    }

    public func render(
        resource: WaterRenderResource,
        atTime time: TimeInterval,
        fog: Fog,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        let frame = Float(time * 60)

        guard resource.vertexCount > 0, !resource.textures.isEmpty else {
            return
        }

        var vertexUniforms = makeVertexUniforms(
            resource: resource,
            atTime: time,
            modelMatrix: modelMatrix,
            camera: camera
        )

        var fragmentUniforms = WaterFragmentUniforms(
            lightAmbient: resource.light.ambient,
            lightDiffuse: resource.light.diffuse,
            lightOpacity: resource.light.opacity,
            opacity: resource.waterOpacity,
            fogUse: fog.isEnabled ? 1 : 0,
            fogNear: fog.near,
            fogFar: fog.far,
            fogColor: fog.color
        )

        let texture = resource.textures[Int(frame / resource.waterAnimationSpeed) % resource.textures.count]

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        renderCommandEncoder.setVertexBuffer(resource.vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout<WaterVertexUniforms>.stride,
            index: 1
        )
        renderCommandEncoder.setFragmentBytes(
            &fragmentUniforms,
            length: MemoryLayout<WaterFragmentUniforms>.stride,
            index: 0
        )
        renderCommandEncoder.setFragmentTexture(texture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: resource.vertexCount)
    }

    private func makeVertexUniforms(
        resource: WaterRenderResource,
        atTime time: TimeInterval,
        modelMatrix: simd_float4x4,
        camera: RenderCamera
    ) -> WaterVertexUniforms {
        let frame = Float(time * 60)
        return WaterVertexUniforms(
            modelMatrix: modelMatrix,
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix,
            waveHeight: resource.waveHeight,
            wavePitch: resource.wavePitch,
            waterOffset: (frame * resource.waveSpeed).truncatingRemainder(dividingBy: 360) - 180
        )
    }
}
