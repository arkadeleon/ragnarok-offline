//
//  SkillUnitFlag.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/4.
//

import rAthenaCommon

public enum SkillUnitFlag: Option {
    case noEnemy
    case noReiteration
    case noFootSet
    case noOverlap
    case pathCheck
    case noPc
    case noMob
    case skill
    case dance
    case ensemble
    case song
    case dualMode
    case noKnockback
    case rangedSingleUnit
    case crazyWeedImmune
    case removedByFireRain
    case knockbackGroup
    case hiddenTrap

    public var intValue: Int {
        switch self {
        case .noEnemy: RA_UF_NOENEMY
        case .noReiteration: RA_UF_NOREITERATION
        case .noFootSet: RA_UF_NOFOOTSET
        case .noOverlap: RA_UF_NOOVERLAP
        case .pathCheck: RA_UF_PATHCHECK
        case .noPc: RA_UF_NOPC
        case .noMob: RA_UF_NOMOB
        case .skill: RA_UF_SKILL
        case .dance: RA_UF_DANCE
        case .ensemble: RA_UF_ENSEMBLE
        case .song: RA_UF_SONG
        case .dualMode: RA_UF_DUALMODE
        case .noKnockback: RA_UF_NOKNOCKBACK
        case .rangedSingleUnit: RA_UF_RANGEDSINGLEUNIT
        case .crazyWeedImmune: RA_UF_CRAZYWEEDIMMUNE
        case .removedByFireRain: RA_UF_REMOVEDBYFIRERAIN
        case .knockbackGroup: RA_UF_KNOCKBACKGROUP
        case .hiddenTrap: RA_UF_HIDDENTRAP
        }
    }

    public var stringValue: String {
        switch self {
        case .noEnemy: "NoEnemy"
        case .noReiteration: "NoReiteration"
        case .noFootSet: "NoFootSet"
        case .noOverlap: "NoOverlap"
        case .pathCheck: "PathCheck"
        case .noPc: "NoPc"
        case .noMob: "NoMob"
        case .skill: "Skill"
        case .dance: "Dance"
        case .ensemble: "Ensemble"
        case .song: "Song"
        case .dualMode: "DualMode"
        case .noKnockback: "NoKnockback"
        case .rangedSingleUnit: "RangedSingleUnit"
        case .crazyWeedImmune: "CrazyWeedImmune"
        case .removedByFireRain: "RemovedByFireRain"
        case .knockbackGroup: "KnockbackGroup"
        case .hiddenTrap: "HiddenTrap"
        }
    }
}
