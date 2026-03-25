//
//  SpriteBillboardSystem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/11/6.
//

import RealityKit
import SGLMath
import WorldCamera

class SpriteBillboardSystem: System {
    static let query = EntityQuery(where: .has(SpriteBillboardComponent.self))

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
        let elevation = worldCameraComponent.elevation

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            entity.scale = [1, 1 / cosf(elevation), 1]

            entity.orientation = simd_quatf(angle: -azimuth, axis: [0, 1, 0])

            if let animation = entity.components[SpriteAnimationComponent.self]?.animation {
                entity.updatePosition(for: animation)
            }
        }
    }
}
