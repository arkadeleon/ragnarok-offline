//
//  SpriteAssetStore.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import Metal
import RagnarokModels
import RagnarokSprite

@MainActor
final class SpriteAssetStore {
    private struct Textures {
        let sprite: ObjectIdentifier
        let partTextures: SpritePartTextures
    }

    private let device: any MTLDevice

    private var objectTextures: [GameObjectID : Textures] = [:]
    private var itemTextures: [GameObjectID : Textures] = [:]

    init(device: any MTLDevice) {
        self.device = device
    }

    func sync(
        objects: [GameObjectID : MapSceneMapObject],
        items: [GameObjectID : MapSceneDroppedItem],
        worldPositions: [GameObjectID : SIMD3<Float>]
    ) -> [SpriteLayerDrawable] {
        for objectID in Set(objectTextures.keys).subtracting(objects.keys) {
            objectTextures.removeValue(forKey: objectID)
        }

        for objectID in Set(itemTextures.keys).subtracting(items.keys) {
            itemTextures.removeValue(forKey: objectID)
        }

        var sprites: [(objectID: GameObjectID, worldPosition: SIMD3<Float>, drawables: [SpriteLayerDrawable])] = []
        sprites.reserveCapacity(objects.count + items.count)

        let frameResolver = SpriteFrameResolver()

        for (objectID, object) in objects {
            guard let composedSprite = object.composedSprite,
                  let worldPosition = worldPositions[objectID] else {
                continue
            }

            let drawables = frameResolver.resolve(
                object,
                composedSprite: composedSprite,
                partTextures: partTextures(for: composedSprite, in: &objectTextures, objectID: objectID),
                worldPosition: worldPosition
            )
            guard !drawables.isEmpty else {
                continue
            }
            sprites.append((objectID, worldPosition, drawables))
        }

        for (objectID, item) in items {
            guard let sprite = item.sprite,
                  let worldPosition = worldPositions[objectID] else {
                continue
            }

            let drawables = frameResolver.resolve(
                objectID: objectID,
                sprite: sprite,
                partTextures: partTextures(for: sprite, in: &itemTextures, objectID: objectID),
                worldPosition: worldPosition
            )
            guard !drawables.isEmpty else {
                continue
            }
            sprites.append((objectID, worldPosition, drawables))
        }

        sprites.sort {
            if $0.worldPosition.y == $1.worldPosition.y {
                $0.objectID < $1.objectID
            } else {
                $0.worldPosition.y > $1.worldPosition.y
            }
        }

        return sprites.flatMap(\.drawables)
    }

    private func partTextures(
        for sprite: AnyObject,
        in textures: inout [GameObjectID : Textures],
        objectID: GameObjectID
    ) -> SpritePartTextures {
        let identity = ObjectIdentifier(sprite)
        if let existing = textures[objectID], existing.sprite == identity {
            return existing.partTextures
        }

        let partTextures = SpritePartTextures(device: device)
        textures[objectID] = Textures(sprite: identity, partTextures: partTextures)
        return partTextures
    }
}
