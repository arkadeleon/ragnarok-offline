//
//  SpriteRenderer.swift
//  swift-ro
//
//  Created by Leon Li on 2025/2/17.
//

import CoreGraphics
import ROCore

public enum PlayerActionType: Int, Sendable {
    case idle
    case walk
    case sit
    case pickup
    case attackWait
    case attack
    case hurt
    case freeze
    case die
    case freeze2
    case attack2
    case attack3
    case skill
}

public enum BodyDirection: Int, Sendable {
    case south
    case southWest
    case west
    case northWest
    case north
    case northEast
    case east
    case southEast
}

public enum HeadDirection: Int, Sendable {
    case straight
    case left
    case right
}

final public class SpriteRenderer {
    public init() {
    }

    public func drawPlayerSprites(sprites: [SpriteResource], actionType: PlayerActionType, direction: BodyDirection, headDirection: HeadDirection) -> [CGImage] {
        var actionNodes: [(SpriteResource, SpriteResource.RenderNode)] = []
        var bounds: CGRect = .null

        let actionIndex = actionType.rawValue * 8 + direction.rawValue

        var frameCount = 0

        for sprite in sprites {
            let actionIndex = (sprite.semantic == .shadow ? 0 : actionIndex)

            let actionNode = sprite.actionNode(actionIndex: actionIndex, headDirection: headDirection)
            actionNodes.append((sprite, actionNode))

            bounds = bounds.union(actionNode.bounds)

            frameCount = max(frameCount, actionNode.children.count)
        }

        var images: [CGImage] = []

        for frameIndex in 0..<frameCount {
            let renderer = CGImageRenderer(size: bounds.size, flipped: true)

            let image = renderer.image { context in
                for (sprite, actionNode) in actionNodes {
                    let frameIndex = frameIndex % actionNode.children.count
                    let frameNode = actionNode.children[frameIndex]
                    for layerNode in frameNode.children {
                        if let image = layerNode.image {
                            context.saveGState()
                            context.translateBy(x: -bounds.origin.x, y: -bounds.origin.y)
                            context.concatenate(layerNode.transform)
                            context.scaleBy(x: 1, y: -1)
                            context.draw(image, in: layerNode.frame)
                            context.restoreGState()
                        }
                    }
                }
            }

            if let image {
                images.append(image)
            }
        }

        return images
    }
}
