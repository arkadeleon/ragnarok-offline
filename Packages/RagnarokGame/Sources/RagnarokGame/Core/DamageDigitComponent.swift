//
//  DamageDigitComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/11/13.
//

import Foundation
import RagnarokNetwork
import RealityKit

struct DamageDigitComponent: Component {
    enum Digit {
        case miss
        case damage(Int)
    }

    var digit: DamageDigitComponent.Digit
    var color: Material.Color = .white

    var duration: TimeInterval
    var delay: TimeInterval
    var elapsedTime: TimeInterval = 0

    var startPosition: SIMD3<Float>
}

extension Entity {
    static func makeDamageEntity(for damage: Int, delay: TimeInterval, targetEntity: Entity) -> Entity {
        let damageEntity = Entity()

        if damage == 0 {
            let damageDigitComponent = DamageDigitComponent(
                digit: .miss,
                color: .yellow,
                duration: 0.8,
                delay: delay / 1000,
                startPosition: targetEntity.position(relativeTo: nil)
            )
            damageEntity.components.set(damageDigitComponent)
        } else {
            let damageDigitComponent = DamageDigitComponent(
                digit: .damage(damage),
                color: targetEntity.components[MapObjectComponent.self]?.mapObject.type == .pc ? .red : .white,
                duration: 1.5,
                delay: delay / 1000,
                startPosition: targetEntity.position(relativeTo: nil)
            )
            damageEntity.components.set(damageDigitComponent)
        }

        return damageEntity
    }
}
