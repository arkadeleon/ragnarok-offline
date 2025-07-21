//
//  SpriteRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/17.
//

import CoreGraphics
import Foundation
import ROCore
import ROResources

final public class SpriteRenderer: Sendable {
    public let scale: CGFloat

    public init(scale: CGFloat = 2) {
        self.scale = scale
    }

    // MARK: - Render Sprite

    public func render(sprite: SpriteResource, actionIndex: Int) async -> AnimatedImage {
        let actionNode = SpriteRenderNode(
            actionNodeWithSprite: sprite,
            actionIndex: actionIndex,
            scale: scale
        )

        let (frames, frameWidth, frameHeight) = render(actionNode: actionNode)

        let frameInterval: CGFloat
        if let action = sprite.act.action(at: actionIndex) {
            frameInterval = CGFloat(action.animationSpeed) * 25 / 1000
        } else {
            frameInterval = 1 / 12
        }

        let animatedImage = AnimatedImage(
            frames: frames,
            frameWidth: frameWidth,
            frameHeight: frameHeight,
            frameInterval: frameInterval,
            frameScale: scale
        )
        return animatedImage
    }

    private func render(actionNode: SpriteRenderNode) -> (frames: [CGImage?], frameWidth: CGFloat, frameHeight: CGFloat) {
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

        let frameWidth = bounds.size.width / scale
        let frameHeight = bounds.size.height / scale

        return (frames, frameWidth, frameHeight)
    }

    // MARK: - Render Composed Sprite

    public func render(
        composedSprite: ComposedSprite,
        actionType: ComposedSprite.ActionType,
        direction: ComposedSprite.Direction,
        headDirection: ComposedSprite.HeadDirection
    ) async -> AnimatedImage {
        let actionIndex = actionType.calculateActionIndex(forJobID: composedSprite.configuration.job.rawValue, direction: direction)

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

        let (frames, frameWidth, frameHeight) = await render(
            composedSprite: composedSprite,
            actionIndex: actionIndex,
            actionNodes: actionNodes,
            direction: direction
        )

        let frameInterval: CGFloat
        if let mainPart = composedSprite.mainPart,
           let action = mainPart.sprite.act.action(at: actionIndex) {
            frameInterval = CGFloat(action.animationSpeed) * 25 / 1000
        } else {
            frameInterval = 1 / 12
        }

        let animatedImage = AnimatedImage(
            frames: frames,
            frameWidth: frameWidth,
            frameHeight: frameHeight,
            frameInterval: frameInterval,
            frameScale: scale
        )
        return animatedImage
    }

    private func render(
        composedSprite: ComposedSprite,
        actionIndex: Int,
        actionNodes: [(SpriteRenderNode, ComposedSprite.Part)],
        direction: ComposedSprite.Direction
    ) async -> (frames: [CGImage?], frameWidth: CGFloat, frameHeight: CGFloat) {
        var bounds: CGRect = .null
        var frameCount = 0

        for actionNode in actionNodes {
            bounds = bounds.union(actionNode.0.bounds)
            frameCount = max(frameCount, actionNode.0.children.count)
        }

        var frames: [CGImage?] = []

        for frameIndex in 0..<frameCount {
            // Sort action nodes.
            var sortedActionNodes: [(SpriteRenderNode, zIndex: Int)] = []
            for (actionNode, part) in actionNodes {
                let zIndex = await zIndex(
                    forComposedSprite: composedSprite,
                    part: part,
                    direction: direction,
                    actionIndex: actionIndex,
                    frameIndex: frameIndex
                )
                logger.info("action: \(actionIndex), frame: \(frameIndex), part: \(String(describing: part.semantic)), zIndex: \(zIndex)")
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

        let frameWidth = bounds.size.width / scale
        let frameHeight = bounds.size.height / scale

        return (frames, frameWidth, frameHeight)
    }

    private func zIndex(
        forComposedSprite composedSprite: ComposedSprite,
        part: ComposedSprite.Part,
        direction: ComposedSprite.Direction,
        actionIndex: Int,
        frameIndex: Int
    ) async -> Int {
        if part.semantic == .shadow {
            return -1
        }

        let configuration = composedSprite.configuration
        let scriptContext = await composedSprite.resourceManager.scriptContext(for: .current)
        let imf = composedSprite.imf

        let isNorth = switch direction {
        case .west, .northwest, .north, .northeast: true
        case .south, .southwest, .east, .southeast: false
        }

        let zIndexForGarment: () async -> Int = {
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
                return await zIndexForGarment()
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
                return await zIndexForGarment()
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
            #if DEBUG
            cgContext.setStrokeColor(CGColor(gray: 0, alpha: 1))
            cgContext.stroke(layerNode.frame)
            #endif
            cgContext.restoreGState()
        }
    }
}
