//
//  SpriteRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/17.
//

import CoreGraphics
import ROCore

final public class SpriteRenderer: Sendable {
    public let scale: CGFloat

    public init(scale: CGFloat = 2) {
        self.scale = scale
    }

    public func render(sprite: SpriteResource, actionIndex: Int) async -> AnimatedImage {
        let actionNode = SpriteRenderNode(
            actionNodeWithSprite: sprite,
            actionIndex: actionIndex,
            scale: scale
        )

        let frames = render(actionNodes: [actionNode], bounds: actionNode.bounds, frameCount: actionNode.children.count)

        let frameWidth = actionNode.bounds.size.width / scale
        let frameHeight = actionNode.bounds.size.height / scale

        let frameInterval: CGFloat
        if let action = sprite.action(at: actionIndex) {
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

    public func render(composedSprite: ComposedSprite, actionIndex: Int, headDirection: HeadDirection) async -> AnimatedImage {
        var actionNodes: [SpriteRenderNode] = []
        var bounds: CGRect = .null
        var frameCount = 0

        for part in composedSprite.parts {
            let actionIndex = (part.semantic == .shadow ? 0 : actionIndex)
            let scale = self.scale * part.sprite.scaleFactor

            let actionNode = SpriteRenderNode(
                actionNodeWithPart: part,
                actionIndex: actionIndex,
                headDirection: headDirection,
                scale: scale
            )
            actionNodes.append(actionNode)

            bounds = bounds.union(actionNode.bounds)

            frameCount = max(frameCount, actionNode.children.count)
        }

        let frames = render(actionNodes: actionNodes, bounds: bounds, frameCount: frameCount)

        let frameWidth = bounds.size.width / scale
        let frameHeight = bounds.size.height / scale

        let frameInterval: CGFloat
        if let mainPart = composedSprite.mainPart,
           let action = mainPart.sprite.action(at: actionIndex) {
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

    private func render(actionNodes: [SpriteRenderNode], bounds: CGRect, frameCount: Int) -> [CGImage?] {
        var frames: [CGImage?] = []

        let renderer = CGImageRenderer(size: bounds.size, flipped: true)

        for frameIndex in 0..<frameCount {
            let image = renderer.image { cgContext in
                cgContext.clear(CGRect(origin: .zero, size: bounds.size))
                for actionNode in actionNodes {
                    let frameIndex = frameIndex % actionNode.children.count
                    let frameNode = actionNode.children[frameIndex]
                    for layerNode in frameNode.children {
                        if var image = layerNode.image {
                            if let color = layerNode.color {
                                image = image.applyingColor(color) ?? image
                            }
                            cgContext.saveGState()
                            cgContext.translateBy(x: -bounds.origin.x, y: -bounds.origin.y)
                            cgContext.concatenate(layerNode.transform)
                            cgContext.scaleBy(x: 1, y: -1)
                            cgContext.draw(image, in: layerNode.frame)
//                            cgContext.setStrokeColor(.black)
//                            cgContext.stroke(layerNode.frame)
                            cgContext.restoreGState()
                        }
                    }
                }
            }
            frames.append(image)
        }

        return frames
    }
}
