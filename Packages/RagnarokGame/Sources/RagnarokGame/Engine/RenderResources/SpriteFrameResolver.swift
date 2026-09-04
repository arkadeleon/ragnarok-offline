//
//  SpriteFrameResolver.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/13.
//

import Metal
import RagnarokFileFormats
import RagnarokShaders
import RagnarokSprite
import simd

struct SpriteFrameResolver {
    private struct ResolvedLayer {
        let zIndex: Int
        let order: Int
        let vertices: [SpriteVertex]
        let texture: any MTLTexture
    }

    func resolve(
        _ object: MapSceneMapObject,
        composedSprite: ComposedSprite,
        partTextures: SpritePartTextures,
        worldPosition: SIMD3<Float>
    ) -> [SpriteLayerDrawable] {
        guard let resolvedAction = object.resolvedAction else {
            return []
        }

        let actionIndex = resolvedAction.actionType.calculateActionIndex(
            forJobID: composedSprite.configuration.job.rawValue,
            direction: resolvedAction.direction
        )

        var resolvedLayers: [ResolvedLayer] = []
        resolvedLayers.reserveCapacity(24)

        for (partIndex, part) in composedSprite.parts.enumerated() {
            let partActionIndex = (part.semantic == .shadow ? 0 : actionIndex)
            guard let partAction = part.sprite.act.action(at: partActionIndex), !partAction.frames.isEmpty else {
                continue
            }

            let frameRange = part.frameRange(
                action: partAction,
                actionType: resolvedAction.actionType,
                headDirection: resolvedAction.headDirection
            )
            guard !frameRange.isEmpty else {
                continue
            }

            let frameInterval = part.frameInterval(
                action: partAction,
                actionType: resolvedAction.actionType,
                frameCount: frameRange.count,
                attackDelay: object.attackDelay
            )
            let rawFrameIndex = Int(resolvedAction.elapsedTime / frameInterval)
            let localFrameIndex: Int
            if resolvedAction.actionType.repeats {
                localFrameIndex = rawFrameIndex % frameRange.count
            } else {
                localFrameIndex = min(rawFrameIndex, frameRange.count - 1)
            }
            let absoluteFrameIndex = frameRange.lowerBound + localFrameIndex

            guard let frame = part.sprite.act.frame(at: [partActionIndex, absoluteFrameIndex]) else {
                continue
            }

            let zIndex = composedSprite.zIndex(
                for: part,
                direction: resolvedAction.direction,
                actionIndex: actionIndex,
                frameIndex: absoluteFrameIndex
            )
            let parentOffset = part.parentOffset(
                actionType: resolvedAction.actionType,
                action: partAction,
                actionIndex: partActionIndex,
                absoluteFrameIndex: absoluteFrameIndex,
                frame: frame
            )
            let partScale = Float(part.scaleFactor)

            for (layerIndex, layer) in frame.layers.enumerated() where layer.color.alpha != 0 {
                guard let image = part.sprite.image(for: layer), image.width * image.height > 1 else {
                    continue
                }

                guard let texture = partTextures.texture(
                    for: layer,
                    resource: part.sprite,
                    label: "sprite-\(object.objectID)-\(partIndex)-\(layerIndex)"
                ) else {
                    continue
                }

                let vertices = makeVertices(
                    layer: layer,
                    parentOffset: parentOffset,
                    partScale: partScale,
                    width: image.width,
                    height: image.height,
                    opacity: object.opacity
                )
                resolvedLayers.append(
                    ResolvedLayer(
                        zIndex: zIndex,
                        order: resolvedLayers.count,
                        vertices: vertices,
                        texture: texture
                    )
                )
            }
        }

        resolvedLayers.sort {
            if $0.zIndex == $1.zIndex {
                $0.order < $1.order
            } else {
                $0.zIndex < $1.zIndex
            }
        }

        return resolvedLayers.map {
            SpriteLayerDrawable(
                objectID: object.objectID,
                vertices: $0.vertices,
                texture: $0.texture,
                worldPosition: worldPosition + [0, 0, 0.2], // Lifted slightly so uneven ground doesn't clip the sprite.
                isVisible: object.effectState != .cloak
            )
        }
    }

    func resolve(
        objectID: GameObjectID,
        sprite: SpriteResource,
        partTextures: SpritePartTextures,
        worldPosition: SIMD3<Float>
    ) -> [SpriteLayerDrawable] {
        guard let action = sprite.act.action(at: 0),
              let frame = action.frames.first else {
            return []
        }

        return frame.layers.enumerated().compactMap { layerIndex, layer in
            guard layer.color.alpha != 0,
                  let image = sprite.image(for: layer),
                  image.width * image.height > 1 else {
                return nil
            }

            let texture = partTextures.texture(
                for: layer,
                resource: sprite,
                label: "item-\(objectID)-\(layerIndex)"
            )
            guard let texture else {
                return nil
            }

            return SpriteLayerDrawable(
                objectID: objectID,
                vertices: makeVertices(
                    layer: layer,
                    parentOffset: .zero,
                    partScale: 1,
                    width: image.width,
                    height: image.height,
                    opacity: 1
                ),
                texture: texture,
                worldPosition: worldPosition + [0, 0, 0.2], // Lifted slightly so uneven ground doesn't clip the sprite.
                isVisible: true
            )
        }
    }

    private func makeVertices(
        layer: ACT.Layer,
        parentOffset: SIMD2<Int32>,
        partScale: Float,
        width: Int,
        height: Int,
        opacity: Float
    ) -> [SpriteVertex] {
        let cx = Float(layer.offset.x + parentOffset.x) * partScale
        let cy = Float(layer.offset.y + parentOffset.y) * partScale
        let halfWidth = Float(width) * layer.scale.x * partScale / 2
        let halfHeight = Float(height) * layer.scale.y * partScale / 2
        let mirrorX: Float = (layer.isMirrored == 0 ? 1 : -1)
        let angle = Float(layer.rotationAngle) * .pi / 180
        let cosAngle = cos(angle)
        let sinAngle = sin(angle)

        func point(_ x: Float, _ y: Float) -> SIMD2<Float> {
            [
                x * cosAngle - y * sinAngle + cx,
                -(x * sinAngle + y * cosAngle + cy),
            ]
        }

        let color = SIMD4<Float>(
            Float(layer.color.red) / 255,
            Float(layer.color.green) / 255,
            Float(layer.color.blue) / 255,
            Float(layer.color.alpha) / 255 * opacity
        )

        let topLeft = point(-halfWidth * mirrorX, -halfHeight)
        let topRight = point(halfWidth * mirrorX, -halfHeight)
        let bottomLeft = point(-halfWidth * mirrorX, halfHeight)
        let bottomRight = point(halfWidth * mirrorX, halfHeight)

        return [
            SpriteVertex(position: topLeft, textureCoordinate: [0, 0], color: color),
            SpriteVertex(position: topRight, textureCoordinate: [1, 0], color: color),
            SpriteVertex(position: bottomLeft, textureCoordinate: [0, 1], color: color),
            SpriteVertex(position: topRight, textureCoordinate: [1, 0], color: color),
            SpriteVertex(position: bottomRight, textureCoordinate: [1, 1], color: color),
            SpriteVertex(position: bottomLeft, textureCoordinate: [0, 1], color: color),
        ]
    }
}
