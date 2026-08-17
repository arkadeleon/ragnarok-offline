//
//  Effect3DRenderer.swift
//  RagnarokRendering
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
    public let configuration: RenderConfiguration

    private var renderPipelineStates: [EffectParameters.BlendMode : any MTLRenderPipelineState] = [:]
    private let depthStencilState: (any MTLDepthStencilState)?
    private let overlayDepthStencilState: (any MTLDepthStencilState)?

    public init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device
        self.configuration = configuration

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = configuration.depthCompareFunction
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
        sourceWorldPosition: SIMD3<Float>?,
        targetWorldPosition: SIMD3<Float>,
        fog: Fog,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        let sample = resource.sample(
            forElapsedTime: elapsedTime,
            worldPosition: worldPosition,
            sourceWorldPosition: sourceWorldPosition,
            targetWorldPosition: targetWorldPosition,
            cameraAzimuth: camera.azimuth
        )
        guard let sample, let renderPipelineState = renderPipelineState(for: resource.definition.blendMode) else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(resource.definition.overlay ? overlayDepthStencilState : depthStencilState)

        resource.vertices.withUnsafeBytes { bytes in
            renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
        }

        // Blending the fog color into an additive draw would only brighten it, so the
        // additive effects go through untouched.
        let isAdditive = resource.definition.blendMode == .one

        for layer in sample.layers {
            guard resource.textures.indices.contains(layer.imageIndex),
                  let texture = resource.textures[layer.imageIndex] else {
                continue
            }

            var vertexUniforms = Effect3DVertexUniforms(
                modelMatrix: modelMatrix,
                viewMatrix: camera.viewMatrix,
                projectionMatrix: camera.projectionMatrix,
                rotationMatrix: layer.rotationMatrix,
                worldPosition: sample.worldPosition,
                size: layer.size,
                offset: layer.offset,
                zIndex: resource.definition.zIndex
            )
            var fragmentUniforms = Effect3DFragmentUniforms(
                color: layer.color,
                fogUse: fog.isEnabled && !isAdditive ? 1 : 0,
                fogNear: fog.near,
                fogFar: fog.far,
                fogColor: fog.color
            )

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
        renderPipelineDescriptor.maxVertexAmplificationCount = configuration.amplificationCount
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = configuration.colorPixelFormat
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = mtlBlendFactor(blendMode)
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = mtlBlendFactor(blendMode)
        renderPipelineDescriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat

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
