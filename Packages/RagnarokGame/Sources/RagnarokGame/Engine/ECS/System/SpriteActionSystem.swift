//
//  SpriteActionSystem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/1/28.
//

import RealityKit
import WorldCamera

class SpriteActionSystem: System {
    static let query = EntityQuery(where: .has(SpriteAnimationLibraryComponent.self) && .has(SpriteActionComponent.self))

    required init(scene: Scene) {
    }

    func update(context: SceneUpdateContext) {
        let worldCameraEntities = context.entities(
            matching: EntityQuery(where: .has(WorldCameraComponent.self)),
            updatingSystemWhen: .rendering
        )
        guard let worldCameraEntity = worldCameraEntities.first(where: { _ in true }),
              let worldCameraComponent = worldCameraEntity.components[WorldCameraComponent.self] else {
            return
        }

        let azimuth = worldCameraComponent.azimuth

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let animations = entity.components[SpriteAnimationLibraryComponent.self]?.animations,
                  var actionComponent = entity.components[SpriteActionComponent.self] else {
                continue
            }

            if let nextActionComponent = entity.components[SpriteNextActionComponent.self],
               let animationComponent = entity.components[SpriteAnimationComponent.self],
               animationComponent.elapsedTime >= animationComponent.animation.duration {
                actionComponent.actionType = nextActionComponent.actionType
                actionComponent.direction = nextActionComponent.direction
                actionComponent.headDirection = nextActionComponent.headDirection
                entity.components.set(actionComponent)
                entity.components.remove(SpriteNextActionComponent.self)
                entity.components.remove(SpriteAnimationComponent.self)
            }

            let visualDirection = actionComponent.direction.adjustedForCameraAzimuth(azimuth)
            let animationName = SpriteAnimation.animationName(
                for: actionComponent.actionType,
                direction: visualDirection,
                headDirection: actionComponent.headDirection
            )
            guard let animation = animations[animationName] else {
                continue
            }

            if entity.components[SpriteAnimationComponent.self]?.animation != animation {
                entity.setSpriteAnimation(animation)
                entity.generateModelAndCollisionShape(for: animation)
            }
        }
    }
}
