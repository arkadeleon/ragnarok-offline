//
//  SkyboxRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/8.
//

import CoreGraphics
import Metal
import RagnarokRendering
import RagnarokShaders
import simd

@MainActor
final class SkyboxRenderer {
    let device: any MTLDevice

    private let renderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: (any MTLDepthStencilState)?

    init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "skyboxVertexShader")
        descriptor.fragmentFunction = library.makeFunction(name: "skyboxFragmentShader")
        descriptor.maxVertexAmplificationCount = configuration.amplificationCount
        descriptor.colorAttachments[0].pixelFormat = configuration.colorPixelFormat
        descriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat
        renderPipelineState = try device.makeRenderPipelineState(descriptor: descriptor)

        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .always
        depthDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthDescriptor)
    }

    func render(
        resource: SkyboxRenderResource,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        cameraParameters: CameraParameters
    ) {
        guard resource.writeUniforms(
            projectionMatrix: cameraParameters.projectionMatrix,
            viewMatrix: cameraParameters.viewMatrix,
            cameraPosition: cameraParameters.cameraPosition
        ) else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)
        renderCommandEncoder.setFragmentBuffer(resource.uniformsBuffer, offset: 0, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }
}
