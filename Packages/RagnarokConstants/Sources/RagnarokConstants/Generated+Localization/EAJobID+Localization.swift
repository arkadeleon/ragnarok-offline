//
//  EAJobID+Localization.swift
//  RagnarokConstants
//
//  Created by Leon Li on 2026/10/20.
//

import Foundation

extension EAJobID {
    public var localizedName: LocalizedStringResource? {
        switch self {
        case .novice:
            LocalizedStringResource("Novice", table: "EAJobID", bundle: .module)
        case .swordman:
            LocalizedStringResource("Swordman", table: "EAJobID", bundle: .module)
        case .mage:
            LocalizedStringResource("Magician", table: "EAJobID", bundle: .module)
        case .archer:
            LocalizedStringResource("Archer", table: "EAJobID", bundle: .module)
        case .acolyte:
            LocalizedStringResource("Acolyte", table: "EAJobID", bundle: .module)
        case .merchant:
            LocalizedStringResource("Merchant", table: "EAJobID", bundle: .module)
        case .thief:
            LocalizedStringResource("Thief", table: "EAJobID", bundle: .module)
        case .taekwon:
            LocalizedStringResource("Taekwon", table: "EAJobID", bundle: .module)
        case .gunslinger:
            LocalizedStringResource("Gunslinger", table: "EAJobID", bundle: .module)
        case .ninja:
            LocalizedStringResource("Ninja", table: "EAJobID", bundle: .module)
        case .summoner:
            LocalizedStringResource("Summoner", table: "EAJobID", bundle: .module)
        case .super_novice:
            LocalizedStringResource("Super Novice", table: "EAJobID", bundle: .module)
        case .knight:
            LocalizedStringResource("Knight", table: "EAJobID", bundle: .module)
        case .wizard:
            LocalizedStringResource("Wizard", table: "EAJobID", bundle: .module)
        case .hunter:
            LocalizedStringResource("Hunter", table: "EAJobID", bundle: .module)
        case .priest:
            LocalizedStringResource("Priest", table: "EAJobID", bundle: .module)
        case .blacksmith:
            LocalizedStringResource("Blacksmith", table: "EAJobID", bundle: .module)
        case .assassin:
            LocalizedStringResource("Assassin", table: "EAJobID", bundle: .module)
        case .star_gladiator:
            LocalizedStringResource("Star Gladiator", table: "EAJobID", bundle: .module)
        case .rebellion:
            LocalizedStringResource("Rebellion", table: "EAJobID", bundle: .module)
        case .kagerouoboro:
            LocalizedStringResource("Kagerou / Oboro", table: "EAJobID", bundle: .module)
        case .spirit_handler:
            LocalizedStringResource("Spirit Handler", table: "EAJobID", bundle: .module)
        case .crusader:
            LocalizedStringResource("Crusader", table: "EAJobID", bundle: .module)
        case .sage:
            LocalizedStringResource("Sage", table: "EAJobID", bundle: .module)
        case .barddancer:
            LocalizedStringResource("Bard / Dancer", table: "EAJobID", bundle: .module)
        case .monk:
            LocalizedStringResource("Monk", table: "EAJobID", bundle: .module)
        case .alchemist:
            LocalizedStringResource("Alchemist", table: "EAJobID", bundle: .module)
        case .rogue:
            LocalizedStringResource("Rogue", table: "EAJobID", bundle: .module)
        case .soul_linker:
            LocalizedStringResource("Soul Linker", table: "EAJobID", bundle: .module)
        default:
            nil
        }
    }
}
