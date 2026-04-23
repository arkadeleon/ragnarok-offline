//
//  DamageEffectSpriteSet.swift
//  RagnarokGame
//
//  Created by Li, Leon on 2026/4/23.
//

import CoreGraphics
import Foundation
import RagnarokCore
import RagnarokResources
import RagnarokSprite
import simd

struct DamageEffectSpriteSet: Sendable {
    private static let digitPadding = 2

    let digitImages: [CGImage?]
    let missImage: CGImage?
    let scale: SIMD2<Float>

    init(resourceManager: ResourceManager) async throws {
        let effectSpriteDirectory = ResourcePath.spriteDirectory.appending(K2L("이팩트"))
        let numberPath = effectSpriteDirectory.appending(K2L("숫자"))
        let messagePath = effectSpriteDirectory.appending("msg")

        async let numberSprite = resourceManager.sprite(at: numberPath)
        async let messageSprite = resourceManager.sprite(at: messagePath)

        let numberSpriteResource = try await numberSprite
        let messageSpriteResource = try await messageSprite

        let digitCount = min(Int(numberSpriteResource.spr.indexedSpriteCount) + Int(numberSpriteResource.spr.rgbaSpriteCount), 10)
        digitImages = (0..<digitCount).map {
            numberSpriteResource.spr.imageForSprite(at: $0)
        }
        missImage = messageSpriteResource.spr.imageForSprite(at: 0)

        if let layer = numberSpriteResource.act.action(at: 0)?.frames.first?.layers.first {
            scale = layer.scale
        } else {
            scale = [1, 1]
        }
    }

    func image(for amount: Int) -> CGImage? {
        if amount == 0 {
            return missImage
        }

        guard amount > 0 else {
            return nil
        }

        let digits = String(amount).compactMap(\.wholeNumberValue)
        guard !digits.isEmpty else {
            return nil
        }

        let frames = digits.compactMap { digit in
            digitImages.indices.contains(digit) ? digitImages[digit] : nil
        }
        guard frames.count == digits.count else {
            return nil
        }

        let width = frames.reduce(0) { $0 + $1.width + Self.digitPadding }
        let height = frames.reduce(0) { max($0, $1.height) }
        guard width > 0, height > 0 else {
            return nil
        }

        let renderer = CGImageRenderer(size: CGSize(width: width, height: height), flipped: false)
        return renderer.image { context in
            var x = 0
            for frame in frames {
                let y = (height - frame.height) / 2
                context.draw(frame, in: CGRect(x: x, y: y, width: frame.width, height: frame.height))
                x += frame.width + Self.digitPadding
            }
        }
    }
}
