//
//  SpriteConfiguration+MapObject.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/14.
//

import RagnarokConstants
import RagnarokModels
import RagnarokSprite

extension ComposedSprite.Configuration {
    init(character: CharacterInfo) {
        self.init(jobID: character.job)
        self.gender = Gender(rawValue: character.sex) ?? .female
        self.hairStyle = character.head
        self.hairColor = character.headPalette
        self.clothesColor = character.bodyPalette
        self.weapon = character.weapon
        self.shield = character.shield
        self.headgears = [character.accessory2, character.accessory3, character.accessory]
        self.garment = character.robePalette

        self.updateHairStyle()
    }

    init(mapObject: MapObject) {
        self.init(jobID: mapObject.job)
        self.gender = mapObject.gender
        self.hairStyle = mapObject.hairStyle
        self.hairColor = mapObject.hairColor
        self.clothesColor = mapObject.clothesColor
        self.weapon = mapObject.weapon
        self.shield = mapObject.shield
        self.headgears = [mapObject.headTop, mapObject.headMid, mapObject.headBottom]
        self.garment = mapObject.garment

        self.updateHairStyle()
    }

    mutating func updateHairStyle() {
        let hairStyles: [Int] = if job.isDoram {
            switch gender {
            case .female: [0, 1, 2, 3, 4, 5, 6]
            case .male: [0, 1, 2, 3, 4, 5, 6]
            default: []
            }
        } else {
            switch gender {
            case .female: [2, 2, 4, 7, 1, 5, 3, 6, 12, 10, 9, 11, 8]
            case .male: [2, 2, 1, 7, 5, 4, 3, 6, 8, 9, 10, 12, 11]
            default: []
            }
        }

        let hairStyle = self.hairStyle
        if hairStyles.indices.contains(hairStyle) {
            self.hairStyle = hairStyles[hairStyle]
        }
    }
}
