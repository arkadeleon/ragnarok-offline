//
//  SpriteSystem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/11/6.
//

import RealityKit
import SGLMath
import WorldCamera

class SpriteSystem: System {
    static let query = EntityQuery(where: .has(SpriteAnimationsComponent.self))

    required init(scene: Scene) {
    }

    func update(context: SceneUpdateContext) {
        let worldCameraEntities = context.entities(
            matching: EntityQuery(where: .has(WorldCameraComponent.self)),
            updatingSystemWhen: .rendering
        )
        guard let worldCameraEntity = worldCameraEntities.first(where: { _ in true }),
              let elevation = worldCameraEntity.components[WorldCameraComponent.self]?.elevation else {
            return
        }

        let entities = context.entities(matching: Self.query, updatingSystemWhen: .rendering)

        for entity in entities {
            entity.scale = [1, 1 / cosf(radians(90) + elevation), 1]

            guard let animations = entity.components[SpriteAnimationsComponent.self]?.animations else {
                continue
            }

            var animation: SpriteAnimation?
            if let animationName = entity.components[SpriteActionComponent.self]?.combinedName {
                animation = animations[animationName]
            } else {
                animation = entity.components[SpriteAnimationsComponent.self]?.defaultAnimation
            }

            if let animation {
                entity.position = [
                    -animation.pivot.x / 32,
                    -(animation.frameHeight / 2 - animation.pivot.y) / 32,
                    animation.frameHeight / 2 / 32 * entity.scale.y,
                ]
            }
        }
    }
}
