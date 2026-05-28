//
//  MapSceneObjectPresentationSystem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import RagnarokModels
import RagnarokSprite
import RealityKit
import simd

class MapSceneObjectPresentationSystem: System {
    static let query = EntityQuery(where: .has(MapSceneObjectComponent.self))

    required init(scene: Scene) {
    }

    func update(context: SceneUpdateContext) {
        let now = ContinuousClock.now

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var component = entity.components[MapSceneObjectComponent.self],
                  let spriteEntity = entity.findEntity(named: "sprite") else {
                continue
            }

            component.animation.update(atTime: now)
            if var movement = component.movement {
                movement.update(atTime: now)
                component.movement = movement
            }
            entity.components.set(component)

            let movement = component.movement
            var animation = component.animation
            if let movement, movement.isMoving {
                animation.action = .walk
                animation.direction = movement.direction ?? animation.direction
                animation.elapsedTime = movement.animationElapsedTime
                animation.completion = .indefinite
            }
            entity.position = if let movement, movement.isMoving, let movementWorldPosition = movement.worldPosition {
                movementWorldPosition
            } else {
                component.logicalWorldPosition
            }

            let actionComponent = SpriteActionComponent(
                actionType: animation.action,
                direction: animation.direction,
                headDirection: animation.headDirection
            )
            if spriteEntity.components[SpriteActionComponent.self] != actionComponent {
                spriteEntity.components.set(actionComponent)
            }

            spriteEntity.components.set(
                SpriteAnimationTimingComponent(animation: animation)
            )
        }
    }
}
