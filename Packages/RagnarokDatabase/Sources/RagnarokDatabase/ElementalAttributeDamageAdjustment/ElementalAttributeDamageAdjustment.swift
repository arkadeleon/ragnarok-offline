//
//  ElementalAttributeDamageAdjustment.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2026/10/19.
//

import RagnarokConstants

public struct ElementalAttributeDamageAdjustment: Decodable, Sendable {

    /// Level of the Attribute.
    public var level: Int

    /// Attacker's weapon element: Neutral
    /// Key: Target's defense element.
    /// Value: Accepted from -100 to 200 in %, default 100.
    public var neutral: [Element : Int]

    /// Attacker's weapon element: Water
    /// Key: Target's defense element.
    /// Value: Accepted from -100 to 200 in %, default 100.
    public var water: [Element : Int]

    /// Attacker's weapon element: Earth
    /// Key: Target's defense element.
    /// Value: Accepted from -100 to 200 in %, default 100.
    public var earth: [Element : Int]

    /// Attacker's weapon element: Fire
    /// Key: Target's defense element.
    /// Value: Accepted from -100 to 200 in %, default 100.
    public var fire: [Element : Int]

    /// Attacker's weapon element: Wind
    /// Key: Target's defense element.
    /// Value: Accepted from -100 to 200 in %, default 100.
    public var wind: [Element : Int]

    /// Attacker's weapon element: Poison
    /// Key: Target's defense element.
    /// Value: Accepted from -100 to 200 in %, default 100.
    public var poison: [Element : Int]

    /// Attacker's weapon element: Holy
    /// Key: Target's defense element.
    /// Value: Accepted from -100 to 200 in %, default 100.
    public var holy: [Element : Int]

    /// Attacker's weapon element: Dark
    /// Key: Target's defense element.
    /// Value: Accepted from -100 to 200 in %, default 100.
    public var dark: [Element : Int]

    /// Attacker's weapon element: Ghost
    /// Key: Target's defense element.
    /// Value: Accepted from -100 to 200 in %, default 100.
    public var ghost: [Element : Int]

    /// Attacker's weapon element: Undead
    /// Key: Target's defense element.
    /// Value: Accepted from -100 to 200 in %, default 100.
    public var undead: [Element : Int]

    enum CodingKeys: String, CodingKey {
        case level = "Level"
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
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.level = try container.decode(Int.self, forKey: .level)
        self.neutral = try container.decodeIfPresent([Element : Int].self, forKey: .neutral) ?? [:]
        self.water = try container.decodeIfPresent([Element : Int].self, forKey: .water) ?? [:]
        self.earth = try container.decodeIfPresent([Element : Int].self, forKey: .earth) ?? [:]
        self.fire = try container.decodeIfPresent([Element : Int].self, forKey: .fire) ?? [:]
        self.wind = try container.decodeIfPresent([Element : Int].self, forKey: .wind) ?? [:]
        self.poison = try container.decodeIfPresent([Element : Int].self, forKey: .poison) ?? [:]
        self.holy = try container.decodeIfPresent([Element : Int].self, forKey: .holy) ?? [:]
        self.dark = try container.decodeIfPresent([Element : Int].self, forKey: .dark) ?? [:]
        self.ghost = try container.decodeIfPresent([Element : Int].self, forKey: .ghost) ?? [:]
        self.undead = try container.decodeIfPresent([Element : Int].self, forKey: .undead) ?? [:]
    }

    public func rate(attackElement: Element, defenseElement: Element) -> Int {
        let rates: [Element : Int]
        switch attackElement {
        case .neutral: rates = neutral
        case .water: rates = water
        case .earth: rates = earth
        case .fire: rates = fire
        case .wind: rates = wind
        case .poison: rates = poison
        case .holy: rates = holy
        case .dark: rates = dark
        case .ghost: rates = ghost
        case .undead: rates = undead
        default: rates = [:]
        }
        return rates[defenseElement] ?? 100
    }
}
