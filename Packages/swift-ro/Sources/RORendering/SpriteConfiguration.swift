//
//  SpriteConfiguration.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import ROGenerated

public struct SpriteConfiguration: Sendable {
    public var gender: Gender
    public var headID: Int
    public var outfitID: Int?
    public var headgearIDs: [Int]
    public var garmentID: Int?
    public var weaponID: Int?
    public var shieldID: Int?
    public var bodyPaletteID: Int?
    public var headPaletteID: Int?
    public var madoType: MadoType

    public init() {
        gender = .male
        headID = 1
        headgearIDs = []
        madoType = .robot
    }
}
