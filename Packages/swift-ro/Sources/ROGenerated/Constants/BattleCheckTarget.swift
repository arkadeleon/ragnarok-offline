//
//  BattleCheckTarget.swift
//  RagnarokOffline
//
//  Generated by ROCodeGenerator.
//

/// Converted from `e_battle_check_target` in `map/battle.hpp`.
public enum BattleCheckTarget: CaseIterable, Sendable {
    case noone
    case _self
    case enemy
    case party
    case guildally
    case neutral
    case sameguild
    case all
    case wos
    case guild
    case noguild
    case noparty
    case noenemy
    case ally
    case friend
}

extension BattleCheckTarget: RawRepresentable {
    public var rawValue: Int {
        switch self {
        case .noone: 0x0
        case ._self: 0x10000
        case .enemy: 0x20000
        case .party: 0x40000
        case .guildally: 0x80000
        case .neutral: 0x100000
        case .sameguild: 0x200000
        case .all: 0x3f0000
        case .wos: 0x400000
        case .guild: 0x280000
        case .noguild: 0x170000
        case .noparty: 0x3b0000
        case .noenemy: 0x3d0000
        case .ally: 0x2c0000
        case .friend: 0x3d0000
        }
    }

    public init?(rawValue: Int) {
        switch rawValue {
        case 0x0: self = .noone
        case 0x10000: self = ._self
        case 0x20000: self = .enemy
        case 0x40000: self = .party
        case 0x80000: self = .guildally
        case 0x100000: self = .neutral
        case 0x200000: self = .sameguild
        case 0x3f0000: self = .all
        case 0x400000: self = .wos
        case 0x280000: self = .guild
        case 0x170000: self = .noguild
        case 0x3b0000: self = .noparty
        case 0x3d0000: self = .noenemy
        case 0x2c0000: self = .ally
        case 0x3d0000: self = .friend
        default: return nil
        }
    }
}

extension BattleCheckTarget: CodingKey {
    public var stringValue: String {
        switch self {
        case .noone: "NOONE"
        case ._self: "SELF"
        case .enemy: "ENEMY"
        case .party: "PARTY"
        case .guildally: "GUILDALLY"
        case .neutral: "NEUTRAL"
        case .sameguild: "SAMEGUILD"
        case .all: "ALL"
        case .wos: "WOS"
        case .guild: "GUILD"
        case .noguild: "NOGUILD"
        case .noparty: "NOPARTY"
        case .noenemy: "NOENEMY"
        case .ally: "ALLY"
        case .friend: "FRIEND"
        }
    }

    public init?(stringValue: String) {
        switch stringValue.uppercased() {
        case "NOONE": self = .noone
        case "SELF": self = ._self
        case "ENEMY": self = .enemy
        case "PARTY": self = .party
        case "GUILDALLY": self = .guildally
        case "NEUTRAL": self = .neutral
        case "SAMEGUILD": self = .sameguild
        case "ALL": self = .all
        case "WOS": self = .wos
        case "GUILD": self = .guild
        case "NOGUILD": self = .noguild
        case "NOPARTY": self = .noparty
        case "NOENEMY": self = .noenemy
        case "ALLY": self = .ally
        case "FRIEND": self = .friend
        default: return nil
        }
    }

    public var intValue: Int? {
        rawValue
    }

    public init?(intValue: Int) {
        self.init(rawValue: intValue)
    }
}

extension BattleCheckTarget: CodingKeyRepresentable {
    public var codingKey: any CodingKey {
        self
    }

    public init?<T>(codingKey: T) where T: CodingKey {
        self.init(stringValue: codingKey.stringValue)
    }
}

extension BattleCheckTarget: Decodable {
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