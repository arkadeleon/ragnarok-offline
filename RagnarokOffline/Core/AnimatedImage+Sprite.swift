//
//  AnimatedImage+Sprite.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/9/4.
//

import ROCore
import RORendering

extension AnimatedImage {
    init(animation: SpriteRenderer.Animation) {
        self.init(
            frames: animation.frames,
            frameWidth: animation.frameWidth,
            frameHeight: animation.frameHeight,
            frameInterval: animation.frameInterval,
            scale: animation.scale
        )
    }
}
