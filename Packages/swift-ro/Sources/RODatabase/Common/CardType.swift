//
//  CardType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum CardType: Option {
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
}
