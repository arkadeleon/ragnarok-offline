//
//  SpriteResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import CoreGraphics
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

    lazy var imagesBySpriteType: [SPR.SpriteType : [CGImage?]] = {
        spr.imagesBySpriteType()
    }()

    init(act: ACT, spr: SPR) {
        self.act = act
        self.spr = spr
    }

    func image(for layer: ACT.Layer) -> CGImage? {
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
