//
//  SpriteAnimation.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/25.
//

import CoreGraphics
import Foundation
import RealityKit
import ROCore
import RORendering
import ROResources

final class SpriteAnimation {
    let texture: TextureResource?
    let frameCount: Int
    let frameWidth: Float
    let frameHeight: Float
    let frameInterval: TimeInterval

    var duration: TimeInterval {
        frameInterval * TimeInterval(frameCount)
    }

    convenience init(sprite: SpriteResource, actionIndex: Int) async throws {
        let spriteRenderer = SpriteRenderer()
        let animatedImage = await spriteRenderer.render(sprite: sprite, actionIndex: actionIndex)

        try await self.init(animatedImage: animatedImage)
    }

    init(animatedImage: AnimatedImage) async throws {
        let frameCount = animatedImage.frames.count

        let frameWidth = animatedImage.frameWidth
        let frameHeight = animatedImage.frameHeight

        let size = CGSize(width: frameWidth * CGFloat(frameCount), height: frameHeight)
        let renderer = CGImageRenderer(size: size, flipped: false)
        let image = renderer.image { cgContext in
            for frameIndex in 0..<frameCount {
                if let frame = animatedImage.frames[frameIndex] {
                    let rect = CGRect(x: frameWidth * CGFloat(frameIndex), y: 0, width: frameWidth, height: frameHeight)
                    cgContext.draw(frame, in: rect)
                }
            }
        }

        if let image {
            let options = TextureResource.CreateOptions(semantic: .color, mipmapsMode: .none)
            texture = try await TextureResource(image: image, options: options)
        } else {
            texture = nil
        }

        self.frameCount = frameCount
        self.frameWidth = Float(frameWidth)
        self.frameHeight = Float(frameHeight)
        self.frameInterval = animatedImage.frameInterval
    }
}

extension SpriteAnimation {
    static func animations(for composedSprite: ComposedSprite) async throws -> [SpriteAnimation] {
        var animations: [SpriteAnimation] = []

        let spriteRenderer = SpriteRenderer()

        let availableActionTypes = ComposedSprite.ActionType.availableActionTypes(forJobID: composedSprite.configuration.job.rawValue)

        for actionType in availableActionTypes {
            for direction in ComposedSprite.Direction.allCases {
                let animatedImage = await spriteRenderer.render(
                    composedSprite: composedSprite,
                    actionType: actionType,
                    direction: direction,
                    headDirection: .straight
                )
                let animation = try await SpriteAnimation(animatedImage: animatedImage)
                animations.append(animation)
            }
        }

        return animations
    }
}
