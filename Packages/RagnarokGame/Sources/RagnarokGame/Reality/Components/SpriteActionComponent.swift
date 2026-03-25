//
//  SpriteActionComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/11/6.
//

import RagnarokSprite
import RealityKit

struct SpriteActionComponent: Component, Equatable {
    var actionType: CharacterActionType
    var direction: CharacterDirection
    var headDirection: CharacterHeadDirection
    var nextActionType: CharacterActionType? = nil
}
