//
//  SpriteAnimationComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/1/28.
//

import Foundation
import RealityKit

struct SpriteAnimationComponent: Component {
    var animation: SpriteAnimation
    var currentFrameIndex: Int? = nil
    var elapsedTime: TimeInterval = 0
}

extension Entity {
    func setSpriteAnimation(_ animation: SpriteAnimation, elapsedTime: TimeInterval = 0) {
        components.set(SpriteAnimationComponent(animation: animation, elapsedTime: elapsedTime))
        updatePosition(for: animation)
    }

    func updatePosition(for animation: SpriteAnimation) {
        position = [
            -animation.pivot.x / 32,
            animation.frameHeight / 2 / 32 * scale.y,
            (animation.frameHeight / 2 - animation.pivot.y) / 32,
        ]
    }
}
