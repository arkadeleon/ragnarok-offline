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
    public struct Result: Sendable {
        public let frames: [CGImage?]
        public let frameWidth: CGFloat
        public let frameHeight: CGFloat
        public let frameInterval: CGFloat
    }

    public let sprites: [SpriteResource]
    public let scale: CGFloat = 2

    public init(sprites: [SpriteResource]) {
        self.sprites = sprites
    }

    public func renderAction(at actionIndex: Int, headDirection: HeadDirection) async -> SpriteRenderer.Result {
        var actionNodes: [(SpriteResource, SpriteRenderNode)] = []
        var bounds: CGRect = .null
        var frameCount = 0

        for sprite in sprites {
            let actionIndex = (sprite.part == .shadow ? 0 : actionIndex)
            let scale = self.scale * sprite.scaleFactor

            let actionNode = SpriteRenderNode(
                actionNodeWithSprite: sprite,
                actionIndex: actionIndex,
                headDirection: headDirection,
                scale: scale
            )
            actionNodes.append((sprite, actionNode))

            bounds = bounds.union(actionNode.bounds)

            frameCount = max(frameCount, actionNode.children.count)
        }

        var frames: [CGImage?] = []
        let renderer = CGImageRenderer(size: bounds.size, flipped: true)

        for frameIndex in 0..<frameCount {
            let image = renderer.image { cgContext in
                cgContext.clear(CGRect(origin: .zero, size: bounds.size))
                for (sprite, actionNode) in actionNodes {
                    let frameIndex = frameIndex % actionNode.children.count
                    let frameNode = actionNode.children[frameIndex]
                    for layerNode in frameNode.children {
                        if let image = layerNode.image {
                            cgContext.saveGState()
                            cgContext.translateBy(x: -bounds.origin.x, y: -bounds.origin.y)
                            cgContext.concatenate(layerNode.transform)
                            cgContext.scaleBy(x: 1, y: -1)
                            cgContext.draw(image, in: layerNode.frame)
                            cgContext.restoreGState()
                        }
                    }
                }
            }
            frames.append(image)
        }

        var frameInterval: CGFloat = 1 / 12
        if let mainSprite = sprites.first(where: { $0.part == .main || $0.part == .playerBody }),
           let action = mainSprite.action(at: actionIndex) {
            frameInterval = CGFloat(action.animationSpeed * 25 / 1000)
        }

        let result = SpriteRenderer.Result(
            frames: frames,
            frameWidth: bounds.size.width,
            frameHeight: bounds.size.height,
            frameInterval: frameInterval
        )
        return result
    }
}
