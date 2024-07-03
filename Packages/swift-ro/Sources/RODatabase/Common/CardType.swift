//
//  CardType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum CardType: CaseIterable, CodingKey, Decodable {
    case normal
    case enchant

    public var intValue: Int {
        switch self {
        case .normal: RA_CARD_NORMAL
        case .enchant: RA_CARD_ENCHANT
        }
    }

    public var stringValue: String {
        switch self {
        case .normal: "Normal"
        case .enchant: "Enchant"
        }
    }

    public init?(stringValue: String) {
        if let cardType = CardType.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = cardType
        } else {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let cardType = CardType(stringValue: stringValue) {
            self = cardType
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Card type does not exist.")
            throw DecodingError.valueNotFound(CardType.self, context)
        }
    }
}
