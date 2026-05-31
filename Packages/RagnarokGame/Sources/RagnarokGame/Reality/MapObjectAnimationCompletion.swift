//
//  MapObjectAnimationCompletion.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/23.
//

import RagnarokSprite

public enum MapObjectAnimationCompletion: Sendable, Equatable {
    case indefinite
    case after(Duration, settledAction: SpriteActionType)
    case once(settledAction: SpriteActionType)
}
