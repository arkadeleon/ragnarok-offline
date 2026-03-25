//
//  SpriteAnimation.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/2/25.
//

import CoreGraphics
import Foundation
import ImageRendering
import RagnarokResources
import RagnarokSprite
import RealityKit

struct SpriteAnimation: Equatable, Sendable {
    let texture: TextureResource?
    let frameCount: Int
    let frameWidth: Float
    let frameHeight: Float
    let frameInterval: TimeInterval
    let pivot: SIMD2<Float>

    var duration: TimeInterval {
        frameInterval * TimeInterval(frameCount)
    }

    init(sprite: SpriteResource, actionIndex: Int) async throws {
        let spriteRenderer = SpriteRenderer()
        let animation = await spriteRenderer.render(sprite: sprite, actionIndex: actionIndex)

        try await self.init(animation: animation)
    }

    init(animation: SpriteRenderer.Animation) async throws {
        let frameCount = animation.frames.count

        let width = animation.frameWidth * animation.scale
        let height = animation.frameHeight * animation.scale
        let size = CGSize(width: width * CGFloat(frameCount), height: height)
        let renderer = CGImageRenderer(size: size, flipped: false)
        let image = renderer.image { cgContext in
            for frameIndex in 0..<frameCount {
                if let frame = animation.frames[frameIndex] {
                    let rect = CGRect(x: width * CGFloat(frameIndex), y: 0, width: width, height: height)
                    cgContext.draw(frame, in: rect)
                }
            }
        }

        if let image {
            let options = TextureResource.CreateOptions(semantic: .color)
            texture = try await TextureResource(image: image, options: options)
        } else {
            texture = nil
        }

        self.frameCount = frameCount
        self.frameWidth = Float(animation.frameWidth)
        self.frameHeight = Float(animation.frameHeight)
        self.frameInterval = animation.frameInterval
        self.pivot = [
            Float(animation.pivot.x),
            Float(animation.pivot.y),
        ]
    }
}

extension SpriteAnimation {
    static func animationName(
        for actionType: CharacterActionType,
        direction: CharacterDirection,
        headDirection: CharacterHeadDirection
    ) -> String {
        "\(actionType).\(direction).\(headDirection)"
    }

    static func animations(for composedSprite: ComposedSprite) async -> [String : SpriteAnimation] {
        await withTaskGroup(
            of: (String, SpriteAnimation?).self,
            returning: [String : SpriteAnimation].self
        ) { taskGroup in
            let spriteRenderer = SpriteRenderer()

            let availableActionTypes = CharacterActionType.availableActionTypes(forJobID: composedSprite.configuration.job.rawValue)

            for actionType in availableActionTypes {
                for direction in CharacterDirection.allCases {
                    let headDirection: CharacterHeadDirection = .lookForward

                    taskGroup.addTask {
                        let animationName = animationName(
                            for: actionType,
                            direction: direction,
                            headDirection: headDirection
                        )

                        let anim = await spriteRenderer.render(
                            composedSprite: composedSprite,
                            actionType: actionType,
                            direction: direction,
                            headDirection: headDirection
                        )

                        do {
                            let animation = try await SpriteAnimation(animation: anim)
                            return (animationName, animation)
                        } catch {
                            logger.warning("Failed to render sprite: \(error)")
                            return (animationName, nil)
                        }
                    }
                }
            }

            var animations: [String : SpriteAnimation] = [:]

            for await (animationName, animation) in taskGroup {
                if let animation {
                    animations[animationName] = animation
                }
            }

            return animations
        }
    }
}

extension AnimationResource {
    @available(*, deprecated)
    static func generate(with animation: SpriteAnimation, repeats: Bool, trimDuration: TimeInterval? = nil) throws -> AnimationResource {
        var frames: [SIMD2<Float>] = (0..<animation.frameCount).map { frameIndex in
            [Float(frameIndex) / Float(animation.frameCount), 0]
        }
        if repeats {
            frames = Array(repeating: frames, count: 100).flatMap({ $0 })
        }
        let animationDefinition = SampledAnimation(
            frames: frames,
            name: "action",
            tweenMode: .hold,
            frameInterval: Float(animation.frameInterval),
            isAdditive: false,
            bindTarget: .material(0).textureCoordinate.offset,
            repeatMode: repeats ? .repeat : .none,
            trimDuration: trimDuration
        )
        let animationResource = try AnimationResource.generate(with: animationDefinition)
        return animationResource
    }
}
