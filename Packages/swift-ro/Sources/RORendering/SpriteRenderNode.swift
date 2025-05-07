//
//  SpriteRenderNode.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/6.
//

import CoreGraphics
import ROCore
import ROFileFormats

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
        guard let action = sprite.action(at: actionIndex) else {
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

    init(actionNodeWithPart part: ComposedSprite.Part, actionIndex: Int, headDirection: ComposedSprite.HeadDirection, scale: CGFloat) {
        guard let action = part.sprite.action(at: actionIndex) else {
            self = .null
            return
        }

        var startFrameIndex = action.frames.startIndex
        var endFrameIndex = action.frames.endIndex

        if let actionType = ComposedSprite.ActionType(forPlayerActionIndex: actionIndex),
           actionType == .idle || actionType == .sit {
            switch part.semantic {
            case .playerBody:
                startFrameIndex = headDirection.rawValue
                endFrameIndex = startFrameIndex + 1
            case .playerHead, .headgear:
                let frameCount = action.frames.count / 3
                startFrameIndex = headDirection.rawValue * frameCount
                endFrameIndex = startFrameIndex + frameCount
            default:
                break
            }
        }

        var bounds: CGRect = .null
        var children: [SpriteRenderNode] = []

        for frameIndex in startFrameIndex..<endFrameIndex {
            let frameNode = SpriteRenderNode(frameNodeWithPart: part, actionIndex: actionIndex, frameIndex: frameIndex, scale: scale)
            children.append(frameNode)
            bounds = bounds.union(frameNode.bounds)
        }

        self = SpriteRenderNode(bounds: bounds, children: children)
    }

    init(frameNodeWithPart part: ComposedSprite.Part, actionIndex: Int, frameIndex: Int, scale: CGFloat) {
        guard let action = part.sprite.action(at: actionIndex),
              let frame = part.sprite.frame(at: [actionIndex, frameIndex]) else {
            self = .null
            return
        }

        var parentOffset: SIMD2<Int32> = .zero

        if let parent = part.sprite.parent {
            var parentFrameIndex = frameIndex

            if part.semantic == .headgear,
               let actionType = ComposedSprite.ActionType(forPlayerActionIndex: actionIndex),
               actionType == .idle || actionType == .sit {
                let frameCount = action.frames.count / 3
                parentFrameIndex = frameIndex / frameCount
            }

            if let parentFrame = parent.frame(at: [actionIndex, parentFrameIndex]),
               let parentAnchorPoint = parentFrame.anchorPoints.first {
                parentOffset = [parentAnchorPoint.x, parentAnchorPoint.y]
            }

            if let anchorPoint = frame.anchorPoints.first {
                parentOffset &-= [anchorPoint.x, anchorPoint.y]
            }
        }

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
        guard let image = sprite.image(for: layer) else {
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
