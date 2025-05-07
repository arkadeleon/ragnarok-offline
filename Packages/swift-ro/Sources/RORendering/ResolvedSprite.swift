//
//  ResolvedSprite.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/29.
//

public struct ResolvedSprite: Sendable {
    var parts: [ResolvedSprite.Part]

    var mainPart: ResolvedSprite.Part? {
        parts.first {
            $0.semantic == .main || $0.semantic == .playerBody
        }
    }

    init() {
        self.parts = []
    }

    mutating func append(_ sprite: SpriteResource, semantic: ResolvedSprite.Part.Semantic, order: Int = 0) {
        let part = ResolvedSprite.Part(sprite: sprite, semantic: semantic, orderBySemantic: order)
        parts.append(part)
    }
}

extension ResolvedSprite {
    struct Part {
        enum Semantic {
            case main
            case playerBody
            case playerHead
            case headgear
            case garment
            case weapon
            case shield
            case shadow
        }

        var sprite: SpriteResource
        var semantic: ResolvedSprite.Part.Semantic
        var orderBySemantic = 0

        init(sprite: SpriteResource, semantic: ResolvedSprite.Part.Semantic, orderBySemantic: Int = 0) {
            self.sprite = sprite
            self.semantic = semantic
            self.orderBySemantic = orderBySemantic
        }
    }
}
