//
//  SpriteConfiguration.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import ROGenerated

struct SpriteConfiguration {
    var gender: Gender = .male
    var headID = 1
    var outfitID: Int?
    var headgearIDs: [Int] = []
    var garmentID: Int?
    var weaponID: Int?
    var shieldID: Int?
    var bodyPaletteID: Int?
    var headPaletteID: Int?
    var headDirection = 0
    var madoType: MadoType = .robot
}
