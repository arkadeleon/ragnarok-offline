//
//  SkillNoNearNPC.swift
//  RagnarokOffline
//
//  Generated by ROCodeGenerator.
//

/// Converted from `e_skill_nonear_npc` in `map/skill.hpp`.
public enum SkillNoNearNPC: Int, CaseIterable, Sendable {
    case warpportal = 0x1
    case shop = 0x2
    case npc = 0x4
    case tomb = 0x8
}

extension SkillNoNearNPC: CodingKey {
    public var stringValue: String {
        switch self {
        case .warpportal: "WARPPORTAL"
        case .shop: "SHOP"
        case .npc: "NPC"
        case .tomb: "TOMB"
        }
    }

    public init?(stringValue: String) {
        switch stringValue.uppercased() {
        case "WARPPORTAL": self = .warpportal
        case "SHOP": self = .shop
        case "NPC": self = .npc
        case "TOMB": self = .tomb
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

extension SkillNoNearNPC: CodingKeyRepresentable {
    public var codingKey: any CodingKey {
        self
    }

    public init?<T>(codingKey: T) where T: CodingKey {
        self.init(stringValue: codingKey.stringValue)
    }
}

extension SkillNoNearNPC: Decodable {
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