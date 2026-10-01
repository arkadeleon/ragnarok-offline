//
//  GroundRenderer.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2020/7/3.
//

import Foundation
import Metal
import RagnarokShaders
import simd

public final class GroundRenderer {
    public let device: any MTLDevice

    private let renderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: (any MTLDepthStencilState)?

    public init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "groundVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "groundFragmentShader")
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
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    public func render(
        resource: GroundRenderResource,
        atTime time: TimeInterval,
        fog: Fog,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        guard let vertexBuffer = resource.vertexBuffer else {
            return
        }

        var vertexUniforms = GroundVertexUniforms(
            modelMatrix: modelMatrix,
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix,
            lightDirection: resource.light.direction,
            lightAmbient: resource.light.ambient,
            lightDiffuse: resource.light.diffuse
        )

        var fragmentUniforms = GroundFragmentUniforms(
            lightMapUse: resource.lightmapTexture == nil ? 0 : 1,
            fogUse: fog.isEnabled ? 1 : 0,
            fogNear: fog.near,
            fogFar: fog.far,
            fogColor: fog.color
        )

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout<GroundVertexUniforms>.stride,
            index: 1
        )
        renderCommandEncoder.setFragmentBytes(
            &fragmentUniforms,
            length: MemoryLayout<GroundFragmentUniforms>.stride,
            index: 0
        )
        renderCommandEncoder.setFragmentTexture(resource.lightmapTexture, index: 1)

        for mesh in resource.meshes {
            renderCommandEncoder.setFragmentTexture(mesh.texture, index: 0)
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: mesh.vertexStart, vertexCount: mesh.vertexCount)
        }
    }
}
