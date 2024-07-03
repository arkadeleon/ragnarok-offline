//
//  SkillFlag.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/11.
//

import rAthenaCommon

public enum SkillFlag: CaseIterable, CodingKey, Decodable {
    case isQuest
    case isNpc
    case isWedding
    case isSpirit
    case isGuild
    case isSong
    case isEnsemble
    case isTrap
    case targetSelf
    case noTargetSelf
    case partyOnly
    case guildOnly
    case noTargetEnemy
    case isAutoShadowSpell
    case isChorus
    case ignoreBgReduction
    case ignoreGvgReduction
    case disableNearNpc
    case targetTrap
    case ignoreLandProtector
    case allowWhenHidden
    case allowWhenPerforming
    case targetEmperium
    case ignoreKagehumi
    case alterRangeVulture
    case alterRangeSnakeEye
    case alterRangeShadowJump
    case alterRangeRadius
    case alterRangeResearchTrap
    case ignoreHovering
    case allowOnWarg
    case allowOnMado
    case targetManHole
    case targetHidden
    case increaseDanceWithWugDamage
    case ignoreWugBite
    case ignoreAutoGuard
    case ignoreCicada
    case showScale
    case ignoreGtb
    case toggleable

    public var intValue: Int {
        switch self {
        case .isQuest: RA_INF2_ISQUEST
        case .isNpc: RA_INF2_ISNPC
        case .isWedding: RA_INF2_ISWEDDING
        case .isSpirit: RA_INF2_ISSPIRIT
        case .isGuild: RA_INF2_ISGUILD
        case .isSong: RA_INF2_ISSONG
        case .isEnsemble: RA_INF2_ISENSEMBLE
        case .isTrap: RA_INF2_ISTRAP
        case .targetSelf: RA_INF2_TARGETSELF
        case .noTargetSelf: RA_INF2_NOTARGETSELF
        case .partyOnly: RA_INF2_PARTYONLY
        case .guildOnly: RA_INF2_GUILDONLY
        case .noTargetEnemy: RA_INF2_NOTARGETENEMY
        case .isAutoShadowSpell: RA_INF2_ISAUTOSHADOWSPELL
        case .isChorus: RA_INF2_ISCHORUS
        case .ignoreBgReduction: RA_INF2_IGNOREBGREDUCTION
        case .ignoreGvgReduction: RA_INF2_IGNOREGVGREDUCTION
        case .disableNearNpc: RA_INF2_DISABLENEARNPC
        case .targetTrap: RA_INF2_TARGETTRAP
        case .ignoreLandProtector: RA_INF2_IGNORELANDPROTECTOR
        case .allowWhenHidden: RA_INF2_ALLOWWHENHIDDEN
        case .allowWhenPerforming: RA_INF2_ALLOWWHENPERFORMING
        case .targetEmperium: RA_INF2_TARGETEMPERIUM
        case .ignoreKagehumi: RA_INF2_IGNOREKAGEHUMI
        case .alterRangeVulture: RA_INF2_ALTERRANGEVULTURE
        case .alterRangeSnakeEye: RA_INF2_ALTERRANGESNAKEEYE
        case .alterRangeShadowJump: RA_INF2_ALTERRANGESHADOWJUMP
        case .alterRangeRadius: RA_INF2_ALTERRANGERADIUS
        case .alterRangeResearchTrap: RA_INF2_ALTERRANGERESEARCHTRAP
        case .ignoreHovering: RA_INF2_IGNOREHOVERING
        case .allowOnWarg: RA_INF2_ALLOWONWARG
        case .allowOnMado: RA_INF2_ALLOWONMADO
        case .targetManHole: RA_INF2_TARGETMANHOLE
        case .targetHidden: RA_INF2_TARGETHIDDEN
        case .increaseDanceWithWugDamage: RA_INF2_INCREASEDANCEWITHWUGDAMAGE
        case .ignoreWugBite: RA_INF2_IGNOREWUGBITE
        case .ignoreAutoGuard: RA_INF2_IGNOREAUTOGUARD
        case .ignoreCicada: RA_INF2_IGNORECICADA
        case .showScale: RA_INF2_SHOWSCALE
        case .ignoreGtb: RA_INF2_IGNOREGTB
        case .toggleable: RA_INF2_TOGGLEABLE
        }
    }

    public var stringValue: String {
        switch self {
        case .isQuest: "IsQuest"
        case .isNpc: "IsNpc"
        case .isWedding: "IsWedding"
        case .isSpirit: "IsSpirit"
        case .isGuild: "IsGuild"
        case .isSong: "IsSong"
        case .isEnsemble: "IsEnsemble"
        case .isTrap: "IsTrap"
        case .targetSelf: "TargetSelf"
        case .noTargetSelf: "NoTargetSelf"
        case .partyOnly: "PartyOnly"
        case .guildOnly: "GuildOnly"
        case .noTargetEnemy: "NoTargetEnemy"
        case .isAutoShadowSpell: "IsAutoShadowSpell"
        case .isChorus: "IsChorus"
        case .ignoreBgReduction: "IgnoreBgReduction"
        case .ignoreGvgReduction: "IgnoreGvgReduction"
        case .disableNearNpc: "DisableNearNpc"
        case .targetTrap: "TargetTrap"
        case .ignoreLandProtector: "IgnoreLandProtector"
        case .allowWhenHidden: "AllowWhenHidden"
        case .allowWhenPerforming: "AllowWhenPerforming"
        case .targetEmperium: "TargetEmperium"
        case .ignoreKagehumi: "IgnoreKagehumi"
        case .alterRangeVulture: "AlterRangeVulture"
        case .alterRangeSnakeEye: "AlterRangeSnakeEye"
        case .alterRangeShadowJump: "AlterRangeShadowJump"
        case .alterRangeRadius: "AlterRangeRadius"
        case .alterRangeResearchTrap: "AlterRangeResearchTrap"
        case .ignoreHovering: "IgnoreHovering"
        case .allowOnWarg: "AllowOnWarg"
        case .allowOnMado: "AllowOnMado"
        case .targetManHole: "TargetManHole"
        case .targetHidden: "TargetHidden"
        case .increaseDanceWithWugDamage: "IncreaseDanceWithWugDamage"
        case .ignoreWugBite: "IgnoreWugBite"
        case .ignoreAutoGuard: "IgnoreAutoGuard"
        case .ignoreCicada: "IgnoreCicada"
        case .showScale: "ShowScale"
        case .ignoreGtb: "IgnoreGtb"
        case .toggleable: "Toggleable"
        }
    }

    public init?(stringValue: String) {
        if let skillFlag = SkillFlag.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = skillFlag
        } else {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let skillFlag = SkillFlag(stringValue: stringValue) {
            self = skillFlag
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Skill flag does not exist.")
            throw DecodingError.valueNotFound(SkillFlag.self, context)
        }
    }
}
