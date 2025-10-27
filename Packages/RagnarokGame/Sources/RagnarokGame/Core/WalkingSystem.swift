//
//  WalkingSystem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/10/25.
//

import Foundation
import RealityKit
import RagnarokSprite

final class WalkingSystem: System {
    static let query = EntityQuery(where: .has(WalkingComponent.self))

    init(scene: Scene) {
    }

    func update(context: SceneUpdateContext) {
        let entities = context.entities(matching: Self.query, updatingSystemWhen: .rendering)

        for entity in entities {
            guard let entity = entity as? SpriteEntity else {
                continue
            }

            guard var walkingComponent = entity.components[WalkingComponent.self],
                  walkingComponent.path.count > 1 else {
                continue
            }

            guard let mapObject = entity.components[MapObjectComponent.self]?.mapObject,
                  let animations = entity.components[SpriteComponent.self]?.animations else {
                continue
            }

            let path = walkingComponent.path
            let sourceGridPosition = path[0]
            let targetGridPosition = path[1]

            let direction: CharacterDirection = switch (targetGridPosition &- sourceGridPosition) {
            case [0, -1]:
                .south
            case [-1, -1]:
                .southwest
            case [-1, 0]:
                .west
            case [-1, 1]:
                .northwest
            case [0, 1]:
                .north
            case [1, 1]:
                .northeast
            case [1, 0]:
                .east
            case [1, -1]:
                .southeast
            default:
                .south
            }

            let speed = TimeInterval(mapObject.speed) / 1000
            let duration = direction.isDiagonal ? speed * sqrt(2) : speed

            let animationIndex = CharacterActionType.walk.calculateActionIndex(forJobID: mapObject.job, direction: direction)
            let animation = animations[animationIndex]

            let mapGrid = walkingComponent.mapGrid
            let sourceAltitude = mapGrid[sourceGridPosition].averageAltitude
            let targetAltitude = mapGrid[targetGridPosition].averageAltitude

            let sourcePosition: SIMD3<Float> = [
                Float(sourceGridPosition.x) + 0.5 - animation.pivot.x / 32,
                Float(sourceGridPosition.y) + 0.5 - (animation.frameHeight / 2 - animation.pivot.y) / 32,
                sourceAltitude + animation.frameHeight / 2 / 32 * entity.scale.y,
            ]

            let targetPosition: SIMD3<Float> = [
                Float(targetGridPosition.x) + 0.5 - animation.pivot.x / 32,
                Float(targetGridPosition.y) + 0.5 - (animation.frameHeight / 2 - animation.pivot.y) / 32,
                targetAltitude + animation.frameHeight / 2 / 32 * entity.scale.y,
            ]

            if walkingComponent.stepTime == 0 {
                entity.generateModelAndCollisionShape(for: animation)
            }

            let totalTime = walkingComponent.totalTime + context.deltaTime
            let stepTime = walkingComponent.stepTime + context.deltaTime

            let frameIndex = Int(totalTime / animation.frameInterval) % animation.frameCount

            if let _ = animation.texture {
                entity.components[ModelComponent.self]?.materialTextureCoordinateTransform = MaterialParameterTypes.TextureCoordinateTransform(
                    offset: [Float(frameIndex) / Float(animation.frameCount), 0],
                    scale: [1 / Float(animation.frameCount), 1]
                )
            }

            let t = stepTime / duration
            if t > 1 {
                entity.position = targetPosition

                walkingComponent.stepTime = 0
                walkingComponent.path = Array(path.dropFirst())

                entity.components[GridPositionComponent.self]?.gridPosition = targetGridPosition
            } else {
                entity.position = mix(sourcePosition, targetPosition, t: Float(stepTime / duration))

                walkingComponent.stepTime = stepTime
            }

            walkingComponent.totalTime = totalTime

            if walkingComponent.path.count == 1 {
                entity.components[WalkingComponent.self] = nil
                entity.playSpriteAnimation(.idle, direction: direction, repeats: true)
            } else {
                entity.components[WalkingComponent.self] = walkingComponent
            }
        }
    }
}
