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

enum SpriteActionError: Error {
    case cannotRenderAction
}

final public class SpriteAction: Sendable {
    public let texture: TextureResource?
    public let frameWidth: Int
    public let frameHeight: Int
    public let frameCount: Int
    public let frameInterval: Float

    public init(sprites: [SpriteResource], actionIndex: Int) async throws {
        let spriteRenderer = SpriteRenderer(sprites: sprites)
        let images = await spriteRenderer.renderAction(at: actionIndex, headDirection: .straight)

        guard !images.isEmpty else {
            throw SpriteActionError.cannotRenderAction
        }

        let scale = Int(spriteRenderer.scale)
        let frameWidth = images[0].width / scale
        let frameHeight = images[0].height / scale
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
            let options = TextureResource.CreateOptions(semantic: .color, mipmapsMode: .none)
            texture = try await TextureResource(image: image, options: options)
        } else {
            texture = nil
        }

        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
        self.frameCount = frameCount
        frameInterval = 1 / 12
    }
}

extension SpriteAction {
    public static func actions(for jobID: UniformJobID, configuration: SpriteConfiguration) async throws -> [SpriteAction] {
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
}
