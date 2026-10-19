//
//  ItemClasses+Localization.swift
//  RagnarokConstants
//
//  Created by Leon Li on 2026/10/20.
//

import Foundation

extension ItemClasses {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .normal:
            LocalizedStringResource("Normal", table: "ItemClasses", bundle: .module)
        case .upper:
            LocalizedStringResource("Transcendent", table: "ItemClasses", bundle: .module)
        case .baby:
            LocalizedStringResource("Baby", table: "ItemClasses", bundle: .module)
        case .third:
            LocalizedStringResource("Third Job", table: "ItemClasses", bundle: .module)
        case .third_upper:
            LocalizedStringResource("Transcendent Third Job", table: "ItemClasses", bundle: .module)
        case .third_baby:
            LocalizedStringResource("Baby Third Job", table: "ItemClasses", bundle: .module)
        case .fourth:
            LocalizedStringResource("Fourth Job", table: "ItemClasses", bundle: .module)
        case .all_upper:
            LocalizedStringResource("All Transcendent", table: "ItemClasses", bundle: .module)
        case .all_baby:
            LocalizedStringResource("All Baby", table: "ItemClasses", bundle: .module)
        case .all_third:
            LocalizedStringResource("All Third Job", table: "ItemClasses", bundle: .module)
        case .all:
            LocalizedStringResource("All", table: "ItemClasses", bundle: .module)
        default:
            LocalizedStringResource(stringLiteral: stringValue)
        }
    }
}
