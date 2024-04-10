//
//  Element.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/9.
//

import rAthenaCommon

public enum Element: String, CaseIterable, CodingKey, Decodable {
    case neutral = "Neutral"
    case water = "Water"
    case earth = "Earth"
    case fire = "Fire"
    case wind = "Wind"
    case poison = "Poison"
    case holy = "Holy"
    case dark = "Dark"
    case ghost = "Ghost"
    case undead = "Undead"
    case weapon = "Weapon"
    case endowed = "Endowed"
    case random = "Random"
}

extension Element: Identifiable {
    public var id: Int {
        switch self {
        case .neutral: RA_ELE_NEUTRAL
        case .water: RA_ELE_WATER
        case .earth: RA_ELE_EARTH
        case .fire: RA_ELE_FIRE
        case .wind: RA_ELE_WIND
        case .poison: RA_ELE_POISON
        case .holy: RA_ELE_HOLY
        case .dark: RA_ELE_DARK
        case .ghost: RA_ELE_GHOST
        case .undead: RA_ELE_UNDEAD
        case .weapon: RA_ELE_WEAPON
        case .endowed: RA_ELE_ENDOWED
        case .random: RA_ELE_RANDOM
        }
    }
}

extension Element: CustomStringConvertible {
    public var description: String {
        stringValue
    }
}
