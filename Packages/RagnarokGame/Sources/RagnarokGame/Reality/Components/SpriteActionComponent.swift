//
//  SpriteActionComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/11/6.
//

import RagnarokSprite
import RealityKit

struct SpriteActionComponent: Component, Equatable {
    var actionType: SpriteActionType
    var direction: SpriteDirection
    var headDirection: SpriteHeadDirection
    var nextActionType: SpriteActionType? = nil
}
