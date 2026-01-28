//
//  SpriteNextActionComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/1/28.
//

import RagnarokSprite
import RealityKit

struct SpriteNextActionComponent: Component {
    var actionType: CharacterActionType
    var direction: CharacterDirection
    var headDirection: CharacterHeadDirection
}
