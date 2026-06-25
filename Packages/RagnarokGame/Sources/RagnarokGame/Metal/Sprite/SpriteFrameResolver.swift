//
//  SpriteFrameResolver.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/13.
//

import Foundation
import Metal
import RagnarokFileFormats
import RagnarokModels
import RagnarokResources
import RagnarokShaders
import RagnarokSprite
import simd

@MainActor
struct SpriteFrameResolver {
    private struct ResolvedLayer {
        let zIndex: Int
        let order: Int
        let vertices: [SpriteVertex]
        let texture: any MTLTexture
    }

    func resolve(
        _ object: MetalMapObject,
        camera: MapCameraState
    ) -> [SpriteLayerDrawable] {
        guard let composedSprite = object.composedSprite,
              let partTextures = object.partTextures else {
            return []
        }

        var animation = animation(for: object, camera: camera)
        if case .once(let settledAction) = animation.completion,
           let duration = onceDuration(composedSprite: composedSprite, animation: animation),
           animation.action != settledAction,
           animation.elapsedTime >= duration {
            animation.action = settledAction
            animation.elapsedTime -= duration
            animation.completion = .indefinite
        }

        let actionIndex = animation.action.calculateActionIndex(
            forJobID: composedSprite.configuration.job.rawValue,
            direction: animation.direction
        )

        var resolvedLayers: [ResolvedLayer] = []
        resolvedLayers.reserveCapacity(24)

        for (partIndex, part) in composedSprite.parts.enumerated() {
            let partActionIndex = (part.semantic == .shadow ? 0 : actionIndex)
            guard let action = part.sprite.act.action(at: partActionIndex), !action.frames.isEmpty else {
                continue
            }

            let frameRange = part.frameRange(
                action: action,
                actionType: animation.action,
                headDirection: animation.headDirection
            )
            guard !frameRange.isEmpty else {
                continue
            }

            let frameInterval = TimeInterval(action.frameInterval)
            let rawFrameIndex = Int(animation.elapsedTime.timeInterval / frameInterval)
            let localFrameIndex: Int
            if actionRepeats(animation.action) {
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
                direction: animation.direction,
                actionIndex: actionIndex,
                frameIndex: absoluteFrameIndex
            )
            let parentOffset = part.parentOffset(
                actionType: animation.action,
                action: action,
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
                    height: image.height
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
                worldPosition: object.worldPosition,
                isVisible: object.effectState != .cloak
            )
        }
    }

    func resolve(_ item: MetalMapItem) -> [SpriteLayerDrawable] {
        guard let sprite = item.sprite,
              let partTextures = item.partTextures,
              let action = sprite.act.action(at: 0),
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
                label: "item-\(item.objectID)-\(layerIndex)"
            )
            guard let texture else {
                return nil
            }

            return SpriteLayerDrawable(
                objectID: item.objectID,
                vertices: makeVertices(
                    layer: layer,
                    parentOffset: .zero,
                    partScale: 1,
                    width: image.width,
                    height: image.height
                ),
                texture: texture,
                worldPosition: item.worldPosition,
                isVisible: true
            )
        }
    }

    private func makeVertices(
        layer: ACT.Layer,
        parentOffset: SIMD2<Int32>,
        partScale: Float,
        width: Int,
        height: Int
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
            Float(layer.color.alpha) / 255
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

    private func actionRepeats(_ action: SpriteActionType) -> Bool {
        switch action {
        case .idle, .walk, .sit, .readyToAttack, .freeze, .freeze2:
            true
        case .pickup, .attack1, .hurt, .die, .attack2, .attack3, .skill:
            false
        }
    }

    private func animation(for object: MetalMapObject, camera: MapCameraState) -> MetalAnimation {
        let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: object.job)

        var animation = object.animation
        if let movement = object.movement, movement.isMoving {
            animation.action = .walk
            animation.direction = movement.direction ?? animation.direction
            animation.elapsedTime = movement.animationElapsedTime
            animation.completion = .indefinite
        }
        animation.direction = animation.direction.adjustedForCameraAzimuth(camera.azimuth)
        if !availableActionTypes.contains(animation.action) {
            animation.action = .idle
        }

        return animation
    }

    private func onceDuration(
        composedSprite: ComposedSprite,
        animation: MetalAnimation
    ) -> Duration? {
        let actionIndex = animation.action.calculateActionIndex(
            forJobID: composedSprite.configuration.job.rawValue,
            direction: animation.direction
        )

        var duration: Duration?
        for part in composedSprite.parts {
            let partActionIndex = (part.semantic == .shadow ? 0 : actionIndex)
            guard let action = part.sprite.act.action(at: partActionIndex), !action.frames.isEmpty else {
                continue
            }

            let frameRange = part.frameRange(
                action: action,
                actionType: animation.action,
                headDirection: animation.headDirection
            )
            guard !frameRange.isEmpty else {
                continue
            }

            let partDuration: Duration = .seconds(Double(action.frameInterval) * Double(frameRange.count))
            duration = max(duration ?? .zero, partDuration)
        }

        return duration
    }
}
