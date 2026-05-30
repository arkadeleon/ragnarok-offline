//
//  HealthPointsComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RealityKit

struct HealthPointsComponent: Component {
    var hp: Int
    var maxHp: Int

    init(hp: Int, maxHp: Int) {
        self.hp = hp
        self.maxHp = maxHp
    }
}
