//
//  SpriteActionSystem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/1/28.
//

import RagnarokSprite
import RealityKit
import WorldCamera

class SpriteActionSystem: System {
    static let query = EntityQuery(where: .has(SpriteAnimationLibraryComponent.self) && .has(SpriteActionComponent.self))

    static var dependencies: [SystemDependency] {
        [.after(MapObjectSnapshotPresentationSystem.self)]
    }

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

            let desiredAnimation = entity.components[SpriteAnimationTimingComponent.self]?.animation

            if let nextActionType = actionComponent.nextActionType,
               let animationComponent = entity.components[SpriteAnimationComponent.self],
               animationComponent.elapsedTime >= animationComponent.animation.duration {
                actionComponent.actionType = nextActionType
                actionComponent.nextActionType = nil
                entity.components.set(actionComponent)
                entity.components.remove(SpriteAnimationComponent.self)
            }

            let visualDirection = actionComponent.direction.adjustedForCameraAzimuth(azimuth)
            func spriteAnimation(for actionType: SpriteActionType) -> SpriteAnimation? {
                let animationName = SpriteAnimation.animationName(
                    for: actionType,
                    direction: visualDirection,
                    headDirection: actionComponent.headDirection
                )
                return animations[animationName]
            }

            guard var animation = spriteAnimation(for: actionComponent.actionType) else {
                continue
            }

            var desiredElapsedTime = desiredAnimation?.elapsed.timeInterval
            if let desiredAnimation,
               case .once(let settledActionType) = desiredAnimation.completion,
               let settledAnimation = spriteAnimation(for: settledActionType),
               actionComponent.actionType != settledActionType,
               desiredAnimation.elapsed.timeInterval >= animation.duration {
                desiredElapsedTime = desiredAnimation.elapsed.timeInterval - animation.duration
                animation = settledAnimation
            }

            if entity.components[SpriteAnimationComponent.self]?.animation != animation {
                entity.setSpriteAnimation(animation, elapsedTime: desiredElapsedTime ?? 0)
                entity.generateModelAndCollisionShape(for: animation)
            } else if let desiredElapsedTime,
                      var animationComponent = entity.components[SpriteAnimationComponent.self] {
                animationComponent.elapsedTime = desiredElapsedTime
                entity.components.set(animationComponent)
            }
        }
    }
}
