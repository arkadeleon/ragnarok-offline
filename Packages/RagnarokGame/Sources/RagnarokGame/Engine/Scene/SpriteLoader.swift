//
//  SpriteLoader.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/4.
//

import RagnarokResources
import RagnarokSprite

@MainActor
final class SpriteLoader {
    private struct ObjectLoadTask {
        let spriteVersion: UInt64
        let task: Task<Void, Never>
    }

    private let resourceManager: ResourceManager

    private var objectLoadTasks: [GameObjectID : ObjectLoadTask] = [:]
    private var itemLoadTasks: [GameObjectID : Task<Void, Never>] = [:]

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    func loadSprite(forObject object: MapSceneMapObject) {
        let objectID = object.objectID
        let spriteVersion = object.spriteVersion

        if object.loadedSpriteVersion != spriteVersion {
            object.composedSprite = nil
            object.loadedSpriteVersion = nil
        }
        if let loadTask = objectLoadTasks[objectID], loadTask.spriteVersion != spriteVersion {
            objectLoadTasks.removeValue(forKey: objectID)?.task.cancel()
        }

        if object.job == 45 { // JT_WARPNPC
            return
        }

        guard object.composedSprite == nil, objectLoadTasks[objectID] == nil else {
            return
        }

        let configuration = ComposedSprite.Configuration(object: object)
        let task = Task { [weak self, weak object] in
            guard let self else {
                return
            }
            defer {
                // A newer sprite version may have replaced this load already.
                if objectLoadTasks[objectID]?.spriteVersion == spriteVersion {
                    objectLoadTasks.removeValue(forKey: objectID)
                }
            }

            guard let composedSprite = try? await ComposedSprite(
                configuration: configuration,
                resourceManager: resourceManager
            ) else {
                return
            }

            // The object left the map or changed how it looks while this was loading.
            guard let object, object.spriteVersion == spriteVersion else {
                return
            }

            object.composedSprite = composedSprite
            object.loadedSpriteVersion = spriteVersion
        }

        objectLoadTasks[objectID] = ObjectLoadTask(spriteVersion: spriteVersion, task: task)
    }

    func cancelObjectLoad(forObjectID objectID: GameObjectID) {
        objectLoadTasks.removeValue(forKey: objectID)?.task.cancel()
    }

    func loadSprite(forItem item: MapSceneDroppedItem) {
        let objectID = item.objectID
        let itemID = item.itemID

        guard item.sprite == nil, itemLoadTasks[objectID] == nil else {
            return
        }

        itemLoadTasks[objectID] = Task { [weak self, weak item] in
            guard let self else {
                return
            }
            defer {
                itemLoadTasks.removeValue(forKey: objectID)
            }

            guard let sprite = try? await resourceManager.itemSprite(forItemID: itemID) else {
                return
            }

            item?.sprite = sprite
        }
    }

    func cancelItemLoad(forItemID itemID: GameObjectID) {
        itemLoadTasks.removeValue(forKey: itemID)?.cancel()
    }

    func cancelAll() {
        for loadTask in objectLoadTasks.values {
            loadTask.task.cancel()
        }
        objectLoadTasks.removeAll()

        for loadTask in itemLoadTasks.values {
            loadTask.cancel()
        }
        itemLoadTasks.removeAll()
    }
}
