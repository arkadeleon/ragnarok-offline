//
//  SpriteAnimation.swift
//  GameCore
//
//  Created by Leon Li on 2025/2/25.
//

import CoreGraphics
import Foundation
import ImageRendering
import RealityKit
import ResourceManagement
import SpriteRendering

final class SpriteAnimation: Sendable {
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
        let animation = await spriteRenderer.render(sprite: sprite, actionIndex: actionIndex)

        try await self.init(animation: animation)
    }

    init(animation: SpriteRenderer.Animation) async throws {
        let frameCount = animation.frames.count

        let frameWidth = animation.frameWidth
        let frameHeight = animation.frameHeight

        let size = CGSize(width: frameWidth * CGFloat(frameCount), height: frameHeight)
        let renderer = CGImageRenderer(size: size, flipped: false)
        let image = renderer.image { cgContext in
            for frameIndex in 0..<frameCount {
                if let frame = animation.frames[frameIndex] {
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
        self.frameInterval = animation.frameInterval
    }
}

extension SpriteAnimation {
    static func animations(for composedSprite: ComposedSprite) async throws -> [SpriteAnimation] {
        var animations: [SpriteAnimation] = []

        let spriteRenderer = SpriteRenderer()

        let availableActionTypes = CharacterActionType.availableActionTypes(forJobID: composedSprite.configuration.job.rawValue)

        for actionType in availableActionTypes {
            for direction in CharacterDirection.allCases {
                let anim = await spriteRenderer.render(
                    composedSprite: composedSprite,
                    actionType: actionType,
                    direction: direction,
                    headDirection: .straight
                )
                let animation = try await SpriteAnimation(animation: anim)
                animations.append(animation)
            }
        }

        return animations
    }
}
