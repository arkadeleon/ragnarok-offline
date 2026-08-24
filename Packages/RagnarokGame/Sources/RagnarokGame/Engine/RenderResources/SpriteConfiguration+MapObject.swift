//
//  SpriteConfiguration+MapObject.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/23.
//

import RagnarokSprite

extension ComposedSprite.Configuration {
    init(object: MapSceneMapObject) {
        self.init(jobID: object.job)
        self.gender = object.gender
        self.hairStyle = object.hairStyle
        self.hairColor = object.hairColor
        self.clothesColor = object.clothesColor
        self.weapon = object.weaponType.rawValue
        self.shield = object.shield
        self.headgears = [object.headTop, object.headMid, object.headBottom]
        self.garment = object.garment

        self.updateHairStyle()
    }
}
