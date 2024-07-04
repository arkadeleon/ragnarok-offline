//
//  ItemJob.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum ItemJob: Option {
    case acolyte
    case alchemist
    case archer
    case assassin
    case bardDancer
    case blacksmith
    case crusader
    case gunslinger
    case hunter
    case kagerouOboro
    case knight
    case mage
    case merchant
    case monk
    case ninja
    case novice
    case priest
    case rebellion
    case rogue
    case sage
    case soulLinker
    case starGladiator
    case summoner
    case superNovice
    case swordman
    case taekwon
    case thief
    case wizard

    public var intValue: Int {
        switch self {
        case .acolyte: RA_MAPID_ACOLYTE
        case .alchemist: RA_MAPID_ALCHEMIST
        case .archer: RA_MAPID_ARCHER
        case .assassin: RA_MAPID_ASSASSIN
        case .bardDancer: RA_MAPID_BARDDANCER
        case .blacksmith: RA_MAPID_BLACKSMITH
        case .crusader: RA_MAPID_CRUSADER
        case .gunslinger: RA_MAPID_GUNSLINGER
        case .hunter: RA_MAPID_HUNTER
        case .kagerouOboro: RA_MAPID_KAGEROUOBORO
        case .knight: RA_MAPID_KNIGHT
        case .mage: RA_MAPID_MAGE
        case .merchant: RA_MAPID_MERCHANT
        case .monk: RA_MAPID_MONK
        case .ninja: RA_MAPID_NINJA
        case .novice: RA_MAPID_NOVICE
        case .priest: RA_MAPID_PRIEST
        case .rebellion: RA_MAPID_REBELLION
        case .rogue: RA_MAPID_ROGUE
        case .sage: RA_MAPID_SAGE
        case .soulLinker: RA_MAPID_SOUL_LINKER
        case .starGladiator: RA_MAPID_STAR_GLADIATOR
        case .summoner: RA_MAPID_SUMMONER
        case .superNovice: RA_MAPID_SUPER_NOVICE
        case .swordman: RA_MAPID_SWORDMAN
        case .taekwon: RA_MAPID_TAEKWON
        case .thief: RA_MAPID_THIEF
        case .wizard: RA_MAPID_WIZARD
        }
    }

    public var stringValue: String {
        switch self {
        case .acolyte: "Acolyte"
        case .alchemist: "Alchemist"
        case .archer: "Archer"
        case .assassin: "Assassin"
        case .bardDancer: "BardDancer"
        case .blacksmith: "Blacksmith"
        case .crusader: "Crusader"
        case .gunslinger: "Gunslinger"
        case .hunter: "Hunter"
        case .kagerouOboro: "KagerouOboro"
        case .knight: "Knight"
        case .mage: "Mage"
        case .merchant: "Merchant"
        case .monk: "Monk"
        case .ninja: "Ninja"
        case .novice: "Novice"
        case .priest: "Priest"
        case .rebellion: "Rebellion"
        case .rogue: "Rogue"
        case .sage: "Sage"
        case .soulLinker: "SoulLinker"
        case .starGladiator: "StarGladiator"
        case .summoner: "Summoner"
        case .superNovice: "SuperNovice"
        case .swordman: "Swordman"
        case .taekwon: "Taekwon"
        case .thief: "Thief"
        case .wizard: "Wizard"
        }
    }
}
