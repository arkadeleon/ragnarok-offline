//
//  CardType+Localization.swift
//  RagnarokConstants
//
//  Created by Leon Li on 2025/12/26.
//

import Foundation

extension CardType {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .normal:
            LocalizedStringResource("Normal", table: "CardType", bundle: .module)
        case .enchant:
            LocalizedStringResource("Enchant", table: "CardType", bundle: .module)
        }
    }
}
