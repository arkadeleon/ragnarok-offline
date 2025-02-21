//
//  CharacterConfiguration.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/20.
//

import ROGenerated
import RORendering

struct CharacterConfiguration {
    var jobID: JobID
    var gender: Gender
    var clothesColorID: Int?
    var hairStyleID: Int
    var hairColorID: Int?
    var weaponID: Int?
    var shieldID: Int?
    var actionType: PlayerActionType
    var direction: BodyDirection
    var headDirection: HeadDirection

    init() {
        jobID = .novice
        gender = .male
        hairStyleID = 1
        weaponID = 1
        shieldID = 1
        actionType = .idle
        direction = .south
        headDirection = .straight
    }
}
