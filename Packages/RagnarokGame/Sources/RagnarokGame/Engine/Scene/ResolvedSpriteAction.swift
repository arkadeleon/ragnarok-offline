//
//  ResolvedSpriteAction.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/4.
//

import RagnarokSprite

struct ResolvedSpriteAction {
    var actionType: SpriteActionType
    var direction: SpriteDirection
    var headDirection: SpriteHeadDirection
    var elapsedTime: Duration

    /// Which frame of the action the main part has reached, counted from the start without wrapping.
    var frameIndex: Int
}
