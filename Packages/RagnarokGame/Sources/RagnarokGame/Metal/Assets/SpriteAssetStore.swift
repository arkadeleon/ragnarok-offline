//
//  SpriteAssetStore.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import Foundation
import Metal
import RagnarokMetalRendering
import RagnarokModels
import RagnarokResources
import RagnarokSprite

@MainActor
final class SpriteAssetStore {
    private struct AnimationLoadKey: Hashable {
        let objectID: GameObjectID
        let animation: SpriteAnimationKey
    }

    private struct ObjectAssetEntry {
        var mapObject: MapObject
        var composedSprite: ComposedSprite?
        var animations: [SpriteAnimationKey : SpriteAnimationFrames]
    }

    private struct ItemAssetEntry {
        var texture: (any MTLTexture)?
        var frameWidth: Float
        var frameHeight: Float
    }

    private let device: any MTLDevice
    private let resourceManager: ResourceManager

    private var objectAssets: [GameObjectID : ObjectAssetEntry] = [:]
    private var itemAssets: [GameObjectID : ItemAssetEntry] = [:]
    private var objectLoadTasks: [GameObjectID : Task<Void, Never>] = [:]
    private var itemLoadTasks: [GameObjectID : Task<Void, Never>] = [:]
    private var animationLoadTasks: [AnimationLoadKey : Task<Void, Never>] = [:]

    init(device: any MTLDevice, resourceManager: ResourceManager) {
        self.device = device
        self.resourceManager = resourceManager
    }

    func sync(snapshots: [GameObjectID : SpriteSnapshot]) {
        let currentIDs = Set(snapshots.keys)

        for objectID in Set(objectAssets.keys).subtracting(currentIDs) {
            objectAssets.removeValue(forKey: objectID)
            objectLoadTasks[objectID]?.cancel()
            objectLoadTasks.removeValue(forKey: objectID)

            let animationKeysToRemove = animationLoadTasks.keys.filter { $0.objectID == objectID }
            for key in animationKeysToRemove {
                animationLoadTasks[key]?.cancel()
                animationLoadTasks.removeValue(forKey: key)
            }
        }

        for itemID in Set(itemAssets.keys).subtracting(currentIDs) {
            itemAssets.removeValue(forKey: itemID)
            itemLoadTasks[itemID]?.cancel()
            itemLoadTasks.removeValue(forKey: itemID)
        }

        for (objectID, snapshot) in snapshots {
            switch snapshot.content {
            case .mapObject(let mapObject, let animationKey, _):
                syncObjectAssets(
                    objectID: objectID,
                    mapObject: mapObject,
                    animationKey: animationKey
                )
            case .item(let mapItem):
                syncItemAssets(
                    objectID: objectID,
                    mapItem: mapItem
                )
            }
        }
    }

    func drawables(for snapshots: [GameObjectID : SpriteSnapshot]) -> [GameObjectID : SpriteDrawable] {
        var drawables: [GameObjectID : SpriteDrawable] = [:]

        for (objectID, snapshot) in snapshots {
            switch snapshot.content {
            case .mapObject(_, let animationKey, let animationElapsed):
                let fallbackKeys = [
                    animationKey,
                    SpriteAnimationKey(action: .idle, direction: animationKey.direction),
                    SpriteAnimationKey(action: .idle, direction: .south),
                ]
                guard let objectAsset = objectAssets[objectID],
                      let resolved = resolvedAnimation(
                        from: objectAsset,
                        candidateKeys: fallbackKeys,
                        elapsed: animationElapsed
                      ) else {
                    continue
                }

                drawables[objectID] = SpriteDrawable(
                    objectID: objectID,
                    texture: resolved.texture,
                    frameWidth: resolved.frames.frameWidth,
                    frameHeight: resolved.frames.frameHeight,
                    worldPosition: snapshot.worldPosition,
                    isVisible: snapshot.isVisible
                )

            case .item:
                guard let itemAsset = itemAssets[objectID] else {
                    continue
                }

                drawables[objectID] = SpriteDrawable(
                    objectID: objectID,
                    texture: itemAsset.texture,
                    frameWidth: itemAsset.frameWidth,
                    frameHeight: itemAsset.frameHeight,
                    worldPosition: snapshot.worldPosition,
                    isVisible: snapshot.isVisible
                )
            }
        }

        return drawables
    }

    func cancelAllTasks() {
        for task in objectLoadTasks.values {
            task.cancel()
        }
        for task in itemLoadTasks.values {
            task.cancel()
        }
        for task in animationLoadTasks.values {
            task.cancel()
        }

        objectLoadTasks.removeAll()
        itemLoadTasks.removeAll()
        animationLoadTasks.removeAll()
        objectAssets.removeAll()
        itemAssets.removeAll()
    }

    private func syncObjectAssets(
        objectID: GameObjectID,
        mapObject: MapObject,
        animationKey: SpriteAnimationKey
    ) {
        let prefetchKeys = prefetchAnimationKeys(for: animationKey)

        if objectAssets[objectID] == nil {
            objectAssets[objectID] = ObjectAssetEntry(
                mapObject: mapObject,
                composedSprite: nil,
                animations: [:]
            )
        }
        objectAssets[objectID]?.mapObject = mapObject

        ensureComposedSpriteLoaded(
            for: objectID,
            mapObject: mapObject,
            prefetchKeys: prefetchKeys
        )

        for key in prefetchKeys {
            ensureAnimationLoaded(for: objectID, animationKey: key)
        }
    }

    private func syncItemAssets(
        objectID: GameObjectID,
        mapItem: MapItem
    ) {
        if itemAssets[objectID] == nil {
            itemAssets[objectID] = ItemAssetEntry(
                texture: nil,
                frameWidth: 32,
                frameHeight: 32
            )
        }

        guard itemAssets[objectID]?.texture == nil, itemLoadTasks[objectID] == nil else {
            return
        }

        itemLoadTasks[objectID] = Task { [weak self] in
            guard let self else {
                return
            }
            defer {
                self.itemLoadTasks.removeValue(forKey: objectID)
            }

            let scriptContext = await resourceManager.scriptContext()
            guard let path = ResourcePath.generateItemSpritePath(
                itemID: Int(mapItem.itemID),
                scriptContext: scriptContext
            ),
            let sprite = try? await resourceManager.sprite(at: path) else {
                return
            }

            guard !Task.isCancelled else {
                return
            }

            let animation = await SpriteRenderer().render(sprite: sprite, actionIndex: 0)

            guard !Task.isCancelled else {
                return
            }

            self.itemAssets[objectID] = ItemAssetEntry(
                texture: MetalTextureFactory.makeTexture(
                    from: animation.firstFrame,
                    device: self.device,
                    label: "sprite-item-\(objectID)"
                ),
                frameWidth: Float(animation.frameWidth),
                frameHeight: Float(animation.frameHeight)
            )
        }
    }

    private func ensureComposedSpriteLoaded(
        for objectID: GameObjectID,
        mapObject: MapObject,
        prefetchKeys: [SpriteAnimationKey]
    ) {
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
                resourceManager: resourceManager
            ) else {
                return
            }

            guard !Task.isCancelled else {
                return
            }

            self.objectAssets[objectID]?.composedSprite = composedSprite
            for key in prefetchKeys {
                self.ensureAnimationLoaded(for: objectID, animationKey: key)
            }
        }
    }

    private func prefetchAnimationKeys(
        for animationKey: SpriteAnimationKey
    ) -> [SpriteAnimationKey] {
        [
            animationKey,
            SpriteAnimationKey(action: .idle, direction: animationKey.direction),
            SpriteAnimationKey(action: .idle, direction: .south),
        ]
    }

    private func ensureAnimationLoaded(
        for objectID: GameObjectID,
        animationKey: SpriteAnimationKey
    ) {
        guard let objectAsset = objectAssets[objectID],
              objectAsset.animations[animationKey] == nil,
              objectAsset.composedSprite != nil else {
            return
        }

        let loadKey = AnimationLoadKey(objectID: objectID, animation: animationKey)
        guard animationLoadTasks[loadKey] == nil else {
            return
        }

        animationLoadTasks[loadKey] = Task { [weak self] in
            guard let self else {
                return
            }
            defer {
                self.animationLoadTasks.removeValue(forKey: loadKey)
            }

            guard let composedSprite = self.objectAssets[objectID]?.composedSprite else {
                return
            }

            let animation = await SpriteRenderer().render(
                composedSprite: composedSprite,
                actionType: animationKey.action,
                direction: animationKey.direction,
                rendersShadow: false
            )

            guard !Task.isCancelled else {
                return
            }

            self.objectAssets[objectID]?.animations[animationKey] = makeAnimationFrames(
                from: animation,
                labelPrefix: "sprite-obj-\(objectID)-\(animationKey.action.rawValue)-\(animationKey.direction.rawValue)"
            )
        }
    }

    private func resolvedAnimation(
        from objectAsset: ObjectAssetEntry,
        candidateKeys: [SpriteAnimationKey],
        elapsed: Duration
    ) -> (frames: SpriteAnimationFrames, texture: (any MTLTexture)?)? {
        for key in candidateKeys {
            guard let frames = objectAsset.animations[key],
                  let texture = texture(for: frames, action: key.action, elapsed: elapsed) else {
                continue
            }
            return (frames, texture)
        }

        return nil
    }

    private func makeAnimationFrames(
        from animation: SpriteRenderer.Animation,
        labelPrefix: String
    ) -> SpriteAnimationFrames {
        let textures = animation.frames.enumerated().map { index, frame in
            MetalTextureFactory.makeTexture(
                from: frame,
                device: device,
                label: "\(labelPrefix)-frame-\(index)"
            )
        }
        return SpriteAnimationFrames(
            textures: textures,
            frameWidth: Float(animation.frameWidth),
            frameHeight: Float(animation.frameHeight),
            frameInterval: max(TimeInterval(animation.frameInterval), 1.0 / 60.0)
        )
    }

    private func texture(
        for animation: SpriteAnimationFrames,
        action: CharacterActionType,
        elapsed: Duration
    ) -> (any MTLTexture)? {
        guard !animation.textures.isEmpty else {
            return nil
        }

        let rawIndex = Int(elapsed.timeInterval / animation.frameInterval)
        let frameIndex: Int
        if actionRepeats(action) {
            frameIndex = rawIndex % animation.textures.count
        } else {
            frameIndex = min(rawIndex, animation.textures.count - 1)
        }
        return animation.textures[frameIndex]
    }

    private func actionRepeats(_ action: CharacterActionType) -> Bool {
        switch action {
        case .idle, .walk, .sit, .readyToAttack, .freeze, .freeze2:
            true
        case .pickup, .attack1, .hurt, .die, .attack2, .attack3, .skill:
            false
        }
    }
}
