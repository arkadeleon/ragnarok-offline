//
//  MetalAnimationCompletion.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokSprite

public enum MetalAnimationCompletion: Sendable, Equatable {
    case indefinite
    case after(Duration, settledAction: SpriteActionType)
    case once(settledAction: SpriteActionType)
}
