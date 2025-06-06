//
//  CharacterConfiguration.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/20.
//

import ROConstants
import RODatabase
import RORendering

struct CharacterConfiguration {
    var jobID: JobID
    var gender: Gender
    var hairStyle: Int
    var hairColor: Int
    var clothesColor: Int
    var weaponType: WeaponType
    var shield: Int
    var headTop: Item?
    var headMid: Item?
    var headBottom: Item?
    var garment: Item?

    var actionType: ComposedSprite.ActionType
    var direction: ComposedSprite.Direction
    var headDirection: ComposedSprite.HeadDirection

    var headgears: [Int] {
        [headTop, headMid, headBottom].map {
            $0?.view ?? 0
        }
    }

    init() {
        jobID = .novice
        gender = .male
        hairStyle = 1
        hairColor = -1
        clothesColor = -1
        weaponType = .w_fist
        shield = 0
        headTop = nil
        headMid = nil
        headBottom = nil
        garment = nil

        actionType = .idle
        direction = .south
        headDirection = .straight
    }

    mutating func rotateClockwise() {
        let count = ComposedSprite.Direction.allCases.count
        let rawValue = (direction.rawValue + 1) % count
        direction = ComposedSprite.Direction(rawValue: rawValue)!
    }

    mutating func rotateCounterClockwise() {
        let count = ComposedSprite.Direction.allCases.count
        let rawValue = (direction.rawValue + count - 1) % count
        direction = ComposedSprite.Direction(rawValue: rawValue)!
    }
}

extension ComposedSprite.Configuration {
    init(configuration: CharacterConfiguration) {
        self.init(jobID: configuration.jobID.rawValue)
        self.gender = configuration.gender
        self.hairStyle = configuration.hairStyle
        self.hairColor = configuration.hairColor
        self.clothesColor = configuration.clothesColor
        self.weapon = configuration.weaponType.rawValue
        self.shield = configuration.shield
        self.headgears = configuration.headgears
        self.garment = configuration.garment?.view ?? 0
    }
}
