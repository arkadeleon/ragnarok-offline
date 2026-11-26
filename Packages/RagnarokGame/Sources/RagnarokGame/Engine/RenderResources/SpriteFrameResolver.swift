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
        worldPosition: SIMD3<Float>,
        shadow: Float
    ) -> SpriteDrawable? {
        guard let resolvedAction = object.resolvedAction else {
            return nil
        }

        let modifiers = object.effectModifiers
        let directionStepOffset = Int((modifiers.effectiveFacingYawDegrees / 45).rounded())
        let effectiveDirection: SpriteDirection
        if directionStepOffset == 0 {
            effectiveDirection = resolvedAction.direction
        } else {
            let shiftedRawValue = ((resolvedAction.direction.rawValue + directionStepOffset) % 8 + 8) % 8
            effectiveDirection = SpriteDirection(rawValue: shiftedRawValue) ?? resolvedAction.direction
        }

        let actionIndex = resolvedAction.actionType.calculateActionIndex(
            forJobID: composedSprite.configuration.job.rawValue,
            direction: effectiveDirection
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
                direction: effectiveDirection,
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
                    opacity: object.opacity,
                    tintColor: modifiers.effectiveTintColor,
                    scale: modifiers.effectiveScale,
                    rotationZ: modifiers.effectiveSpriteRollRadians,
                    spriteOffset: modifiers.effectiveSpriteOffset
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

        guard !resolvedLayers.isEmpty else {
            return nil
        }

        let baseLayers = resolvedLayers.map {
            SpriteDrawable.Layer(vertices: $0.vertices, texture: $0.texture)
        }
        var finalLayers: [SpriteDrawable.Layer] = []

        if let outline = modifiers.effectiveOutline, outline.color.w > 0, outline.spread > 0 {
            let layerCount = max(outline.layers, 1)
            for step in stride(from: layerCount, through: 1, by: -1) {
                let stepSpread = outline.spread * Float(step) / Float(layerCount)
                let outlineColor = SIMD4<Float>(
                    outline.color.x,
                    outline.color.y,
                    outline.color.z,
                    outline.color.w * object.opacity
                )
                for baseLayer in baseLayers {
                    finalLayers.append(
                        makeExpandedLayer(
                            from: baseLayer,
                            spread: stepSpread,
                            color: outlineColor
                        )
                    )
                }
            }
        }

        finalLayers.append(contentsOf: baseLayers)

        if let fourWay = modifiers.effectiveFourWaySplit, fourWay.alpha > 0, fourWay.spread > 0 {
            let offsets: [SIMD2<Float>] = [
                [fourWay.spread, 0],
                [-fourWay.spread, 0],
                [0, fourWay.spread],
                [0, -fourWay.spread],
            ]
            for offset in offsets {
                for baseLayer in baseLayers {
                    finalLayers.append(
                        makeShiftedLayer(
                            from: baseLayer,
                            offset: offset,
                            alphaMultiplier: fourWay.alpha
                        )
                    )
                }
            }
        }

        return SpriteDrawable(
            objectID: object.objectID,
            worldPosition: worldPosition + modifiers.effectiveWorldOffset + [0, 0.2, 0], // Lifted slightly so uneven ground doesn't clip the sprite.
            shadow: shadow,
            isVisible: object.effectState != .cloak || modifiers.cloakingAlpha != nil,
            layers: finalLayers
        )
    }

    func resolve(
        objectID: GameObjectID,
        sprite: SpriteResource,
        partTextures: SpritePartTextures,
        worldPosition: SIMD3<Float>,
        shadow: Float
    ) -> SpriteDrawable? {
        guard let action = sprite.act.action(at: 0),
              let frame = action.frames.first else {
            return nil
        }

        let layers = frame.layers.enumerated().compactMap { layerIndex, layer -> SpriteDrawable.Layer? in
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

            return SpriteDrawable.Layer(
                vertices: makeVertices(
                    layer: layer,
                    parentOffset: .zero,
                    partScale: 1,
                    width: image.width,
                    height: image.height,
                    opacity: 1
                ),
                texture: texture
            )
        }

        guard !layers.isEmpty else {
            return nil
        }

        return SpriteDrawable(
            objectID: objectID,
            worldPosition: worldPosition + [0, 0.2, 0], // Lifted slightly so uneven ground doesn't clip the sprite.
            shadow: shadow,
            isVisible: true,
            layers: layers
        )
    }

    private func makeExpandedLayer(
        from layer: SpriteDrawable.Layer,
        spread: Float,
        color: SIMD4<Float>
    ) -> SpriteDrawable.Layer {
        guard !layer.vertices.isEmpty else {
            return layer
        }
        var minPos = layer.vertices[0].position
        var maxPos = layer.vertices[0].position
        for vertex in layer.vertices {
            minPos = simd_min(minPos, vertex.position)
            maxPos = simd_max(maxPos, vertex.position)
        }
        let center = (minPos + maxPos) * 0.5
        let expandedVertices = layer.vertices.map { vertex -> SpriteVertex in
            let delta = vertex.position - center
            let offset = SIMD2<Float>(
                delta.x >= 0 ? spread : -spread,
                delta.y >= 0 ? spread : -spread
            )
            return SpriteVertex(
                position: vertex.position + offset,
                textureCoordinate: vertex.textureCoordinate,
                color: SIMD4<Float>(color.x, color.y, color.z, vertex.color.w * color.w)
            )
        }
        return SpriteDrawable.Layer(vertices: expandedVertices, texture: layer.texture)
    }

    private func makeShiftedLayer(
        from layer: SpriteDrawable.Layer,
        offset: SIMD2<Float>,
        alphaMultiplier: Float
    ) -> SpriteDrawable.Layer {
        let shiftedVertices = layer.vertices.map { vertex in
            SpriteVertex(
                position: vertex.position + offset,
                textureCoordinate: vertex.textureCoordinate,
                color: SIMD4<Float>(vertex.color.x, vertex.color.y, vertex.color.z, vertex.color.w * alphaMultiplier)
            )
        }
        return SpriteDrawable.Layer(vertices: shiftedVertices, texture: layer.texture)
    }

    private func makeVertices(
        layer: ACT.Layer,
        parentOffset: SIMD2<Int32>,
        partScale: Float,
        width: Int,
        height: Int,
        opacity: Float,
        tintColor: SIMD3<Float> = .one,
        scale: SIMD2<Float> = .one,
        rotationZ: Float = 0,
        spriteOffset: SIMD2<Float> = .zero
    ) -> [SpriteVertex] {
        let cx = Float(layer.offset.x + parentOffset.x) * partScale * scale.x
        let cy = Float(layer.offset.y + parentOffset.y) * partScale * scale.y
        let halfWidth = Float(width) * layer.scale.x * partScale * scale.x / 2
        let halfHeight = Float(height) * layer.scale.y * partScale * scale.y / 2
        let mirrorX: Float = (layer.isMirrored == 0 ? 1 : -1)
        let angle = Float(layer.rotationAngle) * .pi / 180
        let cosAngle = cos(angle)
        let sinAngle = sin(angle)
        let cosExtra = cos(rotationZ)
        let sinExtra = sin(rotationZ)

        func point(_ x: Float, _ y: Float) -> SIMD2<Float> {
            let local = SIMD2<Float>(
                x * cosAngle - y * sinAngle + cx,
                -(x * sinAngle + y * cosAngle + cy)
            )
            let rotated: SIMD2<Float>
            if rotationZ == 0 {
                rotated = local
            } else {
                rotated = SIMD2<Float>(
                    local.x * cosExtra - local.y * sinExtra,
                    local.x * sinExtra + local.y * cosExtra
                )
            }
            return rotated + spriteOffset
        }

        let color = SIMD4<Float>(
            Float(layer.color.red) / 255 * tintColor.x,
            Float(layer.color.green) / 255 * tintColor.y,
            Float(layer.color.blue) / 255 * tintColor.z,
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
