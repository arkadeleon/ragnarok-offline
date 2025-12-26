//
//  Element+Localization.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2025/12/26.
//

import Foundation
import RagnarokConstants

extension Element {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .neutral:
            LocalizedStringResource("Neutral", table: "Element", bundle: .module)
        case .water:
            LocalizedStringResource("Water", table: "Element", bundle: .module)
        case .earth:
            LocalizedStringResource("Earth", table: "Element", bundle: .module)
        case .fire:
            LocalizedStringResource("Fire", table: "Element", bundle: .module)
        case .wind:
            LocalizedStringResource("Wind", table: "Element", bundle: .module)
        case .poison:
            LocalizedStringResource("Poison", table: "Element", bundle: .module)
        case .holy:
            LocalizedStringResource("Holy", table: "Element", bundle: .module)
        case .dark:
            LocalizedStringResource("Dark", table: "Element", bundle: .module)
        case .ghost:
            LocalizedStringResource("Ghost", table: "Element", bundle: .module)
        case .undead:
            LocalizedStringResource("Undead", table: "Element", bundle: .module)
        case .weapon:
            LocalizedStringResource("Weapon", table: "Element", bundle: .module)
        case .endowed:
            LocalizedStringResource("Endowed", table: "Element", bundle: .module)
        case .random:
            LocalizedStringResource("Random", table: "Element", bundle: .module)
        }
    }
}
