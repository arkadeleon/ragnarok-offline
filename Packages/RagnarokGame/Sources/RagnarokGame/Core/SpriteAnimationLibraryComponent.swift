//
//  SpriteAnimationLibraryComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/2/22.
//

import RealityKit

struct SpriteAnimationLibraryComponent: Component {
    private static let defaultAnimationKey = "default"

    var animations: [String : SpriteAnimation]

    var defaultAnimation: SpriteAnimation? {
        animations[Self.defaultAnimationKey]
    }

    init(animation: SpriteAnimation) {
        self.animations = [Self.defaultAnimationKey: animation]
    }

    init(animations: [String : SpriteAnimation]) {
        self.animations = animations
    }
}
