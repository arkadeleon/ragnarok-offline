//
//  SpriteResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import CoreGraphics
import Foundation
import ROFileFormats

enum SpriteSemantic {
    case standard
    case playerBody
    case costume
    case playerHead
    case headgear
    case garment
    case weapon
    case shield
    case npc
    case monster
    case homunculus
    case mercenary
    case shadow
}

final public class SpriteResource: @unchecked Sendable {
    let act: ACT
    let spr: SPR

    var parent: SpriteResource?

    var semantic: SpriteSemantic = .standard
    var orderBySemantic = 0

    var palette: PaletteResource?

    var scale: Float = 1

    lazy var imagesBySpriteType: [SPR.SpriteType : [CGImage?]] = {
        spr.imagesBySpriteType(palette: palette?.pal)
    }()

    init(act: ACT, spr: SPR) {
        self.act = act
        self.spr = spr
    }
}

extension SpriteResource {
    struct RenderNode: Sendable {
        static let null = RenderNode()

        var image: CGImage?
        var scale: CGFloat
        var color: RGBAColor?
        var frame: CGRect
        var bounds: CGRect
        var transform: CGAffineTransform
        var children: [RenderNode]

        init() {
            scale = 1
            frame = .null
            bounds = .null
            transform = .identity
            children = []
        }
    }

    func actionNode(actionIndex: Int, headDirection: HeadDirection, scale: CGFloat) -> RenderNode {
        guard let action = action(at: actionIndex) else {
            return .null
        }

        var startFrameIndex = action.frames.startIndex
        var endFrameIndex = action.frames.endIndex

        if let actionType = PlayerActionType(rawValue: actionIndex / 8),
           actionType == .idle || actionType == .sit {
            switch semantic {
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

        var actionNode = RenderNode()

        for frameIndex in startFrameIndex..<endFrameIndex {
            let frameNode = frameNode(actionIndex: actionIndex, frameIndex: frameIndex, scale: scale)
            actionNode.children.append(frameNode)
            actionNode.bounds = actionNode.bounds.union(frameNode.bounds)
        }

        return actionNode
    }

    func frameNode(actionIndex: Int, frameIndex: Int, scale: CGFloat) -> RenderNode {
        guard let action = action(at: actionIndex),
              let frame = frame(at: [actionIndex, frameIndex]) else {
            return .null
        }

        var parentOffset: SIMD2<Int32> = .zero

        if let parent {
            var parentFrameIndex = frameIndex

            if semantic == .headgear,
               let actionType = PlayerActionType(rawValue: actionIndex / 8),
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

        var frameNode = RenderNode()

        for layer in frame.layers {
            let layerNode = layerNode(layer: layer, parentOffset: parentOffset, scale: scale)
            frameNode.children.append(layerNode)
            frameNode.bounds = frameNode.bounds.union(layerNode.bounds)
        }

        return frameNode
    }

    func layerNode(layer: ACT.Layer, parentOffset: SIMD2<Int32>, scale: CGFloat) -> RenderNode {
        guard let image = image(for: layer) else {
            return .null
        }

        var layerNode = RenderNode()
        layerNode.image = image
        layerNode.scale = scale
        layerNode.color = layer.color

        let width = CGFloat(image.width) * scale
        let height = CGFloat(image.height) * scale
        let frame = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        layerNode.frame = frame

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
        layerNode.transform = transform

        layerNode.bounds = frame.applying(transform)

        return layerNode
    }

    private func action(at actionIndex: Int) -> ACT.Action? {
        guard 0..<act.actions.count ~= actionIndex else {
            return nil
        }

        let action = act.actions[actionIndex]
        return action
    }

    private func frame(at indexPath: IndexPath) -> ACT.Frame? {
        let actionIndex = indexPath[0]
        let frameIndex = indexPath[1]

        guard 0..<act.actions.count ~= actionIndex else {
            return nil
        }

        let action = act.actions[actionIndex]
        guard 0..<action.frames.count ~= frameIndex else {
            return nil
        }

        let frame = action.frames[frameIndex]
        return frame
    }

    private func image(for layer: ACT.Layer) -> CGImage? {
        guard let spriteType = SPR.SpriteType(rawValue: Int(layer.spriteType)),
              let spriteImages = imagesBySpriteType[spriteType] else {
            return nil
        }

        let spriteIndex = Int(layer.spriteIndex)
        guard 0..<spriteImages.count ~= spriteIndex,
              let image = spriteImages[spriteIndex] else {
            return nil
        }

        return image
    }
}
