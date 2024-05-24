//
//  CardType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum CardType: String, CaseIterable, CodingKey, Decodable {
    case normal = "Normal"
    case enchant = "Enchant"
}

extension CardType: Identifiable {
    public var id: Int {
        switch self {
        case .normal: RA_CARD_NORMAL
        case .enchant: RA_CARD_ENCHANT
        }
    }
}

extension CardType: CustomStringConvertible {
    public var description: String {
        stringValue
    }
}
