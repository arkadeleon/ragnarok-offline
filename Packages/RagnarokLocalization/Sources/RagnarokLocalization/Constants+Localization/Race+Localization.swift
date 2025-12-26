//
//  Race+Localization.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2024/1/9.
//

import Foundation
import RagnarokConstants

extension Race {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .formless:
            LocalizedStringResource("Formless", table: "Race", bundle: .module)
        case .undead:
            LocalizedStringResource("Undead", table: "Race", bundle: .module)
        case .brute:
            LocalizedStringResource("Brute", table: "Race", bundle: .module)
        case .plant:
            LocalizedStringResource("Plant", table: "Race", bundle: .module)
        case .insect:
            LocalizedStringResource("Insect", table: "Race", bundle: .module)
        case .fish:
            LocalizedStringResource("Fish", table: "Race", bundle: .module)
        case .demon:
            LocalizedStringResource("Demon", table: "Race", bundle: .module)
        case .demihuman:
            LocalizedStringResource("Demi-Human", table: "Race", bundle: .module)
        case .angel:
            LocalizedStringResource("Angel", table: "Race", bundle: .module)
        case .dragon:
            LocalizedStringResource("Dragon", table: "Race", bundle: .module)
        }
    }
}
