//
//  SpriteBillboardAssetStore.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

#if os(iOS) || os(macOS)

import Foundation
import Metal
import RagnarokModels
import RagnarokResources
import RagnarokSprite

@MainActor
final class SpriteBillboardAssetStore {
    private struct AnimationLoadKey: Hashable {
        let objectID: UInt32
        let animation: SpriteBillboardAnimationKey
    }

    private struct ObjectAssetEntry {
        var mapObject: MapObject
        var composedSprite: ComposedSprite?
        var animations: [SpriteBillboardAnimationKey : SpriteBillboardAnimationFrames]
    }

    private struct ItemAssetEntry {
        var texture: (any MTLTexture)?
        var frameWidth: Float
        var frameHeight: Float
    }

    private let device: any MTLDevice

    private var objectAssets: [UInt32 : ObjectAssetEntry] = [:]
    private var itemAssets: [UInt32 : ItemAssetEntry] = [:]
    private var objectLoadTasks: [UInt32 : Task<Void, Never>] = [:]
    private var itemLoadTasks: [UInt32 : Task<Void, Never>] = [:]
    private var animationLoadTasks: [AnimationLoadKey : Task<Void, Never>] = [:]

    init(device: any MTLDevice) {
        self.device = device
    }

    func sync(
        snapshots: [UInt32 : SpriteBillboardSnapshot],
        resourceManager: ResourceManager
    ) {
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
                    animationKey: animationKey,
                    resourceManager: resourceManager
                )
            case .item(let mapItem):
                syncItemAssets(
                    itemID: objectID,
                    mapItem: mapItem,
                    resourceManager: resourceManager
                )
            }
        }
    }

    func drawables(for snapshots: [UInt32 : SpriteBillboardSnapshot]) -> [UInt32 : SpriteBillboardDrawable] {
        var drawables: [UInt32 : SpriteBillboardDrawable] = [:]

        for (objectID, snapshot) in snapshots {
            switch snapshot.content {
            case .mapObject(_, let animationKey, let animationElapsed):
                let fallbackKeys = [
                    animationKey,
                    SpriteBillboardAnimationKey(action: .idle, direction: animationKey.direction),
                    SpriteBillboardAnimationKey(action: .idle, direction: .south),
                ]
                guard let objectAsset = objectAssets[objectID],
                      let resolved = resolvedAnimation(
                        from: objectAsset,
                        candidateKeys: fallbackKeys,
                        elapsed: animationElapsed
                      ) else {
                    continue
                }

                drawables[objectID] = SpriteBillboardDrawable(
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

                drawables[objectID] = SpriteBillboardDrawable(
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
        objectID: UInt32,
        mapObject: MapObject,
        animationKey: SpriteBillboardAnimationKey,
        resourceManager: ResourceManager
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
            prefetchKeys: prefetchKeys,
            resourceManager: resourceManager
        )

        for key in prefetchKeys {
            ensureAnimationLoaded(for: objectID, animationKey: key)
        }
    }

    private func syncItemAssets(
        itemID: UInt32,
        mapItem: MapItem,
        resourceManager: ResourceManager
    ) {
        if itemAssets[itemID] == nil {
            itemAssets[itemID] = ItemAssetEntry(
                texture: nil,
                frameWidth: 32,
                frameHeight: 32
            )
        }

        guard itemAssets[itemID]?.texture == nil, itemLoadTasks[itemID] == nil else {
            return
        }

        itemLoadTasks[itemID] = Task { [weak self] in
            guard let self else {
                return
            }
            defer {
                self.itemLoadTasks.removeValue(forKey: itemID)
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

            self.itemAssets[itemID] = ItemAssetEntry(
                texture: MapMetalTextureFactory.makeTexture(
                    from: animation.firstFrame,
                    device: self.device,
                    label: "sprite-item-\(itemID)"
                ),
                frameWidth: Float(animation.frameWidth),
                frameHeight: Float(animation.frameHeight)
            )
        }
    }

    private func ensureComposedSpriteLoaded(
        for objectID: UInt32,
        mapObject: MapObject,
        prefetchKeys: [SpriteBillboardAnimationKey],
        resourceManager: ResourceManager
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
        for animationKey: SpriteBillboardAnimationKey
    ) -> [SpriteBillboardAnimationKey] {
        [
            animationKey,
            SpriteBillboardAnimationKey(action: .idle, direction: animationKey.direction),
            SpriteBillboardAnimationKey(action: .idle, direction: .south),
        ]
    }

    private func ensureAnimationLoaded(
        for objectID: UInt32,
        animationKey: SpriteBillboardAnimationKey
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
        candidateKeys: [SpriteBillboardAnimationKey],
        elapsed: Duration
    ) -> (frames: SpriteBillboardAnimationFrames, texture: (any MTLTexture)?)? {
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
    ) -> SpriteBillboardAnimationFrames {
        let textures = animation.frames.enumerated().map { index, frame in
            MapMetalTextureFactory.makeTexture(
                from: frame,
                device: device,
                label: "\(labelPrefix)-frame-\(index)"
            )
        }
        return SpriteBillboardAnimationFrames(
            textures: textures,
            frameWidth: Float(animation.frameWidth),
            frameHeight: Float(animation.frameHeight),
            frameInterval: max(TimeInterval(animation.frameInterval), 1.0 / 60.0)
        )
    }

    private func texture(
        for animation: SpriteBillboardAnimationFrames,
        action: CharacterActionType,
        elapsed: Duration
    ) -> (any MTLTexture)? {
        guard !animation.textures.isEmpty else {
            return nil
        }

        let rawIndex = Int(seconds(elapsed) / animation.frameInterval)
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

    private func seconds(_ duration: Duration) -> Double {
        let components = duration.components
        return Double(components.seconds) + Double(components.attoseconds) / 1_000_000_000_000_000_000
    }
}

#endif
