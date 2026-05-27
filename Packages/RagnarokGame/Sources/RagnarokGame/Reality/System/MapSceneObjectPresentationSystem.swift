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

    private let sampler = MapObjectPresentationSampler()

    required init(scene: Scene) {
    }

    func update(context: SceneUpdateContext) {
        let now = ContinuousClock.now

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let component = entity.components[MapSceneObjectComponent.self],
                  let spriteEntity = entity.findEntity(named: "sprite") else {
                continue
            }

            let movementSample = sampler.sample(
                timeline: component.movementTimeline,
                headDirection: component.presentation.headDirection,
                now: now
            )
            let animation = movementSample?.animation ?? component.presentation.animation(at: now)
            entity.position = movementSample?.worldPosition ?? component.logicalWorldPosition

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
