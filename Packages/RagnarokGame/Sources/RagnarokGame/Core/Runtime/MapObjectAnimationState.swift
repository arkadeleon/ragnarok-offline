//
//  MapObjectAnimationState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/23.
//

import RagnarokSprite

public struct MapObjectAnimationState: Sendable, Equatable {
    public var action: SpriteActionType
    public var direction: SpriteDirection
    public var headDirection: SpriteHeadDirection
    public var elapsed: Duration
    public var completion: MapObjectAnimationCompletion
}
