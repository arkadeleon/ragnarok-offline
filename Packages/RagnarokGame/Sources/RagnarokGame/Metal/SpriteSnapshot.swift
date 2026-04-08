//
//  SpriteSnapshot.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import Metal
import RagnarokModels
import RagnarokSprite
import simd

struct SpriteAnimationKey: Hashable {
    var action: CharacterActionType
    var direction: CharacterDirection
}

struct SpriteAnimationFrames {
    var textures: [(any MTLTexture)?]
    var frameWidth: Float
    var frameHeight: Float
    var frameInterval: TimeInterval
}

struct SpriteDrawable {
    let objectID: GameObjectID
    var texture: (any MTLTexture)?
    var frameWidth: Float
    var frameHeight: Float
    var worldPosition: SIMD3<Float>
    var isVisible: Bool
}

struct SpriteSnapshot {
    enum Content {
        case mapObject(
            mapObject: MapObject,
            animationKey: SpriteAnimationKey,
            animationElapsed: Duration
        )
        case item(MapItem)
    }

    let objectID: GameObjectID
    var worldPosition: SIMD3<Float>
    var isVisible: Bool
    var content: Content
}
