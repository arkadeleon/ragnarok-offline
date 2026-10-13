//
//  TargetSelectorRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/13.
//

import Metal
import RagnarokRendering
import RagnarokShaders
import simd

final class TargetSelectorRenderer {
    let device: any MTLDevice

    private let renderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: (any MTLDepthStencilState)?

    private let ringVertexBuffer: (any MTLBuffer)?
    private let ringVertexCount: Int
    private let gemVertexBuffer: (any MTLBuffer)?
    private let gemVertexCount: Int

    init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "targetSelectorVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "targetSelectorFragmentShader")
        renderPipelineDescriptor.maxVertexAmplificationCount = configuration.amplificationCount
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = configuration.colorPixelFormat
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat
        renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        // The marker is always visible.
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .always
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)

        let mesh = TargetSelectorMesh()

        ringVertexBuffer = mesh.ringVertices.withUnsafeBytes { bytes in
            device.makeBuffer(bytes: bytes.baseAddress!, length: bytes.count)
        }
        ringVertexBuffer?.label = "target-selector-ring"
        ringVertexCount = mesh.ringVertices.count

        gemVertexBuffer = mesh.gemVertices.withUnsafeBytes { bytes in
            device.makeBuffer(bytes: bytes.baseAddress!, length: bytes.count)
        }
        gemVertexBuffer?.label = "target-selector-gem"
        gemVertexCount = mesh.gemVertices.count
    }

    func render(
        targetSelector: MapSceneRenderSnapshot.TargetSelector,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        guard let ringVertexBuffer, let gemVertexBuffer else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        let parts = [
            (ringVertexBuffer, ringVertexCount, targetSelector.ringCenterHeight),
            (gemVertexBuffer, gemVertexCount, targetSelector.gemTopHeight),
        ]
        for (vertexBuffer, vertexCount, height) in parts {
            var uniforms = TargetSelectorVertexUniforms(
                modelMatrix: modelMatrix,
                viewMatrix: camera.viewMatrix,
                projectionMatrix: camera.projectionMatrix,
                worldPosition: targetSelector.worldPosition,
                offset: [0, height]
            )

            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderCommandEncoder.setVertexBytes(
                &uniforms,
                length: MemoryLayout<TargetSelectorVertexUniforms>.stride,
                index: 1
            )
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
        }
    }
}
