//
//  DamageType.swift
//  RagnarokOffline
//
//  Generated by ROCodeGenerator.
//

/// Converted from `e_damage_type` in `map/clif.hpp`.
public enum DamageType: Int, CaseIterable, Sendable {
    case normal = 0
    case pickup_item = 1
    case sit_down = 2
    case stand_up = 3
    case endure = 4
    case splash = 5
    case single = 6
    case _repeat = 7
    case multi_hit = 8
    case multi_hit_endure = 9
    case critical = 10
    case lucy_dodge = 11
    case touch = 12
    case multi_hit_critical = 13
}

extension DamageType: CodingKey {
    public var stringValue: String {
        switch self {
        case .normal: "NORMAL"
        case .pickup_item: "PICKUP_ITEM"
        case .sit_down: "SIT_DOWN"
        case .stand_up: "STAND_UP"
        case .endure: "ENDURE"
        case .splash: "SPLASH"
        case .single: "SINGLE"
        case ._repeat: "REPEAT"
        case .multi_hit: "MULTI_HIT"
        case .multi_hit_endure: "MULTI_HIT_ENDURE"
        case .critical: "CRITICAL"
        case .lucy_dodge: "LUCY_DODGE"
        case .touch: "TOUCH"
        case .multi_hit_critical: "MULTI_HIT_CRITICAL"
        }
    }

    public init?(stringValue: String) {
        switch stringValue.uppercased() {
        case "NORMAL": self = .normal
        case "PICKUP_ITEM": self = .pickup_item
        case "SIT_DOWN": self = .sit_down
        case "STAND_UP": self = .stand_up
        case "ENDURE": self = .endure
        case "SPLASH": self = .splash
        case "SINGLE": self = .single
        case "REPEAT": self = ._repeat
        case "MULTI_HIT": self = .multi_hit
        case "MULTI_HIT_ENDURE": self = .multi_hit_endure
        case "CRITICAL": self = .critical
        case "LUCY_DODGE": self = .lucy_dodge
        case "TOUCH": self = .touch
        case "MULTI_HIT_CRITICAL": self = .multi_hit_critical
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

extension DamageType: CodingKeyRepresentable {
    public var codingKey: any CodingKey {
        self
    }

    public init?<T>(codingKey: T) where T: CodingKey {
        self.init(stringValue: codingKey.stringValue)
    }
}

extension DamageType: Decodable {
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