//
//  MonsterMode+Localization.swift
//  RagnarokConstants
//
//  Created by Leon Li on 2026/10/20.
//

import Foundation

extension MonsterMode {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .canmove:
            LocalizedStringResource("Can Move", table: "MonsterMode", bundle: .module)
        case .looter:
            LocalizedStringResource("Looter", table: "MonsterMode", bundle: .module)
        case .aggressive:
            LocalizedStringResource("Aggressive", table: "MonsterMode", bundle: .module)
        case .assist:
            LocalizedStringResource("Assist", table: "MonsterMode", bundle: .module)
        case .castsensoridle:
            LocalizedStringResource("Cast Sensor (Idle)", table: "MonsterMode", bundle: .module)
        case .norandomwalk:
            LocalizedStringResource("No Random Walk", table: "MonsterMode", bundle: .module)
        case .nocast:
            LocalizedStringResource("No Cast", table: "MonsterMode", bundle: .module)
        case .canattack:
            LocalizedStringResource("Can Attack", table: "MonsterMode", bundle: .module)
        case .castsensorchase:
            LocalizedStringResource("Cast Sensor (Chase)", table: "MonsterMode", bundle: .module)
        case .changechase:
            LocalizedStringResource("Change Chase", table: "MonsterMode", bundle: .module)
        case .angry:
            LocalizedStringResource("Angry", table: "MonsterMode", bundle: .module)
        case .changetargetmelee:
            LocalizedStringResource("Change Target (Melee)", table: "MonsterMode", bundle: .module)
        case .changetargetchase:
            LocalizedStringResource("Change Target (Chase)", table: "MonsterMode", bundle: .module)
        case .targetweak:
            LocalizedStringResource("Target Weak", table: "MonsterMode", bundle: .module)
        case .randomtarget:
            LocalizedStringResource("Random Target", table: "MonsterMode", bundle: .module)
        case .ignoremelee:
            LocalizedStringResource("Ignore Melee", table: "MonsterMode", bundle: .module)
        case .ignoremagic:
            LocalizedStringResource("Ignore Magic", table: "MonsterMode", bundle: .module)
        case .ignoreranged:
            LocalizedStringResource("Ignore Ranged", table: "MonsterMode", bundle: .module)
        case .mvp:
            LocalizedStringResource("MVP", table: "MonsterMode", bundle: .module)
        case .ignoremisc:
            LocalizedStringResource("Ignore Misc", table: "MonsterMode", bundle: .module)
        case .knockbackimmune:
            LocalizedStringResource("Knockback Immune", table: "MonsterMode", bundle: .module)
        case .teleportblock:
            LocalizedStringResource("Teleport Block", table: "MonsterMode", bundle: .module)
        case .fixeditemdrop:
            LocalizedStringResource("Fixed Item Drop", table: "MonsterMode", bundle: .module)
        case .detector:
            LocalizedStringResource("Detector", table: "MonsterMode", bundle: .module)
        case .statusimmune:
            LocalizedStringResource("Status Immune", table: "MonsterMode", bundle: .module)
        case .skillimmune:
            LocalizedStringResource("Skill Immune", table: "MonsterMode", bundle: .module)
        }
    }
}
