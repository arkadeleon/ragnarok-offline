//
//  ItemGroupAlgorithm+Localization.swift
//  RagnarokConstants
//
//  Created by Leon Li on 2026/10/23.
//

import Foundation

extension ItemGroupAlgorithm {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .all:
            LocalizedStringResource("All", table: "ItemGroupAlgorithm", bundle: .module)
        case .random:
            LocalizedStringResource("Random", table: "ItemGroupAlgorithm", bundle: .module)
        case .sharedpool:
            LocalizedStringResource("Shared Pool", table: "ItemGroupAlgorithm", bundle: .module)
        }
    }
}
