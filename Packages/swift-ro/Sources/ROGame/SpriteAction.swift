//
//  SpriteAction.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/25.
//

import CoreGraphics
import RealityKit
import ROCore
import RORendering
import ROResources

final public class SpriteAction: Sendable {
    public let texture: TextureResource?
    public let frameCount: Int
    public let frameWidth: Float
    public let frameHeight: Float
    public let frameInterval: Float

    public convenience init(sprite: SpriteResource, actionIndex: Int) async throws {
        let spriteRenderer = SpriteRenderer()
        let animatedImage = await spriteRenderer.render(sprite: sprite, actionIndex: actionIndex)

        try await self.init(animatedImage: animatedImage)
    }

    public convenience init(resolvedSprite: ResolvedSprite, actionIndex: Int) async throws {
        let spriteRenderer = SpriteRenderer()
        let animatedImage = await spriteRenderer.render(resolvedSprite: resolvedSprite, actionIndex: actionIndex, headDirection: .straight)

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
        self.frameInterval = Float(animatedImage.frameInterval)
    }
}

extension SpriteAction {
    public static func actions(forItemID itemID: Int, resourceManager: ResourceManager) async throws -> [SpriteAction] {
        guard let path = await ResourcePath(itemSpritePathWithItemID: itemID) else {
            return []
        }

        let sprite = try await resourceManager.sprite(at: path)
        let action = try await SpriteAction(sprite: sprite, actionIndex: 0)
        return [action]
    }

    public static func actions(forConfiguration configuration: SpriteConfiguration, resourceManager: ResourceManager) async throws -> [SpriteAction] {
        let spriteResolver = SpriteResolver(resourceManager: resourceManager)
        let resolvedSprite = await spriteResolver.resolveSprite(with: configuration)

        var actions: [SpriteAction] = []

        let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: configuration.job.rawValue)
        let actionCount = availableActionTypes.count * BodyDirection.allCases.count
        for actionIndex in 0..<actionCount {
            let action = try await SpriteAction(resolvedSprite: resolvedSprite, actionIndex: actionIndex)
            actions.append(action)
        }

        return actions
    }
}
