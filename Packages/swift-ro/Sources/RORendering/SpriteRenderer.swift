//
//  SpriteRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/17.
//

import CoreGraphics
import ROCore

public enum PlayerActionType: Int, CaseIterable, CustomStringConvertible, Sendable {
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

    public var description: String {
        switch self {
        case .idle:
            "Idle"
        case .walk:
            "Walk"
        case .sit:
            "Sit"
        case .pickup:
            "Pickup"
        case .attackWait:
            "Attack Wait"
        case .attack:
            "Attack"
        case .hurt:
            "Hurt"
        case .freeze:
            "Freeze"
        case .die:
            "Die"
        case .freeze2:
            "Freeze"
        case .attack2:
            "Attack"
        case .attack3:
            "Attack"
        case .skill:
            "Skill"
        }
    }
}

public enum MonsterActionType: Int, CaseIterable, CustomStringConvertible, Sendable {
    case idle
    case walk
    case attack
    case hurt
    case die

    public var description: String {
        switch self {
        case .idle:
            "Idle"
        case .walk:
            "Walk"
        case .attack:
            "Attack"
        case .hurt:
            "Hurt"
        case .die:
            "Die"
        }
    }
}

public enum BodyDirection: Int, CaseIterable, CustomStringConvertible, Sendable {
    case south
    case southwest
    case west
    case northwest
    case north
    case northeast
    case east
    case southeast

    public var description: String {
        switch self {
        case .south:
            "South"
        case .southwest:
            "Southwest"
        case .west:
            "West"
        case .northwest:
            "Northwest"
        case .north:
            "North"
        case .northeast:
            "Northeast"
        case .east:
            "East"
        case .southeast:
            "Southeast"
        }
    }
}

public enum HeadDirection: Int, CaseIterable, CustomStringConvertible, Sendable {
    case straight
    case left
    case right

    public var description: String {
        switch self {
        case .straight:
            "Straight"
        case .left:
            "Left"
        case .right:
            "Right"
        }
    }
}

final public class SpriteRenderer: Sendable {
    public let sprites: [SpriteResource]
    public let scale: CGFloat = 2

    public init(sprites: [SpriteResource]) {
        self.sprites = sprites
    }

    public func renderAction(at actionIndex: Int, headDirection: HeadDirection) async -> [CGImage] {
        var actionNodes: [(SpriteResource, SpriteRenderNode)] = []
        var bounds: CGRect = .null

        var frameCount = 0

        for sprite in sprites {
            let actionIndex = (sprite.semantic == .shadow ? 0 : actionIndex)

            let actionNode = SpriteRenderNode(actionNodeWithSprite: sprite, actionIndex: actionIndex, headDirection: headDirection, scale: scale)
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
