//
//  CylinderEffectRenderer.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/6/25.
//

import Foundation
import Metal
import RagnarokEffects
import RagnarokShaders
import simd

public final class CylinderEffectRenderer {
    public let device: any MTLDevice

    private var renderPipelineStates: [EffectParameters.BlendMode : any MTLRenderPipelineState] = [:]
    private let depthStencilState: (any MTLDepthStencilState)?

    public init(device: any MTLDevice) throws {
        self.device = device

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)

        let commonBlendMode: EffectParameters.BlendMode = .one
        renderPipelineStates[commonBlendMode] = try makeRenderPipelineState(for: commonBlendMode)
    }

    public func render(
        resource: CylinderEffectRenderResource,
        elapsedTime: TimeInterval,
        worldPosition: SIMD3<Float>,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4,
        cameraAzimuth: Float
    ) {
        guard let snapshot = resource.snapshot(elapsedTime: elapsedTime, cameraAzimuth: cameraAzimuth),
              !resource.vertices.isEmpty,
              let renderPipelineState = renderPipelineState(for: resource.definition.blendMode) else {
            return
        }

        var vertexUniforms = CylinderEffectVertexUniforms(
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            rotationMatrix: snapshot.rotationMatrix,
            worldPosition: worldPosition,
            positionOffset: resource.definition.positionOffset,
            topRadius: snapshot.topRadius,
            bottomRadius: snapshot.bottomRadius,
            height: snapshot.height,
            zIndex: resource.definition.zIndex
        )
        var fragmentUniforms = CylinderEffectFragmentUniforms(color: snapshot.color)

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        resource.vertices.withUnsafeBytes { bytes in
            renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
        }
        renderCommandEncoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout<CylinderEffectVertexUniforms>.stride,
            index: 1
        )
        renderCommandEncoder.setFragmentBytes(
            &fragmentUniforms,
            length: MemoryLayout<CylinderEffectFragmentUniforms>.stride,
            index: 0
        )
        renderCommandEncoder.setFragmentTexture(resource.texture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: resource.vertices.count)
    }

    private func renderPipelineState(for blendMode: EffectParameters.BlendMode) -> (any MTLRenderPipelineState)? {
        if let renderPipelineState = renderPipelineStates[blendMode] {
            return renderPipelineState
        }

        guard let renderPipelineState = try? makeRenderPipelineState(for: blendMode) else {
            return nil
        }

        renderPipelineStates[blendMode] = renderPipelineState
        return renderPipelineState
    }

    private func makeRenderPipelineState(for blendMode: EffectParameters.BlendMode) throws -> any MTLRenderPipelineState {
        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "cylinderEffectVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "cylinderEffectFragmentShader")

        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Formats.colorPixelFormat
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = mtlBlendFactor(blendMode)
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = mtlBlendFactor(blendMode)

        renderPipelineDescriptor.depthAttachmentPixelFormat = Formats.depthPixelFormat

        return try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    }

    private func mtlBlendFactor(_ blendMode: EffectParameters.BlendMode) -> MTLBlendFactor {
        switch blendMode {
        case .zero: .zero
        case .one: .one
        case .sourceColor: .sourceColor
        case .oneMinusSourceColor: .oneMinusSourceColor
        case .destinationColor: .destinationColor
        case .oneMinusDestinationColor: .oneMinusDestinationColor
        case .sourceAlpha: .sourceAlpha
        case .oneMinusSourceAlpha: .oneMinusSourceAlpha
        case .destinationAlpha: .destinationAlpha
        case .oneMinusDestinationAlpha: .oneMinusDestinationAlpha
        case .constantColor: .blendColor
        case .oneMinusConstantColor: .oneMinusBlendColor
        case .constantAlpha: .blendAlpha
        case .oneMinusConstantAlpha: .oneMinusBlendAlpha
        case .sourceAlphaSaturated: .sourceAlphaSaturated
        }
    }
}
