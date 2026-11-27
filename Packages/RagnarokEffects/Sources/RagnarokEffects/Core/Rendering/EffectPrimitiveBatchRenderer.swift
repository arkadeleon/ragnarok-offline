//
//  EffectPrimitiveBatchRenderer.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

import Foundation
import Metal
import RagnarokRendering
import RagnarokShaders
import simd

typealias EffectPrimitivePipelineKey = EffectBlendKey

struct EffectPrimitiveDepthStencilKey: Hashable, Sendable {
    let depthTest: Bool
    let depthWrite: Bool
}

public final class EffectPrimitiveBatchRenderer {
    public struct RenderPayload {
        public let mode: EffectPrimitiveRenderMode
        public let texture: (any MTLTexture)?
        public let renderState: EffectPrimitiveRenderState
        public let worldCenter: SIMD3<Float>
        public let fog: Fog
        public let modelMatrix: simd_float4x4
        public var vertices: [EffectPrimitiveVertex]

        public init(
            mode: EffectPrimitiveRenderMode,
            texture: (any MTLTexture)?,
            renderState: EffectPrimitiveRenderState,
            worldCenter: SIMD3<Float>,
            fog: Fog,
            modelMatrix: simd_float4x4 = matrix_identity_float4x4,
            vertices: [EffectPrimitiveVertex]
        ) {
            self.mode = mode
            self.texture = texture
            self.renderState = renderState
            self.worldCenter = worldCenter
            self.fog = fog
            self.modelMatrix = modelMatrix
            self.vertices = vertices
        }
    }

    private static let inlineVertexBytesLimit = 4096

    public let device: any MTLDevice
    public let configuration: RenderConfiguration

    private var renderPipelineStates: [EffectPrimitivePipelineKey : any MTLRenderPipelineState] = [:]
    private var depthStencilStates: [EffectPrimitiveDepthStencilKey : any MTLDepthStencilState] = [:]
    let fallbackWhiteTexture: any MTLTexture

    var cachedPipelineCount: Int {
        renderPipelineStates.count
    }

    var cachedDepthStencilCount: Int {
        depthStencilStates.count
    }

    public init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device
        self.configuration = configuration
        self.fallbackWhiteTexture = try Self.makeFallbackWhiteTexture(device: device)

        // Pre-warm common alpha & additive pipelines and default depth state.
        let alphaKey = EffectPrimitivePipelineKey(srcBlend: .sourceAlpha, dstBlend: .oneMinusSourceAlpha)
        renderPipelineStates[alphaKey] = try makeRenderPipelineState(for: alphaKey)

        let additiveKey = EffectPrimitivePipelineKey(srcBlend: .sourceAlpha, dstBlend: .one)
        renderPipelineStates[additiveKey] = try makeRenderPipelineState(for: additiveKey)

        let defaultDepthKey = EffectPrimitiveDepthStencilKey(depthTest: true, depthWrite: false)
        if let state = makeDepthStencilState(for: defaultDepthKey) {
            depthStencilStates[defaultDepthKey] = state
        }
    }

    public func submit<Payload>(
        payload: RenderPayload,
        into queue: RenderQueue<Payload>,
        transformPayload: (RenderPayload) -> Payload
    ) {
        guard !payload.vertices.isEmpty else {
            return
        }

        queue.submit(
            bucket: payload.renderState.bucket,
            worldCenter: payload.worldCenter,
            modelMatrix: payload.modelMatrix,
            payload: transformPayload(payload)
        )
    }

    public func render(
        payload: RenderPayload,
        viewport: MTLViewport? = nil,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        guard !payload.vertices.isEmpty else {
            return
        }

        let pipelineKey = EffectPrimitivePipelineKey(
            srcBlend: payload.renderState.srcBlend,
            dstBlend: payload.renderState.dstBlend
        )
        guard let renderPipelineState = renderPipelineState(for: pipelineKey) else {
            return
        }

        let byteLength = payload.vertices.count * MemoryLayout<EffectPrimitiveVertex>.stride
        let vertexBuffer: (any MTLBuffer)?
        if byteLength > Self.inlineVertexBytesLimit {
            vertexBuffer = payload.vertices.withUnsafeBytes { bytes in
                guard let baseAddress = bytes.baseAddress else {
                    return nil
                }
                return device.makeBuffer(
                    bytes: baseAddress,
                    length: byteLength,
                    options: .storageModeShared
                )
            }
            guard vertexBuffer != nil else {
                return
            }
        } else {
            vertexBuffer = nil
        }

        let depthKey = EffectPrimitiveDepthStencilKey(
            depthTest: payload.renderState.depthTest,
            depthWrite: payload.renderState.depthWrite
        )
        if let depthStencilState = depthStencilState(for: depthKey) {
            renderCommandEncoder.setDepthStencilState(depthStencilState)
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setCullMode(payload.renderState.cullMode)

        if let vertexBuffer {
            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        } else {
            let didBind: Bool = payload.vertices.withUnsafeBytes { bytes in
                guard let baseAddress = bytes.baseAddress else {
                    return false
                }
                renderCommandEncoder.setVertexBytes(baseAddress, length: byteLength, index: 0)
                return true
            }
            guard didBind else {
                renderCommandEncoder.setCullMode(.none)
                return
            }
        }

        let viewportSize: SIMD2<Float>
        if let viewport, viewport.width > 0, viewport.height > 0 {
            viewportSize = [Float(viewport.width), Float(viewport.height)]
        } else {
            viewportSize = [640, 480]
        }
        var vertexUniforms = EffectPrimitiveVertexUniforms(
            modelMatrix: payload.modelMatrix,
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix,
            depthBias: payload.renderState.depthBias,
            renderMode: payload.mode.rawValue,
            viewportSize: viewportSize
        )
        renderCommandEncoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout<EffectPrimitiveVertexUniforms>.stride,
            index: 1
        )

        let shouldApplyFog = payload.fog.isEnabled
            && !payload.renderState.isAdditive
            && payload.renderState.bucket != .overlay
            && payload.mode != .screen2D
            && payload.mode != .screen2DAbsolute
        var fragmentUniforms = EffectPrimitiveFragmentUniforms(
            fogUse: shouldApplyFog ? 1 : 0,
            fogNear: payload.fog.near,
            fogFar: payload.fog.far,
            alphaTestThreshold: payload.renderState.alphaTestThreshold,
            fogColor: payload.fog.color
        )
        renderCommandEncoder.setFragmentBytes(
            &fragmentUniforms,
            length: MemoryLayout<EffectPrimitiveFragmentUniforms>.stride,
            index: 0
        )

        renderCommandEncoder.setFragmentTexture(payload.texture ?? fallbackWhiteTexture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: payload.vertices.count)
        renderCommandEncoder.setCullMode(.none)
    }

    // MARK: - Pipeline & State Cache

    func renderPipelineState(for key: EffectPrimitivePipelineKey) -> (any MTLRenderPipelineState)? {
        if let existing = renderPipelineStates[key] {
            return existing
        }

        guard let created = try? makeRenderPipelineState(for: key) else {
            return nil
        }

        renderPipelineStates[key] = created
        return created
    }

    private func makeRenderPipelineState(for key: EffectPrimitivePipelineKey) throws -> any MTLRenderPipelineState {
        guard let library = RagnarokShadersLibrary(device) else {
            throw NSError(
                domain: "RagnarokEffects.EffectPrimitiveBatchRenderer",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to load RagnarokShaders Metal library"]
            )
        }

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "effectPrimitiveVertexShader")
        descriptor.fragmentFunction = library.makeFunction(name: "effectPrimitiveFragmentShader")
        descriptor.maxVertexAmplificationCount = configuration.amplificationCount
        descriptor.colorAttachments[0].pixelFormat = configuration.colorPixelFormat
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].sourceRGBBlendFactor = key.srcBlend.mtlBlendFactor
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = key.srcBlend.mtlBlendFactor
        descriptor.colorAttachments[0].destinationRGBBlendFactor = key.dstBlend.mtlBlendFactor
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = key.dstBlend.mtlBlendFactor
        descriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat

        return try device.makeRenderPipelineState(descriptor: descriptor)
    }

    func depthStencilState(for key: EffectPrimitiveDepthStencilKey) -> (any MTLDepthStencilState)? {
        if let existing = depthStencilStates[key] {
            return existing
        }

        guard let created = makeDepthStencilState(for: key) else {
            return nil
        }

        depthStencilStates[key] = created
        return created
    }

    private func makeDepthStencilState(for key: EffectPrimitiveDepthStencilKey) -> (any MTLDepthStencilState)? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = key.depthTest ? configuration.depthCompareFunction : .always
        descriptor.isDepthWriteEnabled = key.depthWrite
        return device.makeDepthStencilState(descriptor: descriptor)
    }

    private static func makeFallbackWhiteTexture(device: any MTLDevice) throws -> any MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: 1,
            height: 1,
            mipmapped: false
        )
        descriptor.usage = .shaderRead
        guard let texture = device.makeTexture(descriptor: descriptor) else {
            throw NSError(
                domain: "RagnarokEffects.EffectPrimitiveBatchRenderer",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create fallback 1x1 white texture"]
            )
        }
        var whitePixel: [UInt8] = [255, 255, 255, 255]
        texture.replace(
            region: MTLRegionMake2D(0, 0, 1, 1),
            mipmapLevel: 0,
            withBytes: &whitePixel,
            bytesPerRow: 4
        )
        return texture
    }
}
