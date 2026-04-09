//
//  MetalSkyboxRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/8.
//

import CoreGraphics
import Metal
import RagnarokShaders
import simd

@MainActor
final class MetalSkyboxRenderer {
    private let device: any MTLDevice

    private let renderPipelineState: (any MTLRenderPipelineState)?
    private let depthStencilState: (any MTLDepthStencilState)?

    private var uniformsBuffer: (any MTLBuffer)?
    private var configuration: SkyboxConfiguration?

    init(device: any MTLDevice) throws {
        self.device = device

        let library = RagnarokCreateShadersLibrary(device)!

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

    func configure(with configuration: SkyboxConfiguration) {
        self.configuration = configuration
        if uniformsBuffer == nil {
            uniformsBuffer = device.makeBuffer(
                length: MemoryLayout<SkyboxUniforms>.size,
                options: .storageModeShared
            )
        }
    }

    func render(
        renderCommandEncoder: any MTLRenderCommandEncoder,
        projectionMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        cameraPosition: SIMD3<Float>
    ) {
        guard let renderPipelineState,
              let depthStencilState,
              let uniformsBuffer,
              let configuration else {
            return
        }

        let inverseViewProjectionMatrix = (projectionMatrix * viewMatrix).inverse
        var uniforms = SkyboxUniforms(
            topColor: simd4(from: configuration.topColor),
            horizonColor: simd4(from: configuration.horizonColor),
            bottomColor: simd4(from: configuration.bottomColor),
            sphereCenterAndRadius: SIMD4<Float>(
                configuration.center.x,
                configuration.center.y,
                configuration.center.z,
                configuration.radius
            ),
            cameraPosition: SIMD4<Float>(
                cameraPosition.x,
                cameraPosition.y,
                cameraPosition.z,
                1
            ),
            inverseViewProjectionMatrix: inverseViewProjectionMatrix
        )
        memcpy(uniformsBuffer.contents(), &uniforms, MemoryLayout<SkyboxUniforms>.size)

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)
        renderCommandEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }

    private func simd4(from color: CGColor) -> SIMD4<Float> {
        guard let components = color.components, components.count >= 3 else {
            return .zero
        }
        return SIMD4<Float>(Float(components[0]), Float(components[1]), Float(components[2]), 1)
    }
}
