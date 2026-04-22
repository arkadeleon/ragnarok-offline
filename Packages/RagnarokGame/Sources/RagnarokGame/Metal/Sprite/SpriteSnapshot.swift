//
//  SpriteSnapshot.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import RagnarokModels
import RagnarokSprite
import simd

struct SpriteAnimationKey: Hashable {
    var action: SpriteActionType
    var direction: SpriteDirection
}

struct SpriteSnapshot {
    enum Content {
        case mapObject(
            mapObject: MapObject,
            animationKey: SpriteAnimationKey,
            headDirection: SpriteHeadDirection,
            animationElapsed: Duration
        )
        case item(MapItem)
    }

    let objectID: GameObjectID
    var worldPosition: SIMD3<Float>
    var isVisible: Bool
    var content: Content
}
