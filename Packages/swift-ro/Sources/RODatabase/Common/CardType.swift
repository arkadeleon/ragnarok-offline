//
//  CardType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum CardType: CaseIterable, RawRepresentable, CodingKey, Decodable {
    case normal
    case enchant

    public var rawValue: Int {
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
}
