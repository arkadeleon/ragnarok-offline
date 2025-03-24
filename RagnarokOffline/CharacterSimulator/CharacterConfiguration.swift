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
    var clothesColorID: Int?
    var hairStyleID: Int
    var hairColorID: Int?
    var upperHeadgear: Item?
    var middleHeadgear: Item?
    var lowerHeadgear: Item?
    var weaponType: WeaponType
    var shieldID: Int?
    var actionType: PlayerActionType
    var direction: BodyDirection
    var headDirection: HeadDirection

    var headgearIDs: [Int] {
        [upperHeadgear, middleHeadgear, lowerHeadgear].compactMap({ $0?.view })
    }

    init() {
        jobID = .novice
        gender = .male
        hairStyleID = 1
        weaponType = .w_fist
        actionType = .idle
        direction = .south
        headDirection = .straight
    }
}
