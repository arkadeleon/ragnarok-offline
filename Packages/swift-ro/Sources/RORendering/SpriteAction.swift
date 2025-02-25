//
//  SpriteAction.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/25.
//

import CoreGraphics
import RealityKit
import ROCore

enum SpriteActionError: Error {
    case cannotRenderAction
}

final public class SpriteAction: Sendable {
    public let texture: TextureResource?
    public let frameWidth: Float
    public let frameHeight: Float
    public let frameCount: Int
    public let frameInterval: Float

    public init(sprites: [SpriteResource], actionType: PlayerActionType, direction: BodyDirection) async throws {
        let spriteRenderer = SpriteRenderer()
        let images = spriteRenderer.drawPlayerSprites(sprites: sprites, actionType: actionType, direction: direction, headDirection: .straight)

        guard !images.isEmpty else {
            throw SpriteActionError.cannotRenderAction
        }

        let frameWidth = images[0].width
        let frameHeight = images[0].height
        let frameCount = images.count

        let size = CGSize(width: frameWidth * frameCount, height: frameHeight)
        let renderer = CGImageRenderer(size: size, flipped: false)
        let image = renderer.image { context in
            for frameIndex in 0..<frameCount {
                let rect = CGRect(x: frameWidth * frameIndex, y: 0, width: frameWidth, height: frameHeight)
                context.draw(images[frameIndex], in: rect)
            }
        }

        if let image {
            texture = try await TextureResource(image: image, options: TextureResource.CreateOptions(semantic: .color))
        } else {
            texture = nil
        }

        self.frameWidth = Float(frameWidth)
        self.frameHeight = Float(frameHeight)
        self.frameCount = frameCount
        frameInterval = 1 / 12
    }
}

extension SpriteAction {
    public static func actions(for jobID: UniformJobID, configuration: SpriteConfiguration) async throws -> [SpriteAction] {
        let spriteResolver = SpriteResolver()
        let sprites = await spriteResolver.resolvePlayerSprites(jobID: jobID, configuration: configuration)

        var actions: [SpriteAction] = []

        for actionType in PlayerActionType.allCases {
            for direction in BodyDirection.allCases {
                let action = try await SpriteAction(sprites: sprites, actionType: actionType, direction: direction)
                actions.append(action)
            }
        }

        return actions
    }
}
