//
//  Gender+Localization.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2025/7/9.
//

import Foundation
import RagnarokConstants

extension Gender {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .female:
            LocalizedStringResource("Female", table: "Gender", bundle: .module, comment: "The name of a gender.")
        case .male:
            LocalizedStringResource("Male", table: "Gender", bundle: .module, comment: "The name of a gender.")
        case .both:
            LocalizedStringResource("Both", table: "Gender", bundle: .module, comment: "The name of a gender.")
        }
    }
}
