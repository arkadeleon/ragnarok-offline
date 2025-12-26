//
//  CardType+Localization.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2025/12/26.
//

import Foundation
import RagnarokConstants

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
