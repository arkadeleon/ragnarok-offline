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

struct SpriteLayerDrawable {
    let objectID: GameObjectID
    var vertices: [SpriteVertex]
    var texture: any MTLTexture
    var worldPosition: SIMD3<Float>
    var isVisible: Bool
}

@MainActor
struct SpriteFrameResolver {
    struct ResolveInput {
        let objectID: GameObjectID
        let composedSprite: ComposedSprite
        var animation: MapObjectAnimationState
        let partTextures: SpritePartTextures
        let scriptContext: ScriptContext
        let worldPosition: SIMD3<Float>
        let isVisible: Bool
    }

    private struct ResolvedLayer {
        let zIndex: Int
        let order: Int
        let vertices: [SpriteVertex]
        let texture: any MTLTexture
    }

    func resolve(_ input: ResolveInput) -> [SpriteLayerDrawable] {
        if case .once(let settledAction) = input.animation.completion,
           let duration = onceDuration(for: input),
           input.animation.action != settledAction,
           input.animation.elapsed >= duration {
            var settledInput = input
            settledInput.animation.action = settledAction
            settledInput.animation.elapsed = input.animation.elapsed - duration
            settledInput.animation.completion = .indefinite
            return resolve(settledInput)
        }

        let actionIndex = input.animation.action.calculateActionIndex(
            forJobID: input.composedSprite.configuration.job.rawValue,
            direction: input.animation.direction
        )

        var resolvedLayers: [ResolvedLayer] = []
        resolvedLayers.reserveCapacity(24)

        for (partIndex, part) in input.composedSprite.parts.enumerated() {
            let partActionIndex = (part.semantic == .shadow ? 0 : actionIndex)
            guard let action = part.sprite.act.action(at: partActionIndex), !action.frames.isEmpty else {
                continue
            }

            let frameRange = part.frameRange(
                action: action,
                actionType: input.animation.action,
                headDirection: input.animation.headDirection
            )
            guard !frameRange.isEmpty else {
                continue
            }

            let frameInterval = TimeInterval(action.frameInterval)
            let rawFrameIndex = Int(input.animation.elapsed.timeInterval / frameInterval)
            let localFrameIndex: Int
            if actionRepeats(input.animation.action) {
                localFrameIndex = rawFrameIndex % frameRange.count
            } else {
                localFrameIndex = min(rawFrameIndex, frameRange.count - 1)
            }
            let absoluteFrameIndex = frameRange.lowerBound + localFrameIndex

            guard let frame = part.sprite.act.frame(at: [partActionIndex, absoluteFrameIndex]) else {
                continue
            }

            let zIndex = input.composedSprite.zIndex(
                for: part,
                direction: input.animation.direction,
                actionIndex: actionIndex,
                frameIndex: absoluteFrameIndex,
                scriptContext: input.scriptContext
            )
            let parentOffset = part.parentOffset(
                actionType: input.animation.action,
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

                guard let texture = input.partTextures.texture(
                    for: layer,
                    resource: part.sprite,
                    label: "sprite-\(input.objectID)-\(partIndex)-\(layerIndex)"
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
                objectID: input.objectID,
                vertices: $0.vertices,
                texture: $0.texture,
                worldPosition: input.worldPosition,
                isVisible: input.isVisible
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

    private func onceDuration(for input: ResolveInput) -> Duration? {
        let actionIndex = input.animation.action.calculateActionIndex(
            forJobID: input.composedSprite.configuration.job.rawValue,
            direction: input.animation.direction
        )

        var duration: Duration?
        for part in input.composedSprite.parts {
            let partActionIndex = (part.semantic == .shadow ? 0 : actionIndex)
            guard let action = part.sprite.act.action(at: partActionIndex), !action.frames.isEmpty else {
                continue
            }

            let frameRange = part.frameRange(
                action: action,
                actionType: input.animation.action,
                headDirection: input.animation.headDirection
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
