//
//  SpriteAnimationsComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/2/22.
//

import RealityKit

struct SpriteAnimationsComponent: Component {
    var animations: [String : SpriteAnimation]

    var defaultAnimation: SpriteAnimation? {
        animations["default"]
    }

    init(animation: SpriteAnimation) {
        self.animations = ["default": animation]
    }

    init(animations: [String : SpriteAnimation]) {
        self.animations = animations
    }
}
