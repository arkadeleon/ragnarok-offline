//
//  DamageDigitSystem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/11/13.
//

import RealityKit

class DamageDigitSystem: System {
    static let query = EntityQuery(where: .has(DamageDigitComponent.self))

    required init(scene: Scene) {
    }

    func update(context: SceneUpdateContext) {
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
                let mesh = MeshResource.generateText("\(component.digits)", font: .systemFont(ofSize: 0.5))
                let material = SimpleMaterial(color: .white, isMetallic: false)
                entity.components.set(ModelComponent(mesh: mesh, materials: [material]))
            }

            let t = Float((component.elapsedTime - component.delay) / component.duration)

            if t >= 1 {
                entity.removeFromParent()
                continue
            }

            var position = component.startPosition
            position.x += 4 * t
            position.y -= 4 * t
            position.z += sin(-.pi / 2 + (.pi * (0.5 + 1.5 * t))) * 5
            entity.position = position

            let scale = 4 * (1 - t)
            entity.scale = [scale, scale, scale]

            let opacity = 1 - t
            entity.components.set(OpacityComponent(opacity: opacity))
        }
    }
}
