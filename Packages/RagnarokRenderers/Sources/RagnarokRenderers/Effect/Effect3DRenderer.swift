//
//  Effect3DRenderer.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/6/29.
//

import Foundation
import Metal
import RagnarokEffects
import RagnarokShaders
import simd

public final class Effect3DRenderer {
    public let device: any MTLDevice

    private var renderPipelineStates: [EffectParameters.BlendMode : any MTLRenderPipelineState] = [:]
    private let depthStencilState: (any MTLDepthStencilState)?
    private let overlayDepthStencilState: (any MTLDepthStencilState)?

    public init(device: any MTLDevice) throws {
        self.device = device

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)

        let overlayDepthStencilDescriptor = MTLDepthStencilDescriptor()
        overlayDepthStencilDescriptor.depthCompareFunction = .always
        overlayDepthStencilDescriptor.isDepthWriteEnabled = false
        overlayDepthStencilState = device.makeDepthStencilState(descriptor: overlayDepthStencilDescriptor)

        let commonBlendMode: EffectParameters.BlendMode = .oneMinusSourceAlpha
        renderPipelineStates[commonBlendMode] = try makeRenderPipelineState(for: commonBlendMode)
    }

    public func render(
        resource: Effect3DRenderResource,
        elapsedTime: TimeInterval,
        worldPosition: SIMD3<Float>,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4,
        cameraAzimuth: Float
    ) {
        guard let sample = resource.sample(elapsedTime: elapsedTime, worldPosition: worldPosition, cameraAzimuth: cameraAzimuth),
              let renderPipelineState = renderPipelineState(for: resource.definition.blendMode) else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(resource.definition.overlay ? overlayDepthStencilState : depthStencilState)

        resource.vertices.withUnsafeBytes { bytes in
            renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
        }

        for layer in sample.layers {
            guard resource.textures.indices.contains(layer.imageIndex),
                  let texture = resource.textures[layer.imageIndex] else {
                continue
            }

            var vertexUniforms = Effect3DVertexUniforms(
                modelMatrix: modelMatrix,
                viewMatrix: viewMatrix,
                projectionMatrix: projectionMatrix,
                rotationMatrix: layer.rotationMatrix,
                worldPosition: sample.worldPosition,
                size: layer.size,
                offset: layer.offset,
                zIndex: resource.definition.zIndex
            )
            var fragmentUniforms = Effect3DFragmentUniforms(color: layer.color)

            renderCommandEncoder.setVertexBytes(
                &vertexUniforms,
                length: MemoryLayout<Effect3DVertexUniforms>.stride,
                index: 1
            )
            renderCommandEncoder.setFragmentBytes(
                &fragmentUniforms,
                length: MemoryLayout<Effect3DFragmentUniforms>.stride,
                index: 0
            )
            renderCommandEncoder.setFragmentTexture(texture, index: 0)
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: resource.vertices.count)
        }
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
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "effect3DVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "effect3DFragmentShader")

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
