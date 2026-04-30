//
//  DamageDigitSystem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/11/13.
//

import RagnarokCore
import RealityKit
import WorldCamera

class DamageDigitSystem: System {
    static let query = EntityQuery(where: .has(DamageDigitComponent.self))
    static let targetQuery = EntityQuery(where: .has(MapObjectComponent.self))

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
            guard var component = entity.components[DamageDigitComponent.self] else {
                continue
            }

            component.elapsedTime += context.deltaTime
            entity.components.set(component)

            let expiredTime = component.delay + component.duration + 1
            if component.elapsedTime > expiredTime {
                entity.removeFromParent()
                continue
            }

            if component.elapsedTime < component.delay {
                continue
            }

            if component.startPosition == nil {
                let targetEntity: Entity?
                if let targetEntityID = component.targetEntityID {
                    targetEntity = context.scene.findEntity(id: targetEntityID)
                } else {
                    targetEntity = context.entities(matching: Self.targetQuery, updatingSystemWhen: .rendering).first { entity in
                        entity.components[MapObjectComponent.self]?.mapObject.objectID == component.targetObjectID
                    }
                }

                guard let targetEntity else {
                    continue
                }

                component.targetEntityID = targetEntity.id
                component.startPosition = targetEntity.position(relativeTo: nil)
                if case .damage = component.digit {
                    component.color = targetEntity.components[MapObjectComponent.self]?.mapObject.type == .pc ? .red : .white
                }
                entity.components.set(component)
            }

            guard let startPosition = component.startPosition else {
                continue
            }

            if !entity.components.has(ModelComponent.self) {
                let string = switch component.digit {
                case .miss: "MISS"
                case .damage(let damage): "\(damage)"
                }
                let mesh = MeshResource.generateText(
                    string,
                    extrusionDepth: 0.01,
                    font: .monospacedSystemFont(ofSize: 0.25, weight: .bold)
                )
                let material = SimpleMaterial(color: component.color, isMetallic: false)
                entity.components.set(ModelComponent(mesh: mesh, materials: [material]))
            }

            let t = Float((component.elapsedTime - component.delay) / component.duration)

            if t >= 1 {
                entity.removeFromParent()
                continue
            }

            switch component.digit {
            case .miss:
                var position = startPosition
                position.y += 3.5 + 7 * t
                entity.position = position

                let scale: Float = 2.5
                entity.scale = [scale, scale / cosf(elevation), scale]
            case .damage:
                var position = startPosition
                position.x += 4 * t
                position.y += 2 + sin(-.pi / 2 + (.pi * (0.5 + 1.5 * t))) * 5
                position.z -= 4 * t
                entity.position = position

                let scale = 4 * (1 - t)
                entity.scale = [scale, scale / cosf(elevation), scale]
            }

            entity.orientation = simd_quatf(angle: -azimuth, axis: [0, 1, 0])

            let opacity = 1 - t
            entity.components.set(OpacityComponent(opacity: opacity))
        }
    }
}
