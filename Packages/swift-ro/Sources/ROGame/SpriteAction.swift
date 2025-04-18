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

    public init(sprites: [SpriteResource], actionIndex: Int) async throws {
        let spriteRenderer = SpriteRenderer(sprites: sprites)
        let animatedImage = await spriteRenderer.renderAction(at: actionIndex, headDirection: .straight)

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
    public static func actions(forJobID jobID: UniformJobID, configuration: SpriteConfiguration) async throws -> [SpriteAction] {
        let spriteResolver = SpriteResolver(resourceManager: .default)

        let sprites = await spriteResolver.resolve(jobID: jobID, configuration: configuration)

        var actions: [SpriteAction] = []

        if jobID.isPlayer {
            for actionType in PlayerActionType.allCases {
                for direction in BodyDirection.allCases {
                    let actionIndex = actionType.rawValue * 8 + direction.rawValue
                    let action = try await SpriteAction(sprites: sprites, actionIndex: actionIndex)
                    actions.append(action)
                }
            }
        } else if jobID.isMonster {
            // It seems that die action type is a little bit different.
            let actionTypes: [MonsterActionType] = [.idle, .walk, .attack, .hurt]
            for actionType in actionTypes {
                for direction in BodyDirection.allCases {
                    let actionIndex = actionType.rawValue * 8 + direction.rawValue
                    let action = try await SpriteAction(sprites: sprites, actionIndex: actionIndex)
                    actions.append(action)
                }
            }
        } else {
            for direction in BodyDirection.allCases {
                let actionIndex = direction.rawValue
                let action = try await SpriteAction(sprites: sprites, actionIndex: actionIndex)
                actions.append(action)
            }
        }

        return actions
    }

    public static func actions(forItemID itemID: Int) async throws -> [SpriteAction] {
        guard let path = await ResourcePath(itemSpritePathWithItemID: itemID) else {
            return []
        }

        let sprite = try await ResourceManager.default.sprite(at: path)
        let action = try await SpriteAction(sprites: [sprite], actionIndex: 0)
        return [action]
    }
}
