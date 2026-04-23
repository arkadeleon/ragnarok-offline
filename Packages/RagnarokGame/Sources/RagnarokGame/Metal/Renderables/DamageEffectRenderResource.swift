//
//  DamageEffectRenderResource.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/22.
//

import CoreGraphics
import CoreText
import Foundation
import Metal
import RagnarokMetalRendering
import simd

@MainActor
final class DamageEffectRenderResource {
    struct ResolvedTarget {
        var startPosition: SIMD3<Float>
        var isPlayerTarget: Bool
    }

    enum EffectKind {
        case miss
        case damage
    }

    let id: UUID
    let creationTime: ContinuousClock.Instant
    let kind: EffectKind
    let delay: Duration
    let duration: Duration
    let startPosition: SIMD3<Float>
    let texture: (any MTLTexture)?
    let frameWidth: Float
    let frameHeight: Float

    init(device: any MTLDevice, effect: MapDamageEffect, resolvedTarget: ResolvedTarget) {
        let string = effect.amount == 0 ? "MISS" : "\(effect.amount)"
        let color = Self.color(for: effect, isPlayerTarget: resolvedTarget.isPlayerTarget)
        let image = Self.makeImage(for: string, color: color)
        let texture = MetalTextureFactory.makeTexture(
            from: image,
            device: device,
            label: "damage-effect-\(effect.id.uuidString)"
        )

        let size = image.map {
            SIMD2<Float>(Float($0.width), Float($0.height))
        } ?? SIMD2<Float>(64, 24)

        self.id = effect.id
        self.creationTime = effect.creationTime
        self.kind = effect.amount == 0 ? .miss : .damage
        self.delay = effect.delay
        self.duration = effect.amount == 0 ? .milliseconds(800) : .milliseconds(1500)
        self.startPosition = resolvedTarget.startPosition
        self.texture = texture
        self.frameWidth = size.x
        self.frameHeight = size.y
    }

    private static func color(for effect: MapDamageEffect, isPlayerTarget: Bool) -> CGColor {
        if effect.amount == 0 {
            return CGColor(red: 1, green: 1, blue: 0, alpha: 1)
        }

        if isPlayerTarget {
            return CGColor(red: 1, green: 0.25, blue: 0.25, alpha: 1)
        }

        return CGColor(red: 1, green: 1, blue: 1, alpha: 1)
    }

    private static func makeImage(for string: String, color: CGColor) -> CGImage? {
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
