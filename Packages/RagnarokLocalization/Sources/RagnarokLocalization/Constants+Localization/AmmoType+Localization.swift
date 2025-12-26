//
//  AmmoType+Localization.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2025/12/26.
//

import Foundation
import RagnarokConstants

extension AmmoType {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .arrow:
            LocalizedStringResource("Arrow", table: "AmmoType", bundle: .module)
        case .dagger:
            LocalizedStringResource("Dagger", table: "AmmoType", bundle: .module)
        case .bullet:
            LocalizedStringResource("Bullet", table: "AmmoType", bundle: .module)
        case .shell:
            LocalizedStringResource("Shell", table: "AmmoType", bundle: .module)
        case .grenade:
            LocalizedStringResource("Grenade", table: "AmmoType", bundle: .module)
        case .shuriken:
            LocalizedStringResource("Shuriken", table: "AmmoType", bundle: .module)
        case .kunai:
            LocalizedStringResource("Kunai", table: "AmmoType", bundle: .module)
        case .cannonball:
            LocalizedStringResource("Cannonball", table: "AmmoType", bundle: .module)
        case .throwweapon:
            LocalizedStringResource("Throwweapon", table: "AmmoType", bundle: .module)
        }
    }
}
