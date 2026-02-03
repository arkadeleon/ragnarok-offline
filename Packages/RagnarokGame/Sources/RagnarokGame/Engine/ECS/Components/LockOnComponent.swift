//
//  LockOnComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/10/28.
//

import RealityKit

struct LockOnComponent: Component {
    var targetEntity: Entity
    var attackRange: Float
    var action: () -> Void
}
