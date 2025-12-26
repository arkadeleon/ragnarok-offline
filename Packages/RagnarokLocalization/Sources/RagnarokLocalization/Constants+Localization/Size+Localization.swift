//
//  Size+Localization.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2025/12/26.
//

import Foundation
import RagnarokConstants

extension Size {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .small:
            LocalizedStringResource("Small", table: "Size", bundle: .module)
        case .medium:
            LocalizedStringResource("Medium", table: "Size", bundle: .module)
        case .large:
            LocalizedStringResource("Large", table: "Size", bundle: .module)
        }
    }
}
