//
//  MetalMapItem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
import RagnarokModels
import RagnarokSprite
import simd

final class MetalMapItem: SpriteObject {
    let itemID: Int

    var sprite: SpriteResource?
    var partTextures: SpritePartTextures?

    init(
        item: MapItem,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>
    ) {
        itemID = Int(item.itemID)

        super.init(
            objectID: item.objectID,
            gridPosition: gridPosition,
            worldPosition: worldPosition
        )
    }
}
