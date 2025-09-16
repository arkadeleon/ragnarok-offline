//
//  AnimatedImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/5/8.
//

import CoreGraphics
import FileFormats
import RORendering

struct AnimatedImage: Hashable, Sendable {
    var frames: [CGImage?]
    var frameWidth: CGFloat
    var frameHeight: CGFloat
    var frameInterval: CGFloat
    var scale: CGFloat

    var firstFrame: CGImage? {
        frames.first ?? nil
    }

    init(frames: [CGImage?], frameWidth: CGFloat, frameHeight: CGFloat, frameInterval: CGFloat, scale: CGFloat) {
        self.frames = frames
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
        self.frameInterval = frameInterval
        self.scale = scale
    }
}

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

    init(animation: ACTAnimation) {
        self.init(
            frames: animation.frames,
            frameWidth: animation.frameWidth,
            frameHeight: animation.frameHeight,
            frameInterval: animation.frameInterval,
            scale: 1
        )
    }
}
