//
//  CombatTextComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/11/13.
//

import Foundation
import RealityKit

struct CombatTextComponent: Component {
    var combatText: MapCombatText
    var color: Material.Color

    var elapsedTime: TimeInterval = 0

    var targetEntityID: Entity.ID?
    var startPosition: SIMD3<Float>?
}

extension Entity {
    static func makeCombatTextEntity(for combatText: MapCombatText) -> Entity {
        let combatTextEntity = Entity()

        switch combatText.kind {
        case .miss:
            let combatTextComponent = CombatTextComponent(
                combatText: combatText,
                color: .yellow,
            )
            combatTextEntity.components.set(combatTextComponent)
        case .damage:
            let combatTextComponent = CombatTextComponent(
                combatText: combatText,
                color: combatText.target.isPlayer ? .red : .white
            )
            combatTextEntity.components.set(combatTextComponent)
        }

        return combatTextEntity
    }
}
