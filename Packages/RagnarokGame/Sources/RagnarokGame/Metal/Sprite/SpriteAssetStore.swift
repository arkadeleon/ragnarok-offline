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

@MainActor
final class SpriteAssetStore {
    private let device: any MTLDevice
    private let resourceManager: ResourceManager

    private var objectLoadTasks: [GameObjectID : Task<Void, Never>] = [:]
    private var itemLoadTasks: [GameObjectID : Task<Void, Never>] = [:]

    init(device: any MTLDevice, resourceManager: ResourceManager) {
        self.device = device
        self.resourceManager = resourceManager
    }

    func sync(
        objects: [GameObjectID : MetalMapObject],
        items: [GameObjectID : MetalMapItem],
        camera: MapCameraState
    ) -> [SpriteLayerDrawable] {
        let currentObjectIDs = Set(objects.keys)
        let currentItemIDs = Set(items.keys)

        for objectID in Set(objectLoadTasks.keys).subtracting(currentObjectIDs) {
            objectLoadTasks[objectID]?.cancel()
            objectLoadTasks.removeValue(forKey: objectID)
        }

        for objectID in Set(itemLoadTasks.keys).subtracting(currentItemIDs) {
            itemLoadTasks[objectID]?.cancel()
            itemLoadTasks.removeValue(forKey: objectID)
        }

        for (_, object) in objects {
            syncObject(object)
        }

        for (_, item) in items {
            syncItem(item)
        }

        return drawables(objects: objects, items: items, camera: camera)
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

    private func syncObject(_ object: MetalMapObject) {
        let objectID = object.objectID
        let configuration = ComposedSprite.Configuration(object: object)
        if object.spriteConfiguration != configuration {
            objectLoadTasks[objectID]?.cancel()
            objectLoadTasks.removeValue(forKey: objectID)
            object.spriteConfiguration = configuration
            object.composedSprite = nil
            object.partTextures = nil
            object.drawables.removeAll()
        }

        guard object.composedSprite == nil, objectLoadTasks[objectID] == nil else {
            return
        }

        objectLoadTasks[objectID] = Task { [weak self, weak object] in
            guard let self, let object else {
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

            guard object.spriteConfiguration == configuration else {
                return
            }

            object.composedSprite = composedSprite
            object.partTextures = SpritePartTextures(device: self.device)
        }
    }

    private func syncItem(_ item: MetalMapItem) {
        let objectID = item.objectID
        guard item.sprite == nil, itemLoadTasks[objectID] == nil else {
            return
        }

        itemLoadTasks[objectID] = Task { [weak self, weak item] in
            guard let self, let item else {
                return
            }
            defer {
                self.itemLoadTasks.removeValue(forKey: objectID)
            }

            guard let sprite = try? await self.resourceManager.itemSprite(forItemID: item.itemID) else {
                return
            }

            item.sprite = sprite
            item.partTextures = SpritePartTextures(device: self.device)
        }
    }

    private func drawables(
        objects: [GameObjectID : MetalMapObject],
        items: [GameObjectID : MetalMapItem],
        camera: MapCameraState
    ) -> [SpriteLayerDrawable] {
        var sprites: [SpriteObject] = []
        sprites.reserveCapacity(objects.count + items.count)

        let frameResolver = SpriteFrameResolver()

        for (_, object) in objects {
            guard object.composedSprite != nil, object.partTextures != nil else {
                object.drawables.removeAll()
                continue
            }

            object.drawables = frameResolver.resolve(object, camera: camera)
            guard !object.drawables.isEmpty else {
                continue
            }
            sprites.append(object)
        }

        for (_, item) in items {
            guard item.sprite != nil, item.partTextures != nil else {
                item.drawables.removeAll()
                continue
            }

            item.drawables = frameResolver.resolve(item)
            guard !item.drawables.isEmpty else {
                continue
            }
            sprites.append(item)
        }

        sprites.sort {
            if $0.worldPosition.z == $1.worldPosition.z {
                $0.objectID < $1.objectID
            } else {
                $0.worldPosition.z < $1.worldPosition.z
            }
        }

        return sprites.flatMap(\.drawables)
    }
}
