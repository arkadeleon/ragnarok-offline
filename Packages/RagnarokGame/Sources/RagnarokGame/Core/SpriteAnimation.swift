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

final class SpriteAnimation: Sendable {
    let texture: TextureResource?
    let frameCount: Int
    let frameWidth: Float
    let frameHeight: Float
    let frameInterval: TimeInterval
    let pivot: SIMD2<Float>

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

extension Entity {
    func generateModelAndCollisionShape(for animation: SpriteAnimation) {
        let width = animation.frameWidth / 32
        let height = animation.frameHeight / 32

        // Create material.
        var material = PhysicallyBasedMaterial()
        material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.7)
        material.opacityThreshold = 0.0001
        material.blending = .transparent(opacity: 1.0)

        if let texture = animation.texture {
            material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
            material.textureCoordinateTransform = MaterialParameterTypes.TextureCoordinateTransform(scale: [1 / Float(animation.frameCount), 1])
        }

        // Create model component.
        let modelComponent = ModelComponent(
            mesh: .generatePlane(width: width, height: height),
            materials: [material]
        )
        components.set(modelComponent)

        // Create collision component.
        let collisionComponent = CollisionComponent(
            shapes: [.generateBox(width: width, height: height, depth: 0)]
        )
        components.set(collisionComponent)
    }
}
