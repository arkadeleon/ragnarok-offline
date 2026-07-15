//
//  Effect2DRenderer.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/7/9.
//

import Foundation
import Metal
import RagnarokEffects
import RagnarokShaders
import simd

public final class Effect2DRenderer {
    public let device: any MTLDevice

    private var renderPipelineStates: [EffectParameters.BlendMode : any MTLRenderPipelineState] = [:]
    private let depthStencilState: (any MTLDepthStencilState)?
    private let overlayDepthStencilState: (any MTLDepthStencilState)?

    public init(device: any MTLDevice) throws {
        self.device = device

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)

        let overlayDepthStencilDescriptor = MTLDepthStencilDescriptor()
        overlayDepthStencilDescriptor.depthCompareFunction = .always
        overlayDepthStencilDescriptor.isDepthWriteEnabled = false
        overlayDepthStencilState = device.makeDepthStencilState(descriptor: overlayDepthStencilDescriptor)

        let commonBlendMode: EffectParameters.BlendMode = .oneMinusSourceAlpha
        renderPipelineStates[commonBlendMode] = try makeRenderPipelineState(for: commonBlendMode)
    }

    public func render(
        resource: Effect2DRenderResource,
        elapsedTime: TimeInterval,
        worldPosition: SIMD3<Float>,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4,
        cameraAzimuth: Float
    ) {
        guard let texture = resource.texture,
              let sample = resource.sample(elapsedTime: elapsedTime, worldPosition: worldPosition, cameraAzimuth: cameraAzimuth),
              let renderPipelineState = renderPipelineState(for: resource.definition.blendMode) else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(resource.definition.overlay ? overlayDepthStencilState : depthStencilState)

        resource.vertices.withUnsafeBytes { bytes in
            renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
        }

        var vertexUniforms = Effect2DVertexUniforms(
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            rotationMatrix: sample.rotationMatrix,
            worldPosition: sample.worldPosition,
            size: sample.size,
            offset: sample.offset,
            zIndex: resource.definition.zIndex
        )
        var fragmentUniforms = Effect2DFragmentUniforms(color: sample.color)

        renderCommandEncoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout<Effect2DVertexUniforms>.stride,
            index: 1
        )
        renderCommandEncoder.setFragmentBytes(
            &fragmentUniforms,
            length: MemoryLayout<Effect2DFragmentUniforms>.stride,
            index: 0
        )
        renderCommandEncoder.setFragmentTexture(texture, index: 0)
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
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "effect2DVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "effect2DFragmentShader")

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
