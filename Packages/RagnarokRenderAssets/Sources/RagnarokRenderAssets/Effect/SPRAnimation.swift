//
//  SPRAnimation.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import Foundation
import RagnarokFileFormats

public struct SPRAnimation: Sendable {
    public let frameImages: [CGImage]
    public let frameInterval: TimeInterval
    public let frameSize: SIMD2<Float>

    public init(act: ACT, spr: SPR, actionIndex: Int) {
        let action = act.action(at: actionIndex)
        let animation = action?.animation(using: spr.imagesBySpriteType())

        frameImages = animation?.frames.compactMap { $0 } ?? []
        frameInterval = TimeInterval(animation?.frameInterval ?? 1 / 12)
        frameSize = [
            Float(animation?.frameWidth ?? 0),
            Float(animation?.frameHeight ?? 0),
        ]
    }
}
