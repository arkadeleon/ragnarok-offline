//
//  Parameter.swift
//  RagnarokOffline
//
//  Generated by ROCodeGenerator.
//

/// Converted from `e_params` in `map/pc.hpp`.
public enum Parameter: Int, CaseIterable, Sendable {
    case str = 0
    case agi = 1
    case vit = 2
    case int = 3
    case dex = 4
    case luk = 5
    case pow = 6
    case sta = 7
    case wis = 8
    case spl = 9
    case con = 10
    case crt = 11
}

extension Parameter: CodingKey {
    public var stringValue: String {
        switch self {
        case .str: "STR"
        case .agi: "AGI"
        case .vit: "VIT"
        case .int: "INT"
        case .dex: "DEX"
        case .luk: "LUK"
        case .pow: "POW"
        case .sta: "STA"
        case .wis: "WIS"
        case .spl: "SPL"
        case .con: "CON"
        case .crt: "CRT"
        }
    }

    public init?(stringValue: String) {
        switch stringValue.uppercased() {
        case "STR": self = .str
        case "AGI": self = .agi
        case "VIT": self = .vit
        case "INT": self = .int
        case "DEX": self = .dex
        case "LUK": self = .luk
        case "POW": self = .pow
        case "STA": self = .sta
        case "WIS": self = .wis
        case "SPL": self = .spl
        case "CON": self = .con
        case "CRT": self = .crt
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

extension Parameter: CodingKeyRepresentable {
    public var codingKey: any CodingKey {
        self
    }

    public init?<T>(codingKey: T) where T: CodingKey {
        self.init(stringValue: codingKey.stringValue)
    }
}

extension Parameter: Decodable {
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
