//
//  DamageDigitSystem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/11/13.
//

import RealityKit
import SGLMath
import WorldCamera

class DamageDigitSystem: System {
    static let query = EntityQuery(where: .has(DamageDigitComponent.self))

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

            if component.elapsedTime < component.delay {
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
                var position = component.startPosition
                position.z += 3.5 + 7 * t
                entity.position = position

                let scale: Float = 2.5
                entity.scale = [scale, scale, scale]
            case .damage:
                var position = component.startPosition
                position.x += 4 * t
                position.y -= 4 * t
                position.z += 2 + sin(-.pi / 2 + (.pi * (0.5 + 1.5 * t))) * 5
                entity.position = position

                let scale = 4 * (1 - t)
                entity.scale = [scale, scale, scale]
            }

            entity.orientation = simd_quatf(angle: -azimuth, axis: [0, 0, 1]) * simd_quatf(angle: elevation, axis: [1, 0, 0])

            let opacity = 1 - t
            entity.components.set(OpacityComponent(opacity: opacity))
        }
    }
}
