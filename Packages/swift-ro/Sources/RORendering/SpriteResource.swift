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
    case accessory
    case costume
    case garment
    case homunculus
    case mercenary
    case monster
    case npc
    case playerBody
    case playerHead
    case shadow
    case shield
    case standard
    case weapon
}

public class SpriteResource {
    let act: ACT
    let spr: SPR

    var parent: SpriteResource?

    var semantic: SpriteSemantic = .standard
    var orderBySemantic = 0

    var scale: Float = 1

    lazy var imagesBySpriteType: [SPR.SpriteType : [CGImage?]] = {
        spr.imagesBySpriteType()
    }()

    init(act: ACT, spr: SPR) {
        self.act = act
        self.spr = spr
    }
}

extension SpriteResource {
    struct RenderNode {
        static let null = RenderNode()

        var image: CGImage?
        var color: RGBAColor?
        var frame: CGRect
        var bounds: CGRect
        var transform: CGAffineTransform
        var children: [RenderNode]

        init() {
            frame = .null
            bounds = .null
            transform = .identity
            children = []
        }
    }

    func actionNode(actionIndex: Int, headDirection: HeadDirection) -> RenderNode {
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
            case .playerHead, .accessory:
                let frameCount = action.frames.count / 3
                startFrameIndex = headDirection.rawValue * frameCount
                endFrameIndex = startFrameIndex + frameCount
            default:
                break
            }
        }

        var actionNode = RenderNode()

        for frameIndex in startFrameIndex..<endFrameIndex {
            let frameNode = frameNode(actionIndex: actionIndex, frameIndex: frameIndex)
            actionNode.children.append(frameNode)
            actionNode.bounds = actionNode.bounds.union(frameNode.bounds)
        }

        return actionNode
    }

    func frameNode(actionIndex: Int, frameIndex: Int) -> RenderNode {
        guard let action = action(at: actionIndex),
              let frame = frame(at: [actionIndex, frameIndex]) else {
            return .null
        }

        var parentOffset: SIMD2<Int32> = .zero

        if let parent {
            var parentFrameIndex = frameIndex

            if semantic == .accessory,
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
            let layerNode = layerNode(layer: layer, parentOffset: parentOffset)
            frameNode.children.append(layerNode)
            frameNode.bounds = frameNode.bounds.union(layerNode.bounds)
        }

        return frameNode
    }

    func layerNode(layer: ACT.Layer, parentOffset: SIMD2<Int32>) -> RenderNode {
        guard let image = image(for: layer) else {
            return .null
        }

        var layerNode = RenderNode()
        layerNode.image = image
        layerNode.color = layer.color

        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        let frame = CGRect(x: -width, y: -height, width: width * 2, height: height * 2)
        layerNode.frame = frame

        var transform = CGAffineTransformIdentity
        transform = CGAffineTransformTranslate(
            transform,
            CGFloat(layer.offset.x + parentOffset.x) * 2,
            CGFloat(layer.offset.y + parentOffset.y) * 2
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
