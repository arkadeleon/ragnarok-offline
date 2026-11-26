//
//  SpriteAssetStore.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import Foundation
import Metal
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokSprite
import simd

@MainActor
final class SpriteAssetStore {
    private struct Textures {
        let sprite: AnyObject
        let partTextures: SpritePartTextures
    }

    private struct ActiveAfterimage {
        let baseDrawable: SpriteDrawable
        let tint: SIMD3<Float>
        let initialAlpha: Float
        var remainingTime: TimeInterval
        let totalTime: TimeInterval
    }

    private let device: any MTLDevice
    private let shadowmap: GroundShadowmap

    private var objectTextures: [GameObjectID : Textures] = [:]
    private var itemTextures: [GameObjectID : Textures] = [:]
    private var afterimages: [ActiveAfterimage] = []

    init(device: any MTLDevice, shadowmap: GroundShadowmap) {
        self.device = device
        self.shadowmap = shadowmap
    }

    func sync(
        objects: [GameObjectID : MapSceneMapObject],
        items: [GameObjectID : MapSceneDroppedItem],
        deltaTime: TimeInterval = 0
    ) -> [SpriteDrawable] {
        if deltaTime > 0 && !afterimages.isEmpty {
            afterimages = afterimages.compactMap { afterimage in
                var afterimage = afterimage
                afterimage.remainingTime -= deltaTime
                return afterimage.remainingTime > 0 ? afterimage : nil
            }
        }

        var sprites: [SpriteDrawable] = []
        sprites.reserveCapacity(objects.count + items.count + afterimages.count)

        let frameResolver = SpriteFrameResolver()

        for (objectID, object) in objects {
            let pendingAfterimages = object.effectModifiers.takePendingAfterimages()

            guard let composedSprite = object.composedSprite else {
                continue
            }

            let worldPosition = object.worldPosition
            let drawable = frameResolver.resolve(
                object,
                composedSprite: composedSprite,
                partTextures: partTextures(for: composedSprite, in: &objectTextures, objectID: objectID),
                worldPosition: worldPosition,
                shadow: shadowmap.shadowFactor(x: worldPosition.x, y: -worldPosition.z)
            )
            guard let drawable else {
                continue
            }
            sprites.append(drawable)

            for request in pendingAfterimages where drawable.isVisible {
                let (defaultTint, initialAlpha) = afterimageDefaults(for: request.style)
                let tint = request.tint.map({ SIMD3<Float>($0.x, $0.y, $0.z) }) ?? defaultTint
                let afterimage = ActiveAfterimage(
                    baseDrawable: drawable,
                    tint: tint,
                    initialAlpha: initialAlpha,
                    remainingTime: request.duration,
                    totalTime: request.duration
                )
                afterimages.append(afterimage)
            }
        }

        for (objectID, item) in items {
            guard let sprite = item.sprite else {
                continue
            }

            let worldPosition = item.worldPosition
            let drawable = frameResolver.resolve(
                objectID: objectID,
                sprite: sprite,
                partTextures: partTextures(for: sprite, in: &itemTextures, objectID: objectID),
                worldPosition: worldPosition,
                shadow: shadowmap.shadowFactor(x: worldPosition.x, y: -worldPosition.z)
            )
            guard let drawable else {
                continue
            }
            sprites.append(drawable)
        }

        for afterimage in afterimages {
            let ratio = Float(afterimage.remainingTime / max(afterimage.totalTime, 1e-6))
            let alphaMultiplier = afterimage.initialAlpha * min(max(ratio, 0), 1)
            let drawable = makeAfterimageDrawable(
                from: afterimage.baseDrawable,
                tint: afterimage.tint,
                alphaMultiplier: alphaMultiplier
            )
            sprites.append(drawable)
        }

        return sprites
    }

    func makeAfterimageDrawable(
        from base: SpriteDrawable,
        tint: SIMD3<Float>,
        alphaMultiplier: Float
    ) -> SpriteDrawable {
        let clampedAlpha = min(max(alphaMultiplier, 0), 1)
        let modulatedLayers = base.layers.map { layer in
            let vertices = layer.vertices.map { vertex in
                var vertex = vertex
                vertex.color = SIMD4<Float>(
                    vertex.color.x * tint.x,
                    vertex.color.y * tint.y,
                    vertex.color.z * tint.z,
                    vertex.color.w * clampedAlpha
                )
                return vertex
            }
            return SpriteDrawable.Layer(vertices: vertices, texture: layer.texture)
        }

        return SpriteDrawable(
            objectID: base.objectID,
            worldPosition: base.worldPosition,
            shadow: base.shadow,
            isVisible: base.isVisible,
            isAfterimage: true,
            layers: modulatedLayers
        )
    }

    private func afterimageDefaults(for style: EffectAfterimageStyle) -> (tint: SIMD3<Float>, alpha: Float) {
        switch style {
        case .blur:
            ([1, 1, 1], 0.65)
        case .hallucination:
            ([1, 1, 1], 0.55)
        case .paleBlur:
            ([155.0 / 255.0, 155.0 / 255.0, 1], 0.5)
        case .lightBlur:
            ([225.0 / 255.0, 225.0 / 255.0, 1], 0.7)
        }
    }

    func removeObjectTextures(forObjectID objectID: GameObjectID) {
        objectTextures.removeValue(forKey: objectID)
    }

    func removeItemTextures(forItemID itemID: GameObjectID) {
        itemTextures.removeValue(forKey: itemID)
    }

    func removeAll() {
        objectTextures.removeAll()
        itemTextures.removeAll()
        afterimages.removeAll()
    }

    private func partTextures(
        for sprite: AnyObject,
        in textures: inout [GameObjectID : Textures],
        objectID: GameObjectID
    ) -> SpritePartTextures {
        if let existing = textures[objectID], existing.sprite === sprite {
            return existing.partTextures
        }

        let partTextures = SpritePartTextures(device: device)
        textures[objectID] = Textures(sprite: sprite, partTextures: partTextures)
        return partTextures
    }
}
