//
//  Gender+Localization.swift
//  RagnarokConstants
//
//  Created by Leon Li on 2025/7/9.
//

import Foundation

extension Gender {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .female:
            LocalizedStringResource("Female", table: "Gender", bundle: .module)
        case .male:
            LocalizedStringResource("Male", table: "Gender", bundle: .module)
        case .both:
            LocalizedStringResource("Both", table: "Gender", bundle: .module)
        }
    }
}
