//
//  STREffectRenderer.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2023/11/24.
//

import Foundation
import Metal
import RagnarokCore
import RagnarokRenderAssets
import RagnarokRendering
import RagnarokShaders
import simd

@MainActor
public protocol STREffectRenderable: EffectInstance {
    func makeSTRRenderPayloads(
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext
    ) -> [STREffectRenderer.RenderPayload]
}

public enum STREffectRenderMode: Int32, Sendable, Hashable {
    case billboard = 0
    case ground = 1
    case screen = 2
}

/// Runtime transform overrides matching `CEZ2STRParticle` (`scale`, `alpha`, `angle`/`pitch`/`yaw`, `flip`, `lift`, `offset`).
public struct STREffectTransform: Sendable, Equatable {
    public static let identity = STREffectTransform()

    public var scale: Float
    public var alpha: Float
    public var angle: Float
    public var pitch: Float
    public var yaw: Float
    public var flipX: Bool
    public var flipY: Bool
    public var lift: Float
    public var offset: SIMD2<Float>

    public init(
        scale: Float = 1,
        alpha: Float = 1,
        angle: Float = 0,
        pitch: Float = 0,
        yaw: Float = 0,
        flipX: Bool = false,
        flipY: Bool = false,
        lift: Float = 0,
        offset: SIMD2<Float> = .zero
    ) {
        self.scale = scale
        self.alpha = alpha
        self.angle = angle
        self.pitch = pitch
        self.yaw = yaw
        self.flipX = flipX
        self.flipY = flipY
        self.lift = lift
        self.offset = offset
    }
}

public final class STREffectRenderer {
    public struct RenderPayload {
        public let asset: STREffectAsset
        public let frameIndex: Int
        public let frame: STREffectAnimation.Frame?
        public let mode: STREffectRenderMode
        public let worldPosition: SIMD3<Float>
        public let transform: STREffectTransform
        public let fog: Fog
        public let modelMatrix: simd_float4x4
        public let terrainHeight: ((_ worldX: Float, _ worldZ: Float) -> Float)?

        public init(
            asset: STREffectAsset,
            frameIndex: Int = 0,
            frame: STREffectAnimation.Frame? = nil,
            mode: STREffectRenderMode = .billboard,
            worldPosition: SIMD3<Float>,
            transform: STREffectTransform = .identity,
            fog: Fog,
            modelMatrix: simd_float4x4 = matrix_identity_float4x4,
            terrainHeight: ((_ worldX: Float, _ worldZ: Float) -> Float)? = nil
        ) {
            self.asset = asset
            self.frameIndex = frameIndex
            self.frame = frame
            self.mode = mode
            self.worldPosition = worldPosition
            self.transform = transform
            self.fog = fog
            self.modelMatrix = modelMatrix
            self.terrainHeight = terrainHeight
        }
    }

    private static let pixelRatio: Float = 1.0 / 35.0
    private static let groundHeightOffset: Float = 0.08
    private static let groundCliffClampDelta: Float = 1.0

    public let device: any MTLDevice
    public let configuration: RenderConfiguration

    private var renderPipelineStates: [SIMD2<Int32> : any MTLRenderPipelineState] = [:]
    private let depthStencilState: (any MTLDepthStencilState)?
    private let screenDepthStencilState: (any MTLDepthStencilState)?

    public init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device
        self.configuration = configuration

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = configuration.depthCompareFunction
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)

        let screenDepthDescriptor = MTLDepthStencilDescriptor()
        screenDepthDescriptor.depthCompareFunction = .always
        screenDepthDescriptor.isDepthWriteEnabled = false
        screenDepthStencilState = device.makeDepthStencilState(descriptor: screenDepthDescriptor)

        let commonBlendKey = SIMD2<Int32>(5, 6)
        renderPipelineStates[commonBlendKey] = try makeRenderPipelineState(for: commonBlendKey)
    }

    // MARK: - RenderQueue Submission (New Dual-Path Engine)

    public func submit<Payload>(
        asset: STREffectAsset,
        frameIndex: Int,
        mode: STREffectRenderMode = .billboard,
        worldPosition: SIMD3<Float>,
        transform: STREffectTransform = .identity,
        fog: Fog,
        modelMatrix: simd_float4x4 = matrix_identity_float4x4,
        terrainHeight: ((_ worldX: Float, _ worldZ: Float) -> Float)? = nil,
        into queue: RenderQueue<Payload>,
        transformPayload: (RenderPayload) -> Payload
    ) {
        let payload = RenderPayload(
            asset: asset,
            frameIndex: frameIndex,
            mode: mode,
            worldPosition: worldPosition,
            transform: transform,
            fog: fog,
            modelMatrix: modelMatrix,
            terrainHeight: terrainHeight
        )

        submit(payload: payload, into: queue, transformPayload: transformPayload)
    }

    public func submit<Payload>(
        payload: RenderPayload,
        into queue: RenderQueue<Payload>,
        transformPayload: (RenderPayload) -> Payload
    ) {
        let bucket: RenderPassBucket = switch payload.mode {
        case .ground:
            .groundDecal
        case .billboard:
            .translucent
        case .screen:
            .overlay
        }

        queue.submit(
            bucket: bucket,
            worldCenter: payload.worldPosition,
            modelMatrix: payload.modelMatrix,
            payload: transformPayload(payload)
        )
    }

    public func render(
        payload: RenderPayload,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        let frame = payload.frame ?? payload.asset.animation.frame(atFrameIndex: payload.frameIndex)
        render(
            frame: frame,
            textures: payload.asset.textures,
            mode: payload.mode,
            worldPosition: payload.worldPosition,
            transform: payload.transform,
            fog: payload.fog,
            modelMatrix: payload.modelMatrix,
            terrainHeight: payload.terrainHeight,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )
    }

    // MARK: - Legacy Compatibility Entry Point

    public func render(
        resource: STREffectRenderResource,
        elapsedTime: TimeInterval,
        spritePosition: SIMD3<Float>,
        fog: Fog,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        guard let frame = resource.animation.frame(atElapsedTime: elapsedTime) else {
            return
        }

        render(
            frame: frame,
            textures: resource.textures,
            mode: .billboard,
            worldPosition: spritePosition,
            transform: .identity,
            fog: fog,
            modelMatrix: modelMatrix,
            terrainHeight: nil,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )
    }

    // MARK: - Core 3-Mode Rendering

    public func render(
        frame: STREffectAnimation.Frame,
        textures: [String : any MTLTexture],
        mode: STREffectRenderMode,
        worldPosition: SIMD3<Float>,
        transform: STREffectTransform,
        fog: Fog,
        modelMatrix: simd_float4x4,
        terrainHeight: ((_ worldX: Float, _ worldZ: Float) -> Float)?,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        guard !frame.sprites.isEmpty else {
            return
        }

        renderCommandEncoder.setDepthStencilState(mode == .screen ? screenDepthStencilState : depthStencilState)

        for sprite in frame.sprites {
            guard let texture = textures[sprite.textureName] else {
                continue
            }

            let blendKey = SIMD2(sprite.sourceAlpha, sprite.destinationAlpha)
            guard let renderPipelineState = renderPipelineState(for: blendKey) else {
                continue
            }

            let vertices: [STREffectVertex]
            switch mode {
            case .billboard, .screen:
                vertices = makeQuadVertices(for: sprite)
            case .ground:
                vertices = makeGroundVertices(
                    for: sprite,
                    worldPosition: worldPosition,
                    transform: transform,
                    cameraAzimuth: camera.azimuth,
                    terrainHeight: terrainHeight
                )
            }

            let spriteRotation = makeSpriteTransformMatrix(spriteAngleDegrees: sprite.angle, transform: transform)
            let localOffset = (sprite.position - SIMD2<Float>(320, 320)) * transform.scale + transform.offset
            let adjustedOffset = SIMD2<Float>(localOffset.x, localOffset.y - transform.lift)

            var vertexUniforms = STREffectVertexUniforms(
                modelMatrix: modelMatrix,
                viewMatrix: camera.viewMatrix,
                projectionMatrix: camera.projectionMatrix,
                spriteAngle: spriteRotation,
                spritePosition: worldPosition,
                spriteOffset: adjustedOffset,
                screenScale: SIMD2<Float>(1.0 / 320.0, 1.0 / 240.0),
                depthBias: mode == .billboard ? (0.1 + transform.lift * 0.001) : 0.0,
                renderMode: mode.rawValue
            )

            // D3DBLEND_ONE as destination is additive; blending fog color in would brighten it.
            let isAdditive = sprite.destinationAlpha == 2
            let modulatedColor = SIMD4<Float>(
                sprite.color.x,
                sprite.color.y,
                sprite.color.z,
                sprite.color.w * transform.alpha
            )

            var fragmentUniforms = STREffectFragmentUniforms(
                spriteColor: modulatedColor,
                fogUse: (mode != .screen && fog.isEnabled && !isAdditive) ? 1 : 0,
                fogNear: fog.near,
                fogFar: fog.far,
                fogColor: fog.color
            )

            renderCommandEncoder.setRenderPipelineState(renderPipelineState)
            vertices.withUnsafeBytes { bytes in
                renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
            }
            renderCommandEncoder.setVertexBytes(
                &vertexUniforms,
                length: MemoryLayout<STREffectVertexUniforms>.stride,
                index: 1
            )
            renderCommandEncoder.setFragmentBytes(
                &fragmentUniforms,
                length: MemoryLayout<STREffectFragmentUniforms>.stride,
                index: 0
            )
            renderCommandEncoder.setFragmentTexture(texture, index: 0)
            renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertices.count)
        }
    }

    // MARK: - Geometry & Pipeline Helpers

    private func makeGroundVertices(
        for sprite: STREffectAnimation.Sprite,
        worldPosition: SIMD3<Float>,
        transform: STREffectTransform,
        cameraAzimuth: Float,
        terrainHeight: ((_ worldX: Float, _ worldZ: Float) -> Float)?
    ) -> [STREffectVertex] {
        let xy = sprite.xy
        let rawCorners: [(SIMD2<Float>, SIMD2<Float>)] = [
            ([xy[0], xy[4]], [0, 0]),
            ([xy[1], xy[5]], [1, 0]),
            ([xy[3], xy[7]], [0, 1]),
            ([xy[2], xy[6]], [1, 1]),
        ]

        let spriteAngle = radians(-sprite.angle)
        let cosSprite = cosf(spriteAngle)
        let sinSprite = sinf(spriteAngle)

        let worldYaw = cameraAzimuth + radians(transform.angle)
        let cosYaw = cosf(worldYaw)
        let sinYaw = sinf(worldYaw)

        let scaleX = transform.flipX ? -transform.scale : transform.scale
        let scaleY = transform.flipY ? -transform.scale : transform.scale
        let centerOffset = sprite.position - SIMD2<Float>(320, 240)

        var previousHeight: Float?
        return rawCorners.map { corner, uv in
            let rx = corner.x * cosSprite - corner.y * sinSprite
            let ry = corner.x * sinSprite + corner.y * cosSprite

            let localX = (rx + centerOffset.x + transform.offset.x) * scaleX * Self.pixelRatio
            let localZ = (ry + centerOffset.y + transform.offset.y) * scaleY * Self.pixelRatio

            let worldX = worldPosition.x + localX * cosYaw - localZ * sinYaw
            let worldZ = worldPosition.z + localX * sinYaw + localZ * cosYaw

            var worldY: Float
            if let terrainHeight {
                worldY = terrainHeight(worldX, worldZ) + Self.groundHeightOffset + transform.lift * Self.pixelRatio
            } else {
                worldY = worldPosition.y + Self.groundHeightOffset + transform.lift * Self.pixelRatio
            }

            if let prev = previousHeight, prev - worldY > Self.groundCliffClampDelta {
                worldY = prev
            }
            previousHeight = worldY

            return STREffectVertex(position: [worldX, worldY, worldZ], textureCoordinate: uv)
        }
    }

    private func makeSpriteTransformMatrix(
        spriteAngleDegrees: Float,
        transform: STREffectTransform
    ) -> simd_float4x4 {
        let scaleX = transform.flipX ? -transform.scale : transform.scale
        let scaleY = transform.flipY ? -transform.scale : transform.scale

        var matrix = matrix_identity_float4x4
        if transform.yaw != 0 {
            matrix = matrix_rotate(matrix, radians(transform.yaw), [0, 1, 0])
        }
        if transform.pitch != 0 {
            matrix = matrix_rotate(matrix, radians(transform.pitch), [1, 0, 0])
        }
        let totalAngle = -spriteAngleDegrees + transform.angle
        if totalAngle != 0 {
            matrix = matrix_rotate(matrix, radians(totalAngle), [0, 0, 1])
        }
        if scaleX != 1 || scaleY != 1 {
            matrix = matrix_scale(matrix, [scaleX, scaleY, 1])
        }
        return matrix
    }

    private func makeQuadVertices(for sprite: STREffectAnimation.Sprite) -> [STREffectVertex] {
        let xy = sprite.xy
        return [
            STREffectVertex(position: [xy[0], xy[4], 0], textureCoordinate: [0, 0]),
            STREffectVertex(position: [xy[1], xy[5], 0], textureCoordinate: [1, 0]),
            STREffectVertex(position: [xy[3], xy[7], 0], textureCoordinate: [0, 1]),
            STREffectVertex(position: [xy[2], xy[6], 0], textureCoordinate: [1, 1]),
        ]
    }

    private func renderPipelineState(for blendKey: SIMD2<Int32>) -> (any MTLRenderPipelineState)? {
        if let renderPipelineState = renderPipelineStates[blendKey] {
            return renderPipelineState
        }

        guard let renderPipelineState = try? makeRenderPipelineState(for: blendKey) else {
            return nil
        }

        renderPipelineStates[blendKey] = renderPipelineState
        return renderPipelineState
    }

    private func makeRenderPipelineState(for blendKey: SIMD2<Int32>) throws -> any MTLRenderPipelineState {
        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "strEffectVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "strEffectFragmentShader")
        renderPipelineDescriptor.maxVertexAmplificationCount = configuration.amplificationCount
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = configuration.colorPixelFormat
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = mtlBlendFactor(blendKey.x)
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = mtlBlendFactor(blendKey.x)
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = mtlBlendFactor(blendKey.y)
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = mtlBlendFactor(blendKey.y)
        renderPipelineDescriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat

        return try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    }

    private func mtlBlendFactor(_ d3dBlend: Int32) -> MTLBlendFactor {
        switch d3dBlend {
        case 1:  .zero
        case 2:  .one
        case 3:  .sourceColor
        case 4:  .oneMinusSourceColor
        case 5:  .sourceAlpha
        case 6:  .oneMinusSourceAlpha
        case 7:  .destinationAlpha
        case 8:  .oneMinusDestinationAlpha
        case 9:  .destinationColor
        case 10: .oneMinusDestinationColor
        case 11: .sourceAlphaSaturated
        case 14: .blendColor
        case 15: .oneMinusBlendAlpha
        default: .sourceAlpha
        }
    }
}
