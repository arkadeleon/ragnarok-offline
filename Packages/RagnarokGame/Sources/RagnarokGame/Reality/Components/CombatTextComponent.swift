//
//  CombatTextComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/11/13.
//

import Foundation
import RealityKit

struct CombatTextComponent: Component {
    var combatText: MapSceneCombatText
    var color: Material.Color

    var elapsedTime: TimeInterval = 0

    var targetEntityID: Entity.ID?
    var startPosition: SIMD3<Float>?
}

extension Entity {
    static func makeCombatTextEntity(for combatText: MapSceneCombatText) -> Entity {
        let combatTextComponent = switch combatText.kind {
        case .miss:
            CombatTextComponent(
                combatText: combatText,
                color: .yellow,
            )
        case .damage:
            CombatTextComponent(
                combatText: combatText,
                color: combatText.target.isPlayer ? .red : .white
            )
        case .hpRecovery:
            CombatTextComponent(
                combatText: combatText,
                color: .green
            )
        case .spRecovery:
            CombatTextComponent(
                combatText: combatText,
                color: .blue
            )
        }

        let combatTextEntity = Entity()
        combatTextEntity.components.set(combatTextComponent)
        return combatTextEntity
    }
}
