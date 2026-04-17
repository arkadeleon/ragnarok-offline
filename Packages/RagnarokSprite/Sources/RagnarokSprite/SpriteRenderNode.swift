//
//  SpriteRenderNode.swift
//  RagnarokSprite
//
//  Created by Leon Li on 2025/3/6.
//

import CoreGraphics
import RagnarokFileFormats

struct SpriteRenderNode {
    static let null = SpriteRenderNode()

    var image: CGImage?
    var scale: CGFloat = 1
    var color: RGBAColor?
    var frame: CGRect = .null
    var bounds: CGRect = .null
    var transform: CGAffineTransform = .identity
    var children: [SpriteRenderNode] = []
}

extension SpriteRenderNode {
    init(actionNodeWithSprite sprite: SpriteResource, actionIndex: Int, scale: CGFloat) {
        guard let action = sprite.act.action(at: actionIndex) else {
            self = .null
            return
        }

        var bounds: CGRect = .null
        var children: [SpriteRenderNode] = []

        for frame in action.frames {
            let frameNode = SpriteRenderNode(frameNodeWithSprite: sprite, frame: frame, scale: scale)
            children.append(frameNode)
            bounds = bounds.union(frameNode.bounds)
        }

        self = SpriteRenderNode(bounds: bounds, children: children)
    }

    init(frameNodeWithSprite sprite: SpriteResource, frame: ACT.Frame, scale: CGFloat) {
        var bounds: CGRect = .null
        var children: [SpriteRenderNode] = []

        for layer in frame.layers {
            let layerNode = SpriteRenderNode(layerNodeWithSprite: sprite, layer: layer, parentOffset: .zero, scale: scale)
            children.append(layerNode)
            bounds = bounds.union(layerNode.bounds)
        }

        self = SpriteRenderNode(bounds: bounds, children: children)
    }

    init(actionNodeWithPart part: ComposedSprite.Part, actionType: SpriteActionType, actionIndex: Int, headDirection: SpriteHeadDirection, scale: CGFloat) {
        guard let action = part.sprite.act.action(at: actionIndex) else {
            self = .null
            return
        }

        let frameRange = part.frameRange(action: action, actionType: actionType, headDirection: headDirection)

        var bounds: CGRect = .null
        var children: [SpriteRenderNode] = []

        for frameIndex in frameRange {
            let frameNode = SpriteRenderNode(frameNodeWithPart: part, actionType: actionType, actionIndex: actionIndex, frameIndex: frameIndex, scale: scale)
            children.append(frameNode)
            bounds = bounds.union(frameNode.bounds)
        }

        self = SpriteRenderNode(bounds: bounds, children: children)
    }

    init(frameNodeWithPart part: ComposedSprite.Part, actionType: SpriteActionType, actionIndex: Int, frameIndex: Int, scale: CGFloat) {
        guard let action = part.sprite.act.action(at: actionIndex),
              let frame = part.sprite.act.frame(at: [actionIndex, frameIndex]) else {
            self = .null
            return
        }

        let parentOffset = part.parentOffset(
            actionType: actionType,
            action: action,
            actionIndex: actionIndex,
            absoluteFrameIndex: frameIndex,
            frame: frame
        )

        var bounds: CGRect = .null
        var children: [SpriteRenderNode] = []

        for layer in frame.layers {
            let layerNode = SpriteRenderNode(layerNodeWithSprite: part.sprite, layer: layer, parentOffset: parentOffset, scale: scale)
            children.append(layerNode)
            bounds = bounds.union(layerNode.bounds)
        }

        self = SpriteRenderNode(bounds: bounds, children: children)
    }

    init(layerNodeWithSprite sprite: SpriteResource, layer: ACT.Layer, parentOffset: SIMD2<Int32>, scale: CGFloat) {
        guard layer.color.alpha != 0 else {
            self = .null
            return
        }

        guard let image = sprite.image(for: layer), image.width * image.height > 1 else {
            self = .null
            return
        }

        let width = CGFloat(image.width) * scale
        let height = CGFloat(image.height) * scale
        let frame = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)

        var transform = CGAffineTransformIdentity
        transform = CGAffineTransformTranslate(
            transform,
            CGFloat(layer.offset.x + parentOffset.x) * scale,
            CGFloat(layer.offset.y + parentOffset.y) * scale
        )
        transform = CGAffineTransformRotate(transform, CGFloat(layer.rotationAngle) / 180 * .pi)
        if layer.isMirrored == 0 {
            transform = CGAffineTransformScale(transform, CGFloat(layer.scale.x), CGFloat(layer.scale.y))
        } else {
            transform = CGAffineTransformScale(transform, -CGFloat(layer.scale.x), CGFloat(layer.scale.y))
        }

        let bounds = frame.applying(transform)

        self = SpriteRenderNode(image: image, scale: scale, color: layer.color, frame: frame, bounds: bounds, transform: transform)
    }
}
