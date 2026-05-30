//
//  SpellPointsComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RealityKit

struct SpellPointsComponent: Component {
    var sp: Int
    var maxSp: Int

    init(sp: Int, maxSp: Int) {
        self.sp = sp
        self.maxSp = maxSp
    }
}
