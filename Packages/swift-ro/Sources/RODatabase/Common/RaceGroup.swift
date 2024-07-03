//
//  RaceGroup.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/9.
//

import rAthenaCommon

public enum RaceGroup: CaseIterable, RawRepresentable, CodingKey, Decodable {
    case goblin
    case kobold
    case orc
    case golem
    case guardian
    case ninja
    case gvg
    case battlefield
    case treasure
    case biolab
    case manuk
    case splendide
    case scaraba
    case oghAtkDef
    case oghHidden
    case bio5SwordmanThief
    case bio5AcolyteMerchant
    case bio5MageArcher
    case bio5Mvp
    case clocktower
    case thanatos
    case faceworm
    case hearthunter
    case rockridge
    case wernerLab
    case templeDemon
    case illusionVampire
    case malangdo
    case ep172Alpha
    case ep172Beta
    case ep172Bath

    public var rawValue: Int {
        switch self {
        case .goblin: RA_RC2_GOBLIN
        case .kobold: RA_RC2_KOBOLD
        case .orc: RA_RC2_ORC
        case .golem: RA_RC2_GOLEM
        case .guardian: RA_RC2_GOLEM + 1
        case .ninja: RA_RC2_NINJA
        case .gvg: RA_RC2_GVG
        case .battlefield: RA_RC2_GVG + 1
        case .treasure: RA_RC2_TREASURE
        case .biolab: RA_RC2_BIOLAB
        case .manuk: RA_RC2_MANUK
        case .splendide: RA_RC2_SPLENDIDE
        case .scaraba: RA_RC2_SCARABA
        case .oghAtkDef: RA_RC2_OGH_ATK_DEF
        case .oghHidden: RA_RC2_OGH_HIDDEN
        case .bio5SwordmanThief: RA_RC2_BIO5_SWORDMAN_THIEF
        case .bio5AcolyteMerchant: RA_RC2_BIO5_ACOLYTE_MERCHANT
        case .bio5MageArcher: RA_RC2_BIO5_MAGE_ARCHER
        case .bio5Mvp: RA_RC2_BIO5_MVP
        case .clocktower: RA_RC2_CLOCKTOWER
        case .thanatos: RA_RC2_THANATOS
        case .faceworm: RA_RC2_FACEWORM
        case .hearthunter: RA_RC2_HEARTHUNTER
        case .rockridge: RA_RC2_ROCKRIDGE
        case .wernerLab: RA_RC2_WERNER_LAB
        case .templeDemon: RA_RC2_TEMPLE_DEMON
        case .illusionVampire: RA_RC2_ILLUSION_VAMPIRE
        case .malangdo: RA_RC2_MALANGDO
        case .ep172Alpha: RA_RC2_EP172ALPHA
        case .ep172Beta: RA_RC2_EP172BETA
        case .ep172Bath: RA_RC2_EP172BATH
        }
    }

    public var stringValue: String {
        switch self {
        case .goblin: "Goblin"
        case .kobold: "Kobold"
        case .orc: "Orc"
        case .golem: "Golem"
        case .guardian: "Guardian"
        case .ninja: "Ninja"
        case .gvg: "Gvg"
        case .battlefield: "Battlefield"
        case .treasure: "Treasure"
        case .biolab: "Biolab"
        case .manuk: "Manuk"
        case .splendide: "Splendide"
        case .scaraba: "Scaraba"
        case .oghAtkDef: "Ogh_Atk_Def"
        case .oghHidden: "Ogh_Hidden"
        case .bio5SwordmanThief: "Bio5_Swordman_Thief"
        case .bio5AcolyteMerchant: "Bio5_Acolyte_Merchant"
        case .bio5MageArcher: "Bio5_Mage_Archer"
        case .bio5Mvp: "Bio5_Mvp"
        case .clocktower: "Clocktower"
        case .thanatos: "Thanatos"
        case .faceworm: "Faceworm"
        case .hearthunter: "Hearthunter"
        case .rockridge: "Rockridge"
        case .wernerLab: "Werner_Lab"
        case .templeDemon: "Temple_Demon"
        case .illusionVampire: "Illusion_Vampire"
        case .malangdo: "Malangdo"
        case .ep172Alpha: "EP172ALPHA"
        case .ep172Beta: "EP172BETA"
        case .ep172Bath: "EP172BATH"
        }
    }
}
