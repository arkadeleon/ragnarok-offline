//
//  WalkingSystem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/10/25.
//

import Foundation
import RagnarokSprite
import RealityKit

class WalkingSystem: System {
    static let query = EntityQuery(where: .has(WalkingComponent.self))

    required init(scene: Scene) {
    }

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let spriteEntity = entity.findEntity(named: "sprite") else {
                continue
            }

            guard var walkingComponent = entity.components[WalkingComponent.self],
                  walkingComponent.path.count > 1 else {
                continue
            }

            guard let mapObject = entity.components[MapObjectComponent.self]?.mapObject else {
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

            let mapGrid = walkingComponent.mapGrid
            let sourceAltitude = mapGrid[sourceGridPosition].averageAltitude
            let targetAltitude = mapGrid[targetGridPosition].averageAltitude

            let sourcePosition: SIMD3<Float> = [
                Float(sourceGridPosition.x) + 0.5,
                sourceAltitude,
                -Float(sourceGridPosition.y) - 0.5,
            ]

            let targetPosition: SIMD3<Float> = [
                Float(targetGridPosition.x) + 0.5,
                targetAltitude,
                -Float(targetGridPosition.y) - 0.5,
            ]

            if walkingComponent.stepTime == 0 {
                spriteEntity.components.set(
                    SpriteActionComponent(actionType: .walk, direction: direction, headDirection: .lookForward)
                )
            }

            let stepTime = walkingComponent.stepTime + context.deltaTime

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

            if walkingComponent.path.count == 1 {
                entity.components.remove(WalkingComponent.self)
                entity.playSpriteAnimation(.idle, direction: direction)
            } else {
                entity.components.set(walkingComponent)
            }
        }
    }
}
