//
//  SpriteResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

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

class SpriteResource {
    let act: ACT
    let spr: SPR

    var semantic: SpriteSemantic = .standard
    var orderBySemantic = 0

    init(act: ACT, spr: SPR) {
        self.act = act
        self.spr = spr
    }
}
