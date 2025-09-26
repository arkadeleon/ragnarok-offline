//
//  SpriteRenderer.swift
//  SpriteRendering
//
//  Created by Leon Li on 2025/2/17.
//

import CoreGraphics
import Foundation
import ImageRendering
import ResourceManagement

final public class SpriteRenderer: Sendable {
    public let scale: CGFloat

    public init(scale: CGFloat = 2) {
        self.scale = scale
    }

    public struct Animation: Sendable {
        public let frames: [CGImage?]
        public let frameWidth: CGFloat
        public let frameHeight: CGFloat
        public let frameInterval: CGFloat
        public let scale: CGFloat

        /// The pivot point represents the offset to the center point.
        public let pivot: CGPoint
    }

    // MARK: - Render Sprite

    public func render(sprite: SpriteResource, actionIndex: Int) async -> SpriteRenderer.Animation {
        let actionNode = SpriteRenderNode(
            actionNodeWithSprite: sprite,
            actionIndex: actionIndex,
            scale: scale
        )

        let (frames, bounds) = render(actionNode: actionNode)

        let frameWidth = bounds.size.width / scale
        let frameHeight = bounds.size.height / scale

        let frameInterval: CGFloat
        if let action = sprite.act.action(at: actionIndex) {
            frameInterval = CGFloat(action.animationSpeed) * 25 / 1000
        } else {
            frameInterval = 1 / 12
        }

        let pivotX = (0 - bounds.midX) / scale
        let pivotY = (0 - bounds.midY) / scale
        let pivot = CGPoint(x: pivotX, y: pivotY)

        let animation = SpriteRenderer.Animation(
            frames: frames,
            frameWidth: frameWidth,
            frameHeight: frameHeight,
            frameInterval: frameInterval,
            scale: scale,
            pivot: pivot
        )
        return animation
    }

    private func render(actionNode: SpriteRenderNode) -> (frames: [CGImage?], bounds: CGRect) {
        let bounds = actionNode.bounds
        let frameCount = actionNode.children.count

        var frames: [CGImage?] = []

        for frameIndex in 0..<frameCount {
            let renderer = CGImageRenderer(size: bounds.size, flipped: true)
            let image = renderer.image { cgContext in
                let frameNode = actionNode.children[frameIndex]
                render(frameNode: frameNode, bounds: bounds, in: cgContext)
            }
            frames.append(image)
        }

        return (frames, bounds)
    }

    // MARK: - Render Composed Sprite

    public func render(
        composedSprite: ComposedSprite,
        actionType: CharacterActionType,
        direction: CharacterDirection,
        headDirection: CharacterHeadDirection
    ) async -> SpriteRenderer.Animation {
        let actionIndex = actionType.calculateActionIndex(
            forJobID: composedSprite.configuration.job.rawValue,
            direction: direction
        )

        var actionNodes: [(SpriteRenderNode, ComposedSprite.Part)] = []

        for part in composedSprite.parts {
            let actionIndex = (part.semantic == .shadow ? 0 : actionIndex)
            let scale = self.scale * part.sprite.scaleFactor

            let actionNode = SpriteRenderNode(
                actionNodeWithPart: part,
                actionType: actionType,
                actionIndex: actionIndex,
                headDirection: headDirection,
                scale: scale
            )
            actionNodes.append((actionNode, part))
        }

        let (frames, bounds) = await render(
            composedSprite: composedSprite,
            actionIndex: actionIndex,
            actionNodes: actionNodes,
            direction: direction
        )

        let frameWidth = bounds.size.width / scale
        let frameHeight = bounds.size.height / scale

        let frameInterval: CGFloat
        if let mainPart = composedSprite.mainPart,
           let action = mainPart.sprite.act.action(at: actionIndex) {
            frameInterval = CGFloat(action.animationSpeed) * 25 / 1000
        } else {
            frameInterval = 1 / 12
        }

        let pivotX = (0 - bounds.midX) / scale
        let pivotY = (0 - bounds.midY) / scale
        let pivot = CGPoint(x: pivotX, y: pivotY)

        let animation = SpriteRenderer.Animation(
            frames: frames,
            frameWidth: frameWidth,
            frameHeight: frameHeight,
            frameInterval: frameInterval,
            scale: scale,
            pivot: pivot
        )
        return animation
    }

    private func render(
        composedSprite: ComposedSprite,
        actionIndex: Int,
        actionNodes: [(SpriteRenderNode, ComposedSprite.Part)],
        direction: CharacterDirection
    ) async -> (frames: [CGImage?], bounds: CGRect) {
        var bounds: CGRect = .null
        var frameCount = 0

        for actionNode in actionNodes {
            bounds = bounds.union(actionNode.0.bounds)
            frameCount = max(frameCount, actionNode.0.children.count)
        }

        let scriptContext = await composedSprite.resourceManager.scriptContext()

        var frames: [CGImage?] = []

        for frameIndex in 0..<frameCount {
            // Sort action nodes.
            var sortedActionNodes: [(SpriteRenderNode, zIndex: Int)] = []
            for (actionNode, part) in actionNodes {
                let zIndex = zIndex(
                    forComposedSprite: composedSprite,
                    part: part,
                    direction: direction,
                    actionIndex: actionIndex,
                    frameIndex: frameIndex,
                    scriptContext: scriptContext
                )
                sortedActionNodes.append((actionNode, zIndex))
            }
            sortedActionNodes.sort {
                $0.zIndex < $1.zIndex
            }

            let renderer = CGImageRenderer(size: bounds.size, flipped: true)
            let image = renderer.image { cgContext in
                for (actionNode, _) in sortedActionNodes {
                    let frameIndex = frameIndex % actionNode.children.count
                    let frameNode = actionNode.children[frameIndex]
                    render(frameNode: frameNode, bounds: bounds, in: cgContext)
                }
            }
            frames.append(image)
        }

        return (frames, bounds)
    }

    private func zIndex(
        forComposedSprite composedSprite: ComposedSprite,
        part: ComposedSprite.Part,
        direction: CharacterDirection,
        actionIndex: Int,
        frameIndex: Int,
        scriptContext: ScriptContext
    ) -> Int {
        if part.semantic == .shadow {
            return -1
        }

        let configuration = composedSprite.configuration
        let imf = composedSprite.imf

        let isNorth = switch direction {
        case .west, .northwest, .north, .northeast: true
        case .south, .southwest, .east, .southeast: false
        }

        let zIndexForGarment: () -> Int = {
            let drawOnTop = scriptContext.drawOnTop(
                forRobeID: configuration.garment,
                genderID: configuration.gender.rawValue,
                jobID: configuration.job.rawValue,
                actionIndex: actionIndex,
                frameIndex: frameIndex
            )
            if drawOnTop {
                let isTopLayer = scriptContext.isTopLayer(forRobeID: configuration.garment)
                if isTopLayer {
                    return 25
                } else {
                    return isNorth ? 16 : 11
                }
            } else {
                return 5
            }
        }

        if isNorth {
            switch part.semantic {
            case .playerBody:
                return 15
            case .playerHead:
                if let imf, let priority = imf.priority(at: [1, actionIndex, frameIndex]), priority == 1 {
                    return 14
                } else {
                    return 20
                }
            case .weapon:
                return 30 - (2 - part.orderBySemantic)
            case .shield:
                return 10
            case .headgear:
                return 25 - (3 - part.orderBySemantic)
            case .garment:
                return zIndexForGarment()
            default:
                return 0
            }
        } else {
            switch part.semantic {
            case .playerBody:
                return 10
            case .playerHead:
                if let imf, let priority = imf.priority(at: [1, actionIndex, frameIndex]), priority == 1 {
                    return 9
                } else {
                    return 15
                }
            case .weapon:
                return 25 - (2 - part.orderBySemantic)
            case .shield:
                return 30
            case .headgear:
                return 20 - (3 - part.orderBySemantic)
            case .garment:
                return zIndexForGarment()
            default:
                return 0
            }
        }
    }

    // MARK: - Render Frame Node

    private func render(frameNode: SpriteRenderNode, bounds: CGRect, in cgContext: CGContext) {
        for layerNode in frameNode.children {
            guard var layerImage = layerNode.image else {
                continue
            }

            if let color = layerNode.color {
                layerImage = layerImage.applyingColor(color) ?? layerImage
            }

            cgContext.saveGState()
            cgContext.translateBy(x: -bounds.origin.x, y: -bounds.origin.y)
            cgContext.concatenate(layerNode.transform)
            cgContext.scaleBy(x: 1, y: -1)
            cgContext.draw(layerImage, in: layerNode.frame)
//            cgContext.setStrokeColor(CGColor(gray: 0, alpha: 1))
//            cgContext.stroke(layerNode.frame)
            cgContext.restoreGState()
        }
    }
}
