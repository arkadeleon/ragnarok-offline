//
//  MonsterMode.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/9.
//

import rAthenaCommon

public enum MonsterMode: Option {
    case canMove
    case looter
    case aggressive
    case assist
    case castSensorIdle
    case noRandomWalk
    case noCast
    case canAttack
    case castSensorChase
    case changeChase
    case angry
    case changeTargetMelee
    case changeTargetChase
    case targetWeak
    case randomTarget
    case ignoreMelee
    case ignoreMagic
    case ignoreRanged
    case mvp
    case ignoreMisc
    case knockBackImmune
    case teleportBlock
    case fixedItemDrop
    case detector
    case statusImmune
    case skillImmune

    public var intValue: Int {
        switch self {
        case .canMove: RA_MD_CANMOVE
        case .looter: RA_MD_LOOTER
        case .aggressive: RA_MD_AGGRESSIVE
        case .assist: RA_MD_ASSIST
        case .castSensorIdle: RA_MD_CASTSENSORIDLE
        case .noRandomWalk: RA_MD_NORANDOMWALK
        case .noCast: RA_MD_NOCAST
        case .canAttack: RA_MD_CANATTACK
        case .castSensorChase: RA_MD_CASTSENSORCHASE
        case .changeChase: RA_MD_CHANGECHASE
        case .angry: RA_MD_ANGRY
        case .changeTargetMelee: RA_MD_CHANGETARGETMELEE
        case .changeTargetChase: RA_MD_CHANGETARGETCHASE
        case .targetWeak: RA_MD_TARGETWEAK
        case .randomTarget: RA_MD_RANDOMTARGET
        case .ignoreMelee: RA_MD_IGNOREMELEE
        case .ignoreMagic: RA_MD_IGNOREMAGIC
        case .ignoreRanged: RA_MD_IGNORERANGED
        case .mvp: RA_MD_MVP
        case .ignoreMisc: RA_MD_IGNOREMISC
        case .knockBackImmune: RA_MD_KNOCKBACKIMMUNE
        case .teleportBlock: RA_MD_TELEPORTBLOCK
        case .fixedItemDrop: RA_MD_FIXEDITEMDROP
        case .detector: RA_MD_DETECTOR
        case .statusImmune: RA_MD_STATUSIMMUNE
        case .skillImmune: RA_MD_SKILLIMMUNE
        }
    }

    public var stringValue: String {
        switch self {
        case .canMove: "CanMove"
        case .looter: "Looter"
        case .aggressive: "Aggressive"
        case .assist: "Assist"
        case .castSensorIdle: "CastSensorIdle"
        case .noRandomWalk: "NoRandomWalk"
        case .noCast: "NoCast"
        case .canAttack: "CanAttack"
        case .castSensorChase: "CastSensorChase"
        case .changeChase: "ChangeChase"
        case .angry: "Angry"
        case .changeTargetMelee: "ChangeTargetMelee"
        case .changeTargetChase: "ChangeTargetChase"
        case .targetWeak: "TargetWeak"
        case .randomTarget: "RandomTarget"
        case .ignoreMelee: "IgnoreMelee"
        case .ignoreMagic: "IgnoreMagic"
        case .ignoreRanged: "IgnoreRanged"
        case .mvp: "Mvp"
        case .ignoreMisc: "IgnoreMisc"
        case .knockBackImmune: "KnockBackImmune"
        case .teleportBlock: "TeleportBlock"
        case .fixedItemDrop: "FixedItemDrop"
        case .detector: "Detector"
        case .statusImmune: "StatusImmune"
        case .skillImmune: "SkillImmune"
        }
    }
}
