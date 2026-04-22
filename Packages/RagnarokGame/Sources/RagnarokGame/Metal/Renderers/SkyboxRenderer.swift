//
//  SkyboxRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/8.
//

import CoreGraphics
import Metal
import RagnarokShaders
import simd

@MainActor
final class SkyboxRenderer {
    private let device: any MTLDevice
    private let renderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: (any MTLDepthStencilState)?

    init(device: any MTLDevice) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "skyboxVertexShader")
        descriptor.fragmentFunction = library.makeFunction(name: "skyboxFragmentShader")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        descriptor.depthAttachmentPixelFormat = .depth32Float
        renderPipelineState = try device.makeRenderPipelineState(descriptor: descriptor)

        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .always
        depthDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthDescriptor)
    }

    func render(
        resource: SkyboxRenderResource,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        projectionMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        cameraPosition: SIMD3<Float>
    ) {
        guard resource.writeUniforms(
            projectionMatrix: projectionMatrix,
            viewMatrix: viewMatrix,
            cameraPosition: cameraPosition
        ) else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)
        renderCommandEncoder.setFragmentBuffer(resource.uniformsBuffer, offset: 0, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }
}
