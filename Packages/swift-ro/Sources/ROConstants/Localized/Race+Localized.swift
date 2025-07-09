//
//  Race+Localized.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/9.
//

import Foundation

extension Race {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .formless:
            LocalizedStringResource("Formless", table: "Race", bundle: .module, comment: "The name of a race.")
        case .undead:
            LocalizedStringResource("Undead", table: "Race", bundle: .module, comment: "The name of a race.")
        case .brute:
            LocalizedStringResource("Brute", table: "Race", bundle: .module, comment: "The name of a race.")
        case .plant:
            LocalizedStringResource("Plant", table: "Race", bundle: .module, comment: "The name of a race.")
        case .insect:
            LocalizedStringResource("Insect", table: "Race", bundle: .module, comment: "The name of a race.")
        case .fish:
            LocalizedStringResource("Fish", table: "Race", bundle: .module, comment: "The name of a race.")
        case .demon:
            LocalizedStringResource("Demon", table: "Race", bundle: .module, comment: "The name of a race.")
        case .demihuman:
            LocalizedStringResource("Demi-Human", table: "Race", bundle: .module, comment: "The name of a race.")
        case .angel:
            LocalizedStringResource("Angel", table: "Race", bundle: .module, comment: "The name of a race.")
        case .dragon:
            LocalizedStringResource("Dragon", table: "Race", bundle: .module, comment: "The name of a race.")
        }
    }
}
