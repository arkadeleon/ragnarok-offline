//
//  SpriteBillboardSnapshot.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import Metal
import RagnarokModels
import RagnarokSprite
import simd

struct SpriteBillboardAnimationKey: Hashable {
    var action: CharacterActionType
    var direction: CharacterDirection
}

struct SpriteBillboardAnimationFrames {
    var textures: [(any MTLTexture)?]
    var frameWidth: Float
    var frameHeight: Float
    var frameInterval: TimeInterval
}

struct SpriteBillboardDrawable {
    let objectID: GameObjectID
    var texture: (any MTLTexture)?
    var frameWidth: Float
    var frameHeight: Float
    var worldPosition: SIMD3<Float>
    var isVisible: Bool
}

struct SpriteBillboardSnapshot {
    enum Content {
        case mapObject(
            mapObject: MapObject,
            animationKey: SpriteBillboardAnimationKey,
            animationElapsed: Duration
        )
        case item(MapItem)
    }

    let objectID: GameObjectID
    var worldPosition: SIMD3<Float>
    var isVisible: Bool
    var content: Content
}
