//
//  AmmoType.swift
//  RagnarokOffline
//
//  Generated by ROGenerator.
//

public enum AmmoType: Int, CaseIterable, CodingKey, CodingKeyRepresentable, Decodable, Sendable {
    case arrow = 1
    case dagger = 2
    case bullet = 3
    case shell = 4
    case grenade = 5
    case shuriken = 6
    case kunai = 7
    case cannonball = 8
    case throwweapon = 9

    public init?(stringValue: String) {
        switch stringValue.uppercased() {
        case "ARROW": self = .arrow
        case "DAGGER": self = .dagger
        case "BULLET": self = .bullet
        case "SHELL": self = .shell
        case "GRENADE": self = .grenade
        case "SHURIKEN": self = .shuriken
        case "KUNAI": self = .kunai
        case "CANNONBALL": self = .cannonball
        case "THROWWEAPON": self = .throwweapon
        default: return nil
        }
    }

    public init?<T>(codingKey: T) where T: CodingKey {
        self.init(stringValue: codingKey.stringValue)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let value = Self.init(stringValue: stringValue) {
            self = value
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Could not initialize \(Self.self) from invalid string value \(stringValue)")
        }
    }
}