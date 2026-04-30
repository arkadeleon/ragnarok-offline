//
//  DamageDigitComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/11/13.
//

import Foundation
import RagnarokModels
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

    var targetObjectID: GameObjectID
    var targetEntityID: Entity.ID?
    var startPosition: SIMD3<Float>?
}

extension Entity {
    static func makeDamageEntity(for damage: Int, delay: Duration, targetObjectID: GameObjectID) -> Entity {
        let damageEntity = Entity()

        if damage == 0 {
            let damageDigitComponent = DamageDigitComponent(
                digit: .miss,
                color: .yellow,
                duration: 0.8,
                delay: delay.timeInterval,
                targetObjectID: targetObjectID
            )
            damageEntity.components.set(damageDigitComponent)
        } else {
            let damageDigitComponent = DamageDigitComponent(
                digit: .damage(damage),
                duration: 1.5,
                delay: delay.timeInterval,
                targetObjectID: targetObjectID
            )
            damageEntity.components.set(damageDigitComponent)
        }

        return damageEntity
    }
}
