//
//  SpriteAnimationSystem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/1/28.
//

import RealityKit

class SpriteAnimationSystem: System {
    static let query = EntityQuery(where: .has(SpriteAnimationComponent.self))

    static var dependencies: [SystemDependency] {
        [.after(SpriteActionSystem.self)]
    }

    required init(scene: Scene) {
    }

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var animationComponent = entity.components[SpriteAnimationComponent.self] else {
                continue
            }

            let animation = animationComponent.animation
            let frameIndex = Int(animationComponent.elapsedTime / animation.frameInterval) % animation.frameCount

            if animationComponent.currentFrameIndex != frameIndex && animation.texture != nil {
                animationComponent.currentFrameIndex = frameIndex

                entity.components[ModelComponent.self]?.materialTextureCoordinateTransform = UnlitMaterial.TextureCoordinateTransform(
                    offset: [Float(frameIndex) / Float(animation.frameCount), 0],
                    scale: [1 / Float(animation.frameCount), 1]
                )
            }

            animationComponent.elapsedTime += context.deltaTime

            entity.components.set(animationComponent)
        }
    }
}

extension ModelComponent {
    var materialTextureCoordinateTransform: UnlitMaterial.TextureCoordinateTransform? {
        get {
            let material = materials[0] as? UnlitMaterial
            return material?.textureCoordinateTransform
        }
        set {
            if let newValue, var material = materials[0] as? UnlitMaterial {
                material.textureCoordinateTransform = newValue
                materials[0] = material
            }
        }
    }
}
