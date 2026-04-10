//
//  MetalDamageEffectRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/4.
//

import CoreGraphics
import CoreText
import Foundation
import Metal
import RagnarokShaders
import simd

@MainActor
final class MetalDamageEffectRenderer {
    struct ResolvedTarget {
        var startPosition: SIMD3<Float>
        var isPlayerTarget: Bool
    }

    private enum EffectKind {
        case miss
        case damage
    }

    private struct EffectEntry {
        var id: UUID
        var creationTime: ContinuousClock.Instant
        var kind: EffectKind
        var delay: TimeInterval
        var duration: TimeInterval
        var startPosition: SIMD3<Float>
        var texture: (any MTLTexture)?
        var frameWidth: Float
        var frameHeight: Float
    }

    private let device: any MTLDevice

    private let renderPipelineState: (any MTLRenderPipelineState)?
    private let depthStencilState: (any MTLDepthStencilState)?

    private var entries: [UUID : EffectEntry] = [:]

    init(device: any MTLDevice) throws {
        self.device = device

        let library = RagnarokCreateShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "spriteVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "spriteFragmentShader")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    func reset() {
        entries.removeAll()
    }

    func sync(
        with damageEffects: [MapDamageEffect],
        resolveTarget: (MapDamageEffect) -> ResolvedTarget?
    ) {
        let activeEffectIDs = Set(damageEffects.map(\.id))
        entries = entries.filter { activeEffectIDs.contains($0.key) }

        for effect in damageEffects where entries[effect.id] == nil {
            guard let resolvedTarget = resolveTarget(effect) else {
                continue
            }

            let string = effect.amount == 0 ? "MISS" : "\(effect.amount)"
            let color = color(for: effect, isPlayerTarget: resolvedTarget.isPlayerTarget)
            let image = makeImage(for: string, color: color)
            let texture = MetalTextureFactory.makeTexture(
                from: image,
                device: device,
                label: "damage-effect-\(effect.id.uuidString)"
            )

            let duration = effect.amount == 0 ? 0.8 : 1.5
            let size = image.map {
                SIMD2<Float>(Float($0.width), Float($0.height))
            } ?? SIMD2<Float>(64, 24)

            entries[effect.id] = EffectEntry(
                id: effect.id,
                creationTime: effect.creationTime,
                kind: effect.amount == 0 ? .miss : .damage,
                delay: effect.delay / 1000,
                duration: duration,
                startPosition: resolvedTarget.startPosition,
                texture: texture,
                frameWidth: size.x,
                frameHeight: size.y
            )
        }
    }

    func render(
        renderCommandEncoder: any MTLRenderCommandEncoder,
        matrices: MapRuntimeRenderer.RenderMatrices
    ) {
        guard let renderPipelineState, let depthStencilState else {
            return
        }

        let now = ContinuousClock.now

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        for entry in entries.values.sorted(by: { $0.creationTime < $1.creationTime }) {
            guard let texture = entry.texture else {
                continue
            }

            let elapsed = (now - entry.creationTime).timeInterval
            guard elapsed >= entry.delay else {
                continue
            }

            let t = Float((elapsed - entry.delay) / entry.duration)
            guard t >= 0, t < 1 else {
                continue
            }

            let scale: Float
            let worldPosition: SIMD3<Float>
            switch entry.kind {
            case .miss:
                scale = 2.5
                worldPosition = [
                    entry.startPosition.x,
                    entry.startPosition.y + 3.5 + 7 * t,
                    entry.startPosition.z,
                ]
            case .damage:
                scale = 4 * (1 - t)
                worldPosition = [
                    entry.startPosition.x + 4 * t,
                    entry.startPosition.y + 2 + sin(-.pi / 2 + (.pi * (0.5 + 1.5 * t))) * 5,
                    entry.startPosition.z - 4 * t,
                ]
            }

            guard scale > 0 else {
                continue
            }

            let frameWidth = entry.frameWidth * scale
            let frameHeight = entry.frameHeight * scale
            let halfW = frameWidth / 2

            var vertices: [SpriteVertex] = [
                SpriteVertex(position: [-halfW, 0], textureCoordinate: [0, 1]),
                SpriteVertex(position: [ halfW, 0], textureCoordinate: [1, 1]),
                SpriteVertex(position: [-halfW, frameHeight], textureCoordinate: [0, 0]),
                SpriteVertex(position: [ halfW, 0], textureCoordinate: [1, 1]),
                SpriteVertex(position: [ halfW, frameHeight], textureCoordinate: [1, 0]),
                SpriteVertex(position: [-halfW, frameHeight], textureCoordinate: [0, 0]),
            ]
            guard let vertexBuffer = device.makeBuffer(
                bytes: &vertices,
                length: vertices.count * MemoryLayout<SpriteVertex>.stride,
                options: []
            ) else {
                continue
            }

            var uniforms = SpriteVertexUniforms(
                viewMatrix: matrices.viewMatrix,
                projectionMatrix: matrices.projectionMatrix,
                spriteWorldPosition: SIMD4<Float>(worldPosition, 0)
            )
            guard let uniformsBuffer = device.makeBuffer(
                bytes: &uniforms,
                length: MemoryLayout<SpriteVertexUniforms>.stride,
                options: []
            ) else {
                continue
            }

            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderCommandEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)
            renderCommandEncoder.setFragmentTexture(texture, index: 0)
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        }
    }

    private func color(for effect: MapDamageEffect, isPlayerTarget: Bool) -> CGColor {
        if effect.amount == 0 {
            return CGColor(red: 1, green: 1, blue: 0, alpha: 1)
        }

        if isPlayerTarget {
            return CGColor(red: 1, green: 0.25, blue: 0.25, alpha: 1)
        }

        return CGColor(red: 1, green: 1, blue: 1, alpha: 1)
    }

    private func makeImage(for string: String, color: CGColor) -> CGImage? {
        let fontSize: CGFloat = string == "MISS" ? 18 : 20
        let font = CTFontCreateWithName("Menlo-Bold" as CFString, fontSize, nil)
        let attributes: [NSAttributedString.Key : Any] = [
            kCTFontAttributeName as NSAttributedString.Key: font,
            kCTForegroundColorAttributeName as NSAttributedString.Key: color
        ]
        let attributedString = NSAttributedString(string: string, attributes: attributes)
        let line = CTLineCreateWithAttributedString(attributedString)
        let bounds = CTLineGetBoundsWithOptions(line, [.useGlyphPathBounds, .useOpticalBounds]).integral
        let padding: CGFloat = 6
        let width = max(Int(ceil(bounds.width + padding * 2)), 1)
        let height = max(Int(ceil(bounds.height + padding * 2)), 1)

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        context.clear(CGRect(x: 0, y: 0, width: width, height: height))
        context.textPosition = CGPoint(
            x: padding - bounds.minX,
            y: padding - bounds.minY
        )
        context.setTextDrawingMode(.fill)
        CTLineDraw(line, context)

        return context.makeImage()
    }
}
