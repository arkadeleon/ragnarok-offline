//
//  EffectViewerTargetRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/11/26.
//

import CoreGraphics
import Foundation
import Metal
import RagnarokConstants
import RagnarokEffects
import RagnarokRendering
import RagnarokResources
import RagnarokSprite
import simd

struct EffectViewerTargetSprite: @unchecked Sendable {
    struct DirectionFrame {
        let texture: any MTLTexture
        let width: Float
        let height: Float
        let centerOffset: SIMD2<Float>
    }

    let frames: [SpriteDirection : DirectionFrame]

    func frame(for direction: SpriteDirection) -> DirectionFrame? {
        frames[direction] ?? frames[.south] ?? frames.values.first
    }

    static func loadNovice(
        device: any MTLDevice,
        resourceManager: ResourceManager
    ) async -> EffectViewerTargetSprite? {
        var configuration = ComposedSprite.Configuration(jobID: JobID.novice.rawValue)
        configuration.gender = .male
        configuration.hairStyle = 1

        guard let composedSprite = try? await ComposedSprite(
            configuration: configuration,
            resourceManager: resourceManager
        ) else {
            return nil
        }

        let animationRenderer = SpriteAnimationRenderer(scale: 2)
        var frames: [SpriteDirection : DirectionFrame] = [:]
        frames.reserveCapacity(SpriteDirection.allCases.count)

        for direction in SpriteDirection.allCases {
            let animation = await animationRenderer.render(
                composedSprite: composedSprite,
                actionType: .idle,
                direction: direction,
                headDirection: .lookForward,
                rendersShadow: true
            )
            guard let image = animation.firstFrame,
                  let texture = MetalTextureFactory.makeTexture(
                      from: image,
                      device: device,
                      label: "effect-viewer-novice-\(direction)"
                  ) else {
                continue
            }

            frames[direction] = DirectionFrame(
                texture: texture,
                width: Float(animation.frameWidth),
                height: Float(animation.frameHeight),
                centerOffset: SIMD2<Float>(
                    -Float(animation.pivot.x),
                    Float(animation.pivot.y)
                )
            )
        }

        guard !frames.isEmpty else {
            return nil
        }
        return EffectViewerTargetSprite(frames: frames)
    }
}

struct EffectViewerTargetModifiers: Sendable {
    struct Timed<Value: Sendable>: Sendable {
        var value: Value
        var remainingTime: TimeInterval
        var totalTime: TimeInterval
    }

    struct Outline: Sendable, Equatable {
        let color: SIMD4<Float>
        let spread: Float
        let layers: Int
    }

    struct FourWaySplit: Sendable, Equatable {
        let spread: Float
        let alpha: Float
    }

    struct AfterimageRequest: Sendable, Equatable {
        let style: EffectAfterimageStyle
        let tint: SIMD4<Float>?
        let duration: TimeInterval
    }

    struct ActiveAfterimage: Sendable {
        let snapshot: EffectViewerTargetRenderer.RenderPayload
        let tint: SIMD3<Float>
        let initialAlpha: Float
        var remainingTime: TimeInterval
        let totalTime: TimeInterval
    }

    var tint: Timed<SIMD4<Float>>?
    var flash: Timed<SIMD4<Float>>?
    var alpha: Timed<Float>?
    var cloakingAlpha: Timed<Float>?
    var scale: Timed<SIMD3<Float>>?
    var facingYawDegrees: Timed<Float>?
    var spriteRollDegrees: Timed<Float>?
    var spriteOffset: Timed<SIMD2<Float>>?
    var outline: Timed<Outline>?
    var fourWaySplit: Timed<FourWaySplit>?
    var shake: Timed<Float>?

    private var shakeElapsedTime: TimeInterval = 0
    private var pendingAfterimages: [AfterimageRequest] = []
    private var activeAfterimages: [ActiveAfterimage] = []

    var effectiveTintColor: SIMD3<Float> {
        var color = SIMD3<Float>(repeating: 1)
        if let tint {
            color *= SIMD3<Float>(tint.value.x, tint.value.y, tint.value.z)
        }
        if let flash {
            let ratio = Float(flash.remainingTime / max(flash.totalTime, 1e-6))
            let weight = min(max(flash.value.w, 0), 1) * min(max(ratio, 0), 1)
            let flashRGB = SIMD3<Float>(flash.value.x, flash.value.y, flash.value.z)
            color = simd_mix(color, flashRGB, SIMD3<Float>(repeating: weight))
        }
        return color
    }

    var effectiveAlphaMultiplier: Float {
        var multiplier: Float = 1
        if let alpha {
            multiplier *= min(max(alpha.value, 0), 1)
        }
        if let cloakingAlpha {
            multiplier *= min(max(cloakingAlpha.value, 0), 1)
        }
        return min(max(multiplier, 0), 1)
    }

    var effectiveScale: SIMD2<Float> {
        if let scale {
            [scale.value.x, scale.value.y]
        } else {
            .one
        }
    }

    var effectiveFacingYawDegrees: Float {
        facingYawDegrees?.value ?? 0
    }

    var effectiveSpriteRollRadians: Float {
        (spriteRollDegrees?.value ?? 0) * .pi / 180
    }

    var effectiveSpriteOffset: SIMD2<Float> {
        spriteOffset?.value ?? .zero
    }

    var effectiveOutline: Outline? {
        outline?.value
    }

    var effectiveFourWaySplit: FourWaySplit? {
        fourWaySplit?.value
    }

    var effectiveWorldOffset: SIMD3<Float> {
        guard let shake else {
            return .zero
        }
        let decay = Float(shake.remainingTime / max(shake.totalTime, 1e-6))
        let magnitude = shake.value * max(decay, 0) * 0.05
        let elapsed = Float(shakeElapsedTime)
        return [sin(elapsed * 60) * magnitude, 0, cos(elapsed * 47) * magnitude]
    }

    mutating func apply(_ modifier: EffectTargetModifier) {
        switch modifier {
        case .tint(let color, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            tint = Timed(value: color, remainingTime: duration, totalTime: duration)
        case .flash(let color, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            flash = Timed(value: color, remainingTime: duration, totalTime: duration)
        case .alpha(let value, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            let clamped = min(max(value, 0), 1)
            alpha = Timed(value: clamped, remainingTime: duration, totalTime: duration)
        case .cloaking(let value):
            let duration = Self.duration(fromTicks: 2)
            let clamped = min(max(value, 0), 1)
            cloakingAlpha = Timed(value: clamped, remainingTime: duration, totalTime: duration)
        case .scale(let value, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            let clamped = simd_max(value, SIMD3<Float>(repeating: 0.01))
            scale = Timed(value: clamped, remainingTime: duration, totalTime: duration)
        case .facingYaw(let degrees, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            facingYawDegrees = Timed(value: degrees, remainingTime: duration, totalTime: duration)
        case .spriteRoll(let degrees, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            spriteRollDegrees = Timed(value: degrees, remainingTime: duration, totalTime: duration)
        case .spriteOffset(let offset, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            spriteOffset = Timed(value: offset, remainingTime: duration, totalTime: duration)
        case .outline(let color, let spread, let layers, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            let value = Outline(color: color, spread: max(spread, 0), layers: max(layers, 1))
            outline = Timed(value: value, remainingTime: duration, totalTime: duration)
        case .fourWaySplit(let spread, let alpha, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            let value = FourWaySplit(spread: max(spread, 0), alpha: min(max(alpha, 0), 1))
            fourWaySplit = Timed(value: value, remainingTime: duration, totalTime: duration)
        case .shake(let amplitude, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            shake = Timed(value: amplitude, remainingTime: duration, totalTime: duration)
        case .afterimage(let style, let tint, let durationTicks):
            let duration = Self.duration(fromTicks: durationTicks)
            pendingAfterimages.append(AfterimageRequest(style: style, tint: tint, duration: duration))
        }
    }

    mutating func update(deltaTime: TimeInterval) {
        guard deltaTime > 0 else {
            return
        }

        Self.decay(&tint, by: deltaTime)
        Self.decay(&flash, by: deltaTime)
        Self.decay(&alpha, by: deltaTime)
        Self.decay(&cloakingAlpha, by: deltaTime)
        Self.decay(&scale, by: deltaTime)
        Self.decay(&facingYawDegrees, by: deltaTime)
        Self.decay(&spriteRollDegrees, by: deltaTime)
        Self.decay(&spriteOffset, by: deltaTime)
        Self.decay(&outline, by: deltaTime)
        Self.decay(&fourWaySplit, by: deltaTime)
        Self.decay(&shake, by: deltaTime)

        if shake != nil {
            shakeElapsedTime += deltaTime
        } else {
            shakeElapsedTime = 0
        }

        if !activeAfterimages.isEmpty {
            activeAfterimages = activeAfterimages.compactMap { afterimage in
                var afterimage = afterimage
                afterimage.remainingTime -= deltaTime
                return afterimage.remainingTime > 0 ? afterimage : nil
            }
        }
    }

    mutating func collectPayloads(baseWorldPosition: SIMD3<Float>) -> [EffectViewerTargetRenderer.RenderPayload] {
        let mainPayload = EffectViewerTargetRenderer.RenderPayload(
            worldPosition: baseWorldPosition + effectiveWorldOffset + [0, 0.2, 0],
            tintColor: effectiveTintColor,
            alpha: effectiveAlphaMultiplier,
            scale: effectiveScale,
            facingYawDegrees: effectiveFacingYawDegrees,
            spriteRollRadians: effectiveSpriteRollRadians,
            spriteOffset: effectiveSpriteOffset,
            outline: effectiveOutline,
            fourWaySplit: effectiveFourWaySplit
        )

        if !pendingAfterimages.isEmpty {
            for request in pendingAfterimages {
                let (defaultTint, initialAlpha) = Self.afterimageDefaults(for: request.style)
                let tint = request.tint.map { SIMD3<Float>($0.x, $0.y, $0.z) } ?? defaultTint
                activeAfterimages.append(
                    ActiveAfterimage(
                        snapshot: mainPayload,
                        tint: tint,
                        initialAlpha: initialAlpha,
                        remainingTime: request.duration,
                        totalTime: request.duration
                    )
                )
            }
            pendingAfterimages.removeAll(keepingCapacity: true)
        }

        var payloads: [EffectViewerTargetRenderer.RenderPayload] = []
        payloads.reserveCapacity(1 + activeAfterimages.count)

        for afterimage in activeAfterimages {
            let ratio = Float(afterimage.remainingTime / max(afterimage.totalTime, 1e-6))
            let alphaMultiplier = afterimage.initialAlpha * min(max(ratio, 0), 1)
            guard alphaMultiplier > 0.001 else {
                continue
            }
            let base = afterimage.snapshot
            payloads.append(
                EffectViewerTargetRenderer.RenderPayload(
                    worldPosition: base.worldPosition,
                    tintColor: base.tintColor * afterimage.tint,
                    alpha: base.alpha * alphaMultiplier,
                    scale: base.scale,
                    facingYawDegrees: base.facingYawDegrees,
                    spriteRollRadians: base.spriteRollRadians,
                    spriteOffset: base.spriteOffset,
                    outline: nil,
                    fourWaySplit: nil
                )
            )
        }

        payloads.append(mainPayload)
        return payloads
    }

    private static let tickRate: TimeInterval = 60.0

    private static func duration(fromTicks ticks: Int) -> TimeInterval {
        TimeInterval(max(1, ticks)) / tickRate
    }

    private static func decay<Value>(_ channel: inout Timed<Value>?, by deltaTime: TimeInterval) {
        guard var current = channel else {
            return
        }
        current.remainingTime -= deltaTime
        channel = current.remainingTime > 0 ? current : nil
    }

    private static func afterimageDefaults(for style: EffectAfterimageStyle) -> (tint: SIMD3<Float>, alpha: Float) {
        switch style {
        case .blur:
            ([1, 1, 1], 0.65)
        case .hallucination:
            ([1, 1, 1], 0.55)
        case .paleBlur:
            ([155.0 / 255.0, 155.0 / 255.0, 1], 0.5)
        case .lightBlur:
            ([225.0 / 255.0, 225.0 / 255.0, 1], 0.7)
        }
    }
}

@MainActor
final class EffectViewerTargetRenderer {
    struct RenderPayload: Sendable {
        let worldPosition: SIMD3<Float>
        let tintColor: SIMD3<Float>
        let alpha: Float
        let scale: SIMD2<Float>
        let facingYawDegrees: Float
        let spriteRollRadians: Float
        let spriteOffset: SIMD2<Float>
        let outline: EffectViewerTargetModifiers.Outline?
        let fourWaySplit: EffectViewerTargetModifiers.FourWaySplit?
    }

    private struct Vertex {
        var position: SIMD2<Float>
        var textureCoordinate: SIMD2<Float>
        var color: SIMD4<Float>
    }

    private struct Uniforms {
        var modelMatrix: simd_float4x4
        var viewMatrix: simd_float4x4
        var projectionMatrix: simd_float4x4
        var spriteWorldPosition: SIMD4<Float>
        var cameraPosition: SIMD4<Float>
        var viewport: SIMD4<Float>
    }

    private let renderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: any MTLDepthStencilState

    init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        let library = try device.makeDefaultLibrary(bundle: .main)

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "effectViewerTargetVertex")
        descriptor.fragmentFunction = library.makeFunction(name: "effectViewerTargetFragment")
        descriptor.maxVertexAmplificationCount = configuration.amplificationCount
        descriptor.colorAttachments[0].pixelFormat = configuration.colorPixelFormat
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        descriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat
        renderPipelineState = try device.makeRenderPipelineState(descriptor: descriptor)

        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = configuration.depthCompareFunction
        depthDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthDescriptor)!
    }

    func submit<Payload>(
        payload: RenderPayload,
        into queue: RenderQueue<Payload>,
        transformPayload: (RenderPayload) -> Payload
    ) {
        guard payload.alpha > 0.001 else {
            return
        }

        queue.submit(
            bucket: .translucent,
            translucentPasses: .all,
            worldCenter: payload.worldPosition,
            modelMatrix: matrix_identity_float4x4,
            payload: transformPayload(payload)
        )
    }

    func render(
        payload: RenderPayload,
        targetSprite: EffectViewerTargetSprite,
        viewport: MTLViewport,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        let baseDirection = SpriteDirection.south.adjustedForCameraAzimuth(camera.azimuth)
        let directionStepOffset = Int((payload.facingYawDegrees / 45).rounded())
        let effectiveDirection: SpriteDirection
        if directionStepOffset == 0 {
            effectiveDirection = baseDirection
        } else {
            let shifted = ((baseDirection.rawValue + directionStepOffset) % 8 + 8) % 8
            effectiveDirection = SpriteDirection(rawValue: shifted) ?? baseDirection
        }

        guard let frame = targetSprite.frame(for: effectiveDirection) else {
            return
        }

        let baseVertices = makeQuadVertices(frame: frame, payload: payload)
        var drawQuads: [[Vertex]] = []

        if let outline = payload.outline, outline.color.w > 0, outline.spread > 0 {
            let layerCount = max(outline.layers, 1)
            for step in stride(from: layerCount, through: 1, by: -1) {
                let stepSpread = outline.spread * Float(step) / Float(layerCount)
                let outlineColor = SIMD4<Float>(
                    outline.color.x,
                    outline.color.y,
                    outline.color.z,
                    outline.color.w * payload.alpha
                )
                drawQuads.append(makeExpandedQuad(from: baseVertices, spread: stepSpread, color: outlineColor))
            }
        }

        drawQuads.append(baseVertices)

        if let fourWay = payload.fourWaySplit, fourWay.alpha > 0, fourWay.spread > 0 {
            let offsets: [SIMD2<Float>] = [
                [fourWay.spread, 0],
                [-fourWay.spread, 0],
                [0, fourWay.spread],
                [0, -fourWay.spread],
            ]
            for offset in offsets {
                drawQuads.append(makeShiftedQuad(from: baseVertices, offset: offset, alphaMultiplier: fourWay.alpha))
            }
        }

        var uniforms = Uniforms(
            modelMatrix: matrix_identity_float4x4,
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix,
            spriteWorldPosition: SIMD4<Float>(payload.worldPosition, 0),
            cameraPosition: SIMD4<Float>(camera.position, 1),
            viewport: SIMD4<Float>(
                Float(viewport.originX),
                Float(viewport.originY),
                Float(viewport.width),
                Float(viewport.height)
            )
        )

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)
        renderCommandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        renderCommandEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 0)
        renderCommandEncoder.setFragmentTexture(frame.texture, index: 0)

        for quad in drawQuads {
            quad.withUnsafeBytes { bytes in
                renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
            }
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        }
    }

    private func makeQuadVertices(
        frame: EffectViewerTargetSprite.DirectionFrame,
        payload: RenderPayload
    ) -> [Vertex] {
        let halfWidth = frame.width * payload.scale.x * 0.5
        let halfHeight = frame.height * payload.scale.y * 0.5
        let centerX = frame.centerOffset.x * payload.scale.x
        let centerY = frame.centerOffset.y * payload.scale.y
        let cosRoll = cos(payload.spriteRollRadians)
        let sinRoll = sin(payload.spriteRollRadians)

        func point(_ x: Float, _ y: Float) -> SIMD2<Float> {
            let local = SIMD2<Float>(centerX + x, centerY + y)
            let rotated: SIMD2<Float>
            if payload.spriteRollRadians == 0 {
                rotated = local
            } else {
                rotated = SIMD2<Float>(
                    local.x * cosRoll - local.y * sinRoll,
                    local.x * sinRoll + local.y * cosRoll
                )
            }
            return rotated + payload.spriteOffset
        }

        let color = SIMD4<Float>(
            payload.tintColor.x,
            payload.tintColor.y,
            payload.tintColor.z,
            payload.alpha
        )

        let topLeft = point(-halfWidth, halfHeight)
        let topRight = point(halfWidth, halfHeight)
        let bottomLeft = point(-halfWidth, -halfHeight)
        let bottomRight = point(halfWidth, -halfHeight)

        return [
            Vertex(position: topLeft, textureCoordinate: [0, 0], color: color),
            Vertex(position: topRight, textureCoordinate: [1, 0], color: color),
            Vertex(position: bottomLeft, textureCoordinate: [0, 1], color: color),
            Vertex(position: topRight, textureCoordinate: [1, 0], color: color),
            Vertex(position: bottomRight, textureCoordinate: [1, 1], color: color),
            Vertex(position: bottomLeft, textureCoordinate: [0, 1], color: color),
        ]
    }

    private func makeExpandedQuad(
        from vertices: [Vertex],
        spread: Float,
        color: SIMD4<Float>
    ) -> [Vertex] {
        guard !vertices.isEmpty else {
            return vertices
        }
        var minPos = vertices[0].position
        var maxPos = vertices[0].position
        for vertex in vertices {
            minPos = simd_min(minPos, vertex.position)
            maxPos = simd_max(maxPos, vertex.position)
        }
        let center = (minPos + maxPos) * 0.5
        return vertices.map { vertex in
            let delta = vertex.position - center
            let offset = SIMD2<Float>(
                delta.x >= 0 ? spread : -spread,
                delta.y >= 0 ? spread : -spread
            )
            return Vertex(
                position: vertex.position + offset,
                textureCoordinate: vertex.textureCoordinate,
                color: SIMD4<Float>(color.x, color.y, color.z, color.w)
            )
        }
    }

    private func makeShiftedQuad(
        from vertices: [Vertex],
        offset: SIMD2<Float>,
        alphaMultiplier: Float
    ) -> [Vertex] {
        vertices.map { vertex in
            Vertex(
                position: vertex.position + offset,
                textureCoordinate: vertex.textureCoordinate,
                color: SIMD4<Float>(vertex.color.x, vertex.color.y, vertex.color.z, vertex.color.w * alphaMultiplier)
            )
        }
    }
}
