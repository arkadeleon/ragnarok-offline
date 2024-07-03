//
//  AmmoType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum AmmoType: CaseIterable, CodingKey, Decodable {
    case arrow
    case dagger
    case bullet
    case shell
    case grenade
    case shuriken
    case kunai
    case cannonball
    case throwweapon

    public var intValue: Int {
        switch self {
        case .arrow: RA_AMMO_ARROW
        case .dagger: RA_AMMO_DAGGER
        case .bullet: RA_AMMO_BULLET
        case .shell: RA_AMMO_SHELL
        case .grenade: RA_AMMO_GRENADE
        case .shuriken: RA_AMMO_SHURIKEN
        case .kunai: RA_AMMO_KUNAI
        case .cannonball: RA_AMMO_CANNONBALL
        case .throwweapon: RA_AMMO_THROWWEAPON
        }
    }

    public var stringValue: String {
        switch self {
        case .arrow: "Arrow"
        case .dagger: "Dagger"
        case .bullet: "Bullet"
        case .shell: "Shell"
        case .grenade: "Grenade"
        case .shuriken: "Shuriken"
        case .kunai: "Kunai"
        case .cannonball: "Cannonball"
        case .throwweapon: "Throwweapon"
        }
    }

    public init?(stringValue: String) {
        if let ammoType = AmmoType.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = ammoType
        } else {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let ammoType = AmmoType(stringValue: stringValue) {
            self = ammoType
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Ammo type does not exist.")
            throw DecodingError.valueNotFound(AmmoType.self, context)
        }
    }
}
