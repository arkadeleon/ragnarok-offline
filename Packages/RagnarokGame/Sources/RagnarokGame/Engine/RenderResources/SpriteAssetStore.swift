//
//  SpriteAssetStore.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import Metal
import RagnarokModels
import RagnarokResources
import RagnarokSprite

struct ObjectSpriteAssets {
    let composedSprite: ComposedSprite
    let partTextures: SpritePartTextures
}

struct ItemSpriteAssets {
    let sprite: SpriteResource
    let partTextures: SpritePartTextures
}

@MainActor
final class SpriteAssetStore {
    private let device: any MTLDevice
    private let resourceManager: ResourceManager

    private var objectConfigurations: [GameObjectID : ComposedSprite.Configuration] = [:]
    private var objectAssets: [GameObjectID : ObjectSpriteAssets] = [:]
    private var itemAssets: [GameObjectID : ItemSpriteAssets] = [:]

    private var objectLoadTasks: [GameObjectID : Task<Void, Never>] = [:]
    private var itemLoadTasks: [GameObjectID : Task<Void, Never>] = [:]

    init(device: any MTLDevice, resourceManager: ResourceManager) {
        self.device = device
        self.resourceManager = resourceManager
    }

    func sync(
        objects: [GameObjectID : MapSceneMapObject],
        items: [GameObjectID : MapSceneDroppedItem],
        worldPositions: [GameObjectID : SIMD3<Float>],
        camera: MapCameraState
    ) -> [SpriteLayerDrawable] {
        let currentObjectIDs = Set(objects.keys)
        let currentItemIDs = Set(items.keys)

        for objectID in Set(objectConfigurations.keys).union(objectLoadTasks.keys).subtracting(currentObjectIDs) {
            objectLoadTasks.removeValue(forKey: objectID)?.cancel()
            objectConfigurations.removeValue(forKey: objectID)
            objectAssets.removeValue(forKey: objectID)
        }

        for itemID in Set(itemAssets.keys).union(itemLoadTasks.keys).subtracting(currentItemIDs) {
            itemLoadTasks.removeValue(forKey: itemID)?.cancel()
            itemAssets.removeValue(forKey: itemID)
        }

        for (_, object) in objects {
            syncObject(object)
        }

        for (_, item) in items {
            syncItem(item)
        }

        return drawables(
            objects: objects,
            items: items,
            worldPositions: worldPositions,
            camera: camera
        )
    }

    func cancelAllTasks() {
        for task in objectLoadTasks.values {
            task.cancel()
        }
        for task in itemLoadTasks.values {
            task.cancel()
        }

        objectLoadTasks.removeAll()
        itemLoadTasks.removeAll()
    }

    private func syncObject(_ object: MapSceneMapObject) {
        let objectID = object.objectID
        let configuration = ComposedSprite.Configuration(object: object)

        if objectConfigurations[objectID] != configuration {
            objectLoadTasks.removeValue(forKey: objectID)?.cancel()
            objectConfigurations[objectID] = configuration
            objectAssets.removeValue(forKey: objectID)
        }

        if object.job == 45 { // JT_WARPNPC
            return
        }

        guard objectAssets[objectID] == nil, objectLoadTasks[objectID] == nil else {
            return
        }

        objectLoadTasks[objectID] = Task { [weak self] in
            guard let self else {
                return
            }
            defer {
                self.objectLoadTasks.removeValue(forKey: objectID)
            }

            guard let composedSprite = try? await ComposedSprite(
                configuration: configuration,
                resourceManager: self.resourceManager
            ) else {
                return
            }

            guard self.objectConfigurations[objectID] == configuration else {
                return
            }

            self.objectAssets[objectID] = ObjectSpriteAssets(
                composedSprite: composedSprite,
                partTextures: SpritePartTextures(device: self.device)
            )
        }
    }

    private func syncItem(_ item: MapSceneDroppedItem) {
        let objectID = item.objectID
        let itemID = item.itemID

        guard itemAssets[objectID] == nil, itemLoadTasks[objectID] == nil else {
            return
        }

        itemLoadTasks[objectID] = Task { [weak self] in
            guard let self else {
                return
            }
            defer {
                self.itemLoadTasks.removeValue(forKey: objectID)
            }

            guard let sprite = try? await self.resourceManager.itemSprite(forItemID: itemID) else {
                return
            }

            self.itemAssets[objectID] = ItemSpriteAssets(
                sprite: sprite,
                partTextures: SpritePartTextures(device: self.device)
            )
        }
    }

    private func drawables(
        objects: [GameObjectID : MapSceneMapObject],
        items: [GameObjectID : MapSceneDroppedItem],
        worldPositions: [GameObjectID : SIMD3<Float>],
        camera: MapCameraState
    ) -> [SpriteLayerDrawable] {
        var sprites: [(objectID: GameObjectID, worldPosition: SIMD3<Float>, drawables: [SpriteLayerDrawable])] = []
        sprites.reserveCapacity(objects.count + items.count)

        let frameResolver = SpriteFrameResolver()

        for (objectID, object) in objects {
            guard let assets = objectAssets[objectID],
                  let worldPosition = worldPositions[objectID] else {
                continue
            }

            let drawables = frameResolver.resolve(
                object,
                assets: assets,
                worldPosition: worldPosition,
                camera: camera
            )
            guard !drawables.isEmpty else {
                continue
            }
            sprites.append((objectID, worldPosition, drawables))
        }

        for objectID in items.keys {
            guard let assets = itemAssets[objectID],
                  let worldPosition = worldPositions[objectID] else {
                continue
            }

            let drawables = frameResolver.resolve(
                objectID: objectID,
                assets: assets,
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
}
