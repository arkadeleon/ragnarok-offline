//
//  SpriteConfiguration.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import ROConstants

public struct SpriteConfiguration: Sendable {
    public var gender: Gender
    public var outfitID: Int?
    public var clothesColorID: Int?
    public var hairStyleID: Int
    public var hairColorID: Int?
    public var headgearIDs: [Int]
    public var garmentID: Int?
    public var weaponID: Int?
    public var shieldID: Int?
    public var madoType: MadoType

    public init() {
        gender = .male
        hairStyleID = 1
        headgearIDs = []
        madoType = .robot
    }
}
