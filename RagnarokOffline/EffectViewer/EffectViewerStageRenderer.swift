//
//  EffectViewerStageRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import Metal
import RagnarokRendering
import simd

@MainActor
final class EffectViewerStageRenderer {
    static let centerCharcoalColor = SIMD3<Float>(0.118, 0.133, 0.169)
    static let edgeCharcoalColor = SIMD3<Float>(0.067, 0.075, 0.094)

    private struct BackdropUniforms {
        var centerColor: SIMD3<Float>
        var edgeColor: SIMD3<Float>
    }

    private struct GridUniforms {
        var viewProjectionMatrix: simd_float4x4
    }

    private let backdropPipelineState: any MTLRenderPipelineState
    private let backdropDepthStencilState: any MTLDepthStencilState
    private let gridPipelineState: any MTLRenderPipelineState
    private let gridDepthStencilState: any MTLDepthStencilState

    init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        let library = try device.makeDefaultLibrary(bundle: .main)

        let backdropDescriptor = MTLRenderPipelineDescriptor()
        backdropDescriptor.vertexFunction = library.makeFunction(name: "effectViewerBackdropVertex")
        backdropDescriptor.fragmentFunction = library.makeFunction(name: "effectViewerBackdropFragment")
        backdropDescriptor.maxVertexAmplificationCount = configuration.amplificationCount
        backdropDescriptor.colorAttachments[0].pixelFormat = configuration.colorPixelFormat
        backdropDescriptor.colorAttachments[0].isBlendingEnabled = false
        backdropDescriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat
        backdropPipelineState = try device.makeRenderPipelineState(descriptor: backdropDescriptor)

        let backdropDepthDescriptor = MTLDepthStencilDescriptor()
        backdropDepthDescriptor.depthCompareFunction = .always
        backdropDepthDescriptor.isDepthWriteEnabled = false
        backdropDepthStencilState = device.makeDepthStencilState(descriptor: backdropDepthDescriptor)!

        let gridDescriptor = MTLRenderPipelineDescriptor()
        gridDescriptor.vertexFunction = library.makeFunction(name: "effectViewerGridVertex")
        gridDescriptor.fragmentFunction = library.makeFunction(name: "effectViewerGridFragment")
        gridDescriptor.maxVertexAmplificationCount = configuration.amplificationCount
        gridDescriptor.colorAttachments[0].pixelFormat = configuration.colorPixelFormat
        gridDescriptor.colorAttachments[0].isBlendingEnabled = true
        gridDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        gridDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        gridDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        gridDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        gridDescriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat
        gridPipelineState = try device.makeRenderPipelineState(descriptor: gridDescriptor)

        let gridDepthDescriptor = MTLDepthStencilDescriptor()
        gridDepthDescriptor.depthCompareFunction = configuration.depthCompareFunction
        gridDepthDescriptor.isDepthWriteEnabled = false
        gridDepthStencilState = device.makeDepthStencilState(descriptor: gridDepthDescriptor)!
    }

    func renderBackdrop(renderCommandEncoder: any MTLRenderCommandEncoder) {
        var uniforms = BackdropUniforms(
            centerColor: Self.centerCharcoalColor,
            edgeColor: Self.edgeCharcoalColor
        )
        renderCommandEncoder.setRenderPipelineState(backdropPipelineState)
        renderCommandEncoder.setDepthStencilState(backdropDepthStencilState)
        renderCommandEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<BackdropUniforms>.stride, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
    }

    func renderGroundGrid(camera: RenderCamera, renderCommandEncoder: any MTLRenderCommandEncoder) {
        var uniforms = GridUniforms(
            viewProjectionMatrix: camera.projectionMatrix * camera.viewMatrix
        )
        renderCommandEncoder.setRenderPipelineState(gridPipelineState)
        renderCommandEncoder.setDepthStencilState(gridDepthStencilState)
        renderCommandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<GridUniforms>.stride, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }
}
