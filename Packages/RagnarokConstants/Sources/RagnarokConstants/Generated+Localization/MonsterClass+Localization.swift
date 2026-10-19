//
//  MonsterClass+Localization.swift
//  RagnarokConstants
//
//  Created by Leon Li on 2026/10/19.
//

import Foundation

extension MonsterClass {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .normal:
            LocalizedStringResource("Normal", table: "MonsterClass", bundle: .module)
        case .boss:
            LocalizedStringResource("Boss", table: "MonsterClass", bundle: .module)
        case .guardian:
            LocalizedStringResource("Guardian", table: "MonsterClass", bundle: .module)
        case .battlefield:
            LocalizedStringResource("Battlefield", table: "MonsterClass", bundle: .module)
        case .event:
            LocalizedStringResource("Event", table: "MonsterClass", bundle: .module)
        }
    }
}
