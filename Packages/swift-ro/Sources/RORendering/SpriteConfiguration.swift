//
//  SpriteConfiguration.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import ROConstants

public struct SpriteConfiguration: Sendable {
    public var gender: Gender
    public var hairStyle: Int
    public var hairColor: Int
    public var clothesColor: Int
    public var weapon: Int
    public var shield: Int
    public var headgears: [Int]
    public var garment: Int
    public var outfit: Int
    public var madoType: MadoType

    public init() {
        gender = .male
        hairStyle = 1
        hairColor = -1
        clothesColor = -1
        weapon = 0
        shield = 0
        headgears = []
        garment = 0
        outfit = 0
        madoType = .robot
    }
}
