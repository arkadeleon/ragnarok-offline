//
//  MonsterClass.swift
//  RagnarokOffline
//
//  Generated by ROCodeGenerator.
//

/// Converted from `e_aegis_monsterclass` in `map/mob.hpp`.
public enum MonsterClass: Int, CaseIterable, Sendable {
    case normal = 0
    case boss = 1
    case guardian = 2
    case battlefield = 4
    case event = 5
}

extension MonsterClass: CodingKey {
    public var stringValue: String {
        switch self {
        case .normal: "NORMAL"
        case .boss: "BOSS"
        case .guardian: "GUARDIAN"
        case .battlefield: "BATTLEFIELD"
        case .event: "EVENT"
        }
    }

    public init?(stringValue: String) {
        switch stringValue.uppercased() {
        case "NORMAL": self = .normal
        case "BOSS": self = .boss
        case "GUARDIAN": self = .guardian
        case "BATTLEFIELD": self = .battlefield
        case "EVENT": self = .event
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

extension MonsterClass: CodingKeyRepresentable {
    public var codingKey: any CodingKey {
        self
    }

    public init?<T>(codingKey: T) where T: CodingKey {
        self.init(stringValue: codingKey.stringValue)
    }
}

extension MonsterClass: Decodable {
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