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
    private struct DrawableGroup {
        let depth: Float
        let objectID: GameObjectID
        let drawables: [SpriteLayerDrawable]
    }

    private struct ObjectAssetEntry {
        var mapObject: MapObject
        var composedSprite: ComposedSprite?
        var partTextures: SpritePartTextures?
    }

    private struct ItemAssetEntry {
        var composedSprite: ComposedSprite?
        var partTextures: SpritePartTextures?
    }

    private static let itemSpriteConfiguration = ComposedSprite.Configuration(jobID: 45)

    private let device: any MTLDevice
    private let resourceManager: ResourceManager
    private let scriptContext: ScriptContext
    private let frameResolver = SpriteFrameResolver()

    private var objectAssets: [GameObjectID : ObjectAssetEntry] = [:]
    private var objectLoadTasks: [GameObjectID : Task<Void, Never>] = [:]
    private var itemAssets: [GameObjectID : ItemAssetEntry] = [:]
    private var itemLoadTasks: [GameObjectID : Task<Void, Never>] = [:]

    init(device: any MTLDevice, resourceManager: ResourceManager, scriptContext: ScriptContext) {
        self.device = device
        self.resourceManager = resourceManager
        self.scriptContext = scriptContext
    }

    func sync(snapshots: [GameObjectID : SpriteSnapshot]) {
        let currentIDs = Set(snapshots.keys)

        for objectID in Set(objectAssets.keys).subtracting(currentIDs) {
            objectAssets.removeValue(forKey: objectID)
            objectLoadTasks[objectID]?.cancel()
            objectLoadTasks.removeValue(forKey: objectID)
        }

        for itemID in Set(itemAssets.keys).subtracting(currentIDs) {
            itemAssets.removeValue(forKey: itemID)
            itemLoadTasks[itemID]?.cancel()
            itemLoadTasks.removeValue(forKey: itemID)
        }

        for (objectID, snapshot) in snapshots {
            switch snapshot.content {
            case .mapObject(let mapObject, _, _, _):
                syncObjectAssets(objectID: objectID, mapObject: mapObject)
            case .item(let mapItem):
                syncItemAssets(objectID: objectID, mapItem: mapItem)
            }
        }
    }

    func drawables(for snapshots: [GameObjectID : SpriteSnapshot]) -> [SpriteLayerDrawable] {
        var groups: [DrawableGroup] = []
        groups.reserveCapacity(snapshots.count)

        for (objectID, snapshot) in snapshots {
            switch snapshot.content {
            case .mapObject(_, let animationKey, let headDirection, let animationElapsed):
                guard let objectAsset = objectAssets[objectID],
                      let composedSprite = objectAsset.composedSprite,
                      let partTextures = objectAsset.partTextures else {
                    continue
                }

                let fallbackKeys = [
                    animationKey,
                    SpriteAnimationKey(action: .idle, direction: animationKey.direction),
                    SpriteAnimationKey(action: .idle, direction: .south),
                ]

                guard let resolvedDrawables = fallbackKeys.lazy.compactMap({ key in
                    let input = SpriteFrameResolver.ResolveInput(
                        objectID: objectID,
                        composedSprite: composedSprite,
                        animationKey: key,
                        headDirection: headDirection,
                        elapsed: animationElapsed,
                        partTextures: partTextures,
                        scriptContext: self.scriptContext,
                        worldPosition: snapshot.worldPosition,
                        isVisible: snapshot.isVisible
                    )
                    let drawables = self.frameResolver.resolve(input)
                    return drawables.isEmpty ? nil : drawables
                }).first else {
                    continue
                }

                groups.append(
                    DrawableGroup(
                        depth: snapshot.worldPosition.z,
                        objectID: objectID,
                        drawables: resolvedDrawables
                    )
                )

            case .item:
                guard let itemAsset = itemAssets[objectID],
                      let composedSprite = itemAsset.composedSprite,
                      let partTextures = itemAsset.partTextures else {
                    continue
                }

                let input = SpriteFrameResolver.ResolveInput(
                    objectID: objectID,
                    composedSprite: composedSprite,
                    animationKey: SpriteAnimationKey(action: .idle, direction: .south),
                    headDirection: .lookForward,
                    elapsed: .zero,
                    partTextures: partTextures,
                    scriptContext: scriptContext,
                    worldPosition: snapshot.worldPosition,
                    isVisible: snapshot.isVisible
                )
                let drawables = frameResolver.resolve(input)
                guard !drawables.isEmpty else {
                    continue
                }

                groups.append(
                    DrawableGroup(
                        depth: snapshot.worldPosition.z,
                        objectID: objectID,
                        drawables: drawables
                    )
                )
            }
        }

        groups.sort {
            if $0.depth == $1.depth {
                $0.objectID < $1.objectID
            } else {
                $0.depth < $1.depth
            }
        }

        return groups.flatMap(\.drawables)
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
        objectAssets.removeAll()
        itemAssets.removeAll()
    }

    private func syncObjectAssets(objectID: GameObjectID, mapObject: MapObject) {
        if objectAssets[objectID] == nil {
            objectAssets[objectID] = ObjectAssetEntry(
                mapObject: mapObject,
                composedSprite: nil,
                partTextures: nil
            )
        }
        objectAssets[objectID]?.mapObject = mapObject

        guard objectAssets[objectID]?.composedSprite == nil, objectLoadTasks[objectID] == nil else {
            return
        }

        objectLoadTasks[objectID] = Task { [weak self] in
            guard let self else {
                return
            }
            defer {
                self.objectLoadTasks.removeValue(forKey: objectID)
            }

            let configuration = ComposedSprite.Configuration(mapObject: mapObject)
            guard let composedSprite = try? await ComposedSprite(
                configuration: configuration,
                resourceManager: self.resourceManager
            ) else {
                return
            }

            self.objectAssets[objectID]?.composedSprite = composedSprite
            self.objectAssets[objectID]?.partTextures = SpritePartTextures(
                device: self.device,
                composedSprite: composedSprite
            )
        }
    }

    private func syncItemAssets(objectID: GameObjectID, mapItem: MapItem) {
        if itemAssets[objectID] == nil {
            itemAssets[objectID] = ItemAssetEntry(
                composedSprite: nil,
                partTextures: nil
            )
        }

        guard itemAssets[objectID]?.composedSprite == nil, itemLoadTasks[objectID] == nil else {
            return
        }

        itemLoadTasks[objectID] = Task { [weak self] in
            guard let self else {
                return
            }
            defer {
                self.itemLoadTasks.removeValue(forKey: objectID)
            }

            guard let sprite = try? await self.resourceManager.itemSprite(forItemID: Int(mapItem.itemID)) else {
                return
            }

            let part = ComposedSprite.Part(sprite: sprite, semantic: .main)
            let composedSprite = ComposedSprite(
                configuration: Self.itemSpriteConfiguration,
                resourceManager: self.resourceManager,
                parts: [part]
            )

            self.itemAssets[objectID]?.composedSprite = composedSprite
            self.itemAssets[objectID]?.partTextures = SpritePartTextures(
                device: self.device,
                composedSprite: composedSprite
            )
        }
    }
}
