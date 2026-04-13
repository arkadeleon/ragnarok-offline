//
//  MapObjectSnapshotPresentationSystem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import RagnarokModels
import RagnarokSprite
import RealityKit
import simd

class MapObjectSnapshotPresentationSystem: System {
    static let query = EntityQuery(where: .has(MapObjectSnapshotPresentationComponent.self) && .has(MapObjectComponent.self))

    private let sampler = MapObjectPresentationSampler()

    required init(scene: Scene) {
    }

    func update(context: SceneUpdateContext) {
        let now = ContinuousClock.now

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let mapObject = entity.components[MapObjectComponent.self]?.mapObject,
                  let component = entity.components[MapObjectSnapshotPresentationComponent.self],
                  let spriteEntity = entity.findEntity(named: "sprite") else {
                continue
            }

            let sample = sampler.sample(
                logicalWorldPosition: component.logicalWorldPosition,
                timeline: component.timeline,
                presentation: component.presentation,
                mapObject: mapObject,
                now: now
            )
            entity.position = sample.worldPosition

            let actionComponent = SpriteActionComponent(
                actionType: sample.action,
                direction: sample.direction,
                headDirection: .lookForward
            )
            if spriteEntity.components[SpriteActionComponent.self] != actionComponent {
                spriteEntity.components.set(actionComponent)
            }

            spriteEntity.components.set(
                SpriteAnimationTimingComponent(elapsedTime: sample.animationElapsed.timeInterval)
            )
        }
    }
}
