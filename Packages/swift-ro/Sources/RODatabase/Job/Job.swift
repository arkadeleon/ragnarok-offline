//
//  Job.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum Job: Option {
    case novice
    case swordman
    case mage
    case archer
    case acolyte
    case merchant
    case thief
    case knight
    case priest
    case wizard
    case blacksmith
    case hunter
    case assassin
    case knight2
    case crusader
    case monk
    case sage
    case rogue
    case alchemist
    case bard
    case dancer
    case crusader2
    case wedding
    case superNovice
    case gunslinger
    case ninja
    case christmas
    case summer
    case hanbok
    case oktoberfest
    case summer2
    case noviceHigh
    case swordmanHigh
    case mageHigh
    case archerHigh
    case acolyteHigh
    case merchantHigh
    case thiefHigh
    case lordKnight
    case highPriest
    case highWizard
    case whitesmith
    case sniper
    case assassinCross
    case lordKnight2
    case paladin
    case champion
    case professor
    case stalker
    case creator
    case clown
    case gypsy
    case paladin2
    case baby
    case babySwordman
    case babyMage
    case babyArcher
    case babyAcolyte
    case babyMerchant
    case babyThief
    case babyKnight
    case babyPriest
    case babyWizard
    case babyBlacksmith
    case babyHunter
    case babyAssassin
    case babyKnight2
    case babyCrusader
    case babyMonk
    case babySage
    case babyRogue
    case babyAlchemist
    case babyBard
    case babyDancer
    case babyCrusader2
    case superBaby
    case taekwon
    case starGladiator
    case starGladiator2
    case soulLinker
    case gangsi
    case deathKnight
    case darkCollector
    case runeKnight
    case warlock
    case ranger
    case archBishop
    case mechanic
    case guillotineCross
    case runeKnightT
    case warlockT
    case rangerT
    case archBishopT
    case mechanicT
    case guillotineCrossT
    case royalGuard
    case sorcerer
    case minstrel
    case wanderer
    case sura
    case genetic
    case shadowChaser
    case royalGuardT
    case sorcererT
    case minstrelT
    case wandererT
    case suraT
    case geneticT
    case shadowChaserT
    case runeKnight2
    case runeKnightT2
    case royalGuard2
    case royalGuardT2
    case ranger2
    case rangerT2
    case mechanic2
    case mechanicT2
    case babyRuneKnight
    case babyWarlock
    case babyRanger
    case babyArchBishop
    case babyMechanic
    case babyGuillotineCross
    case babyRoyalGuard
    case babySorcerer
    case babyMinstrel
    case babyWanderer
    case babySura
    case babyGenetic
    case babyShadowChaser
    case babyRuneKnight2
    case babyRoyalGuard2
    case babyRanger2
    case babyMechanic2
    case superNoviceE
    case superBabyE
    case kagerou
    case oboro
    case rebellion
    case summoner
    case babySummoner
    case babyNinja
    case babyKagerou
    case babyOboro
    case babyTaekwon
    case babyStarGladiator
    case babySoulLinker
    case babyGunslinger
    case babyRebellion
    case babyStarGladiator2
    case starEmperor
    case soulReaper
    case babyStarEmperor
    case babySoulReaper
    case starEmperor2
    case babyStarEmperor2
    case dragonKnight
    case meister
    case shadowCross
    case archMage
    case cardinal
    case windhawk
    case imperialGuard
    case biolo
    case abyssChaser
    case elementalMaster
    case inquisitor
    case troubadour
    case trouvere
    case windhawk2
    case meister2
    case dragonKnight2
    case imperialGuard2
    case skyEmperor
    case soulAscetic
    case shinkiro
    case shiranui
    case nightWatch
    case hyperNovice
    case spiritHandler
    case skyEmperor2

    public var intValue: Int {
        switch self {
        case .novice: RA_JOB_NOVICE
        case .swordman: RA_JOB_SWORDMAN
        case .mage: RA_JOB_MAGE
        case .archer: RA_JOB_ARCHER
        case .acolyte: RA_JOB_ACOLYTE
        case .merchant: RA_JOB_MERCHANT
        case .thief: RA_JOB_THIEF
        case .knight: RA_JOB_KNIGHT
        case .priest: RA_JOB_PRIEST
        case .wizard: RA_JOB_WIZARD
        case .blacksmith: RA_JOB_BLACKSMITH
        case .hunter: RA_JOB_HUNTER
        case .assassin: RA_JOB_ASSASSIN
        case .knight2: RA_JOB_KNIGHT2
        case .crusader: RA_JOB_CRUSADER
        case .monk: RA_JOB_MONK
        case .sage: RA_JOB_SAGE
        case .rogue: RA_JOB_ROGUE
        case .alchemist: RA_JOB_ALCHEMIST
        case .bard: RA_JOB_BARD
        case .dancer: RA_JOB_DANCER
        case .crusader2: RA_JOB_CRUSADER2
        case .wedding: RA_JOB_WEDDING
        case .superNovice: RA_JOB_SUPER_NOVICE
        case .gunslinger: RA_JOB_GUNSLINGER
        case .ninja: RA_JOB_NINJA
        case .christmas: RA_JOB_XMAS
        case .summer: RA_JOB_SUMMER
        case .hanbok: RA_JOB_HANBOK
        case .oktoberfest: RA_JOB_OKTOBERFEST
        case .summer2: RA_JOB_SUMMER2
        case .noviceHigh: RA_JOB_NOVICE_HIGH
        case .swordmanHigh: RA_JOB_SWORDMAN_HIGH
        case .mageHigh: RA_JOB_MAGE_HIGH
        case .archerHigh: RA_JOB_ARCHER_HIGH
        case .acolyteHigh: RA_JOB_ACOLYTE_HIGH
        case .merchantHigh: RA_JOB_MERCHANT_HIGH
        case .thiefHigh: RA_JOB_THIEF_HIGH
        case .lordKnight: RA_JOB_LORD_KNIGHT
        case .highPriest: RA_JOB_HIGH_PRIEST
        case .highWizard: RA_JOB_HIGH_WIZARD
        case .whitesmith: RA_JOB_WHITESMITH
        case .sniper: RA_JOB_SNIPER
        case .assassinCross: RA_JOB_ASSASSIN_CROSS
        case .lordKnight2: RA_JOB_LORD_KNIGHT2
        case .paladin: RA_JOB_PALADIN
        case .champion: RA_JOB_CHAMPION
        case .professor: RA_JOB_PROFESSOR
        case .stalker: RA_JOB_STALKER
        case .creator: RA_JOB_CREATOR
        case .clown: RA_JOB_CLOWN
        case .gypsy: RA_JOB_GYPSY
        case .paladin2: RA_JOB_PALADIN2
        case .baby: RA_JOB_BABY
        case .babySwordman: RA_JOB_BABY_SWORDMAN
        case .babyMage: RA_JOB_BABY_MAGE
        case .babyArcher: RA_JOB_BABY_ARCHER
        case .babyAcolyte: RA_JOB_BABY_ACOLYTE
        case .babyMerchant: RA_JOB_BABY_MERCHANT
        case .babyThief: RA_JOB_BABY_THIEF
        case .babyKnight: RA_JOB_BABY_KNIGHT
        case .babyPriest: RA_JOB_BABY_PRIEST
        case .babyWizard: RA_JOB_BABY_WIZARD
        case .babyBlacksmith: RA_JOB_BABY_BLACKSMITH
        case .babyHunter: RA_JOB_BABY_HUNTER
        case .babyAssassin: RA_JOB_BABY_ASSASSIN
        case .babyKnight2: RA_JOB_BABY_KNIGHT2
        case .babyCrusader: RA_JOB_BABY_CRUSADER
        case .babyMonk: RA_JOB_BABY_MONK
        case .babySage: RA_JOB_BABY_SAGE
        case .babyRogue: RA_JOB_BABY_ROGUE
        case .babyAlchemist: RA_JOB_BABY_ALCHEMIST
        case .babyBard: RA_JOB_BABY_BARD
        case .babyDancer: RA_JOB_BABY_DANCER
        case .babyCrusader2: RA_JOB_BABY_CRUSADER2
        case .superBaby: RA_JOB_SUPER_BABY
        case .taekwon: RA_JOB_TAEKWON
        case .starGladiator: RA_JOB_STAR_GLADIATOR
        case .starGladiator2: RA_JOB_STAR_GLADIATOR2
        case .soulLinker: RA_JOB_SOUL_LINKER
        case .gangsi: RA_JOB_GANGSI
        case .deathKnight: RA_JOB_DEATH_KNIGHT
        case .darkCollector: RA_JOB_DARK_COLLECTOR
        case .runeKnight: RA_JOB_RUNE_KNIGHT
        case .warlock: RA_JOB_WARLOCK
        case .ranger: RA_JOB_RANGER
        case .archBishop: RA_JOB_ARCH_BISHOP
        case .mechanic: RA_JOB_MECHANIC
        case .guillotineCross: RA_JOB_GUILLOTINE_CROSS
        case .runeKnightT: RA_JOB_RUNE_KNIGHT_T
        case .warlockT: RA_JOB_WARLOCK_T
        case .rangerT: RA_JOB_RANGER_T
        case .archBishopT: RA_JOB_ARCH_BISHOP_T
        case .mechanicT: RA_JOB_MECHANIC_T
        case .guillotineCrossT: RA_JOB_GUILLOTINE_CROSS_T
        case .royalGuard: RA_JOB_ROYAL_GUARD
        case .sorcerer: RA_JOB_SORCERER
        case .minstrel: RA_JOB_MINSTREL
        case .wanderer: RA_JOB_WANDERER
        case .sura: RA_JOB_SURA
        case .genetic: RA_JOB_GENETIC
        case .shadowChaser: RA_JOB_SHADOW_CHASER
        case .royalGuardT: RA_JOB_ROYAL_GUARD_T
        case .sorcererT: RA_JOB_SORCERER_T
        case .minstrelT: RA_JOB_MINSTREL_T
        case .wandererT: RA_JOB_WANDERER_T
        case .suraT: RA_JOB_SURA_T
        case .geneticT: RA_JOB_GENETIC_T
        case .shadowChaserT: RA_JOB_SHADOW_CHASER_T
        case .runeKnight2: RA_JOB_RUNE_KNIGHT2
        case .runeKnightT2: RA_JOB_RUNE_KNIGHT_T2
        case .royalGuard2: RA_JOB_ROYAL_GUARD2
        case .royalGuardT2: RA_JOB_ROYAL_GUARD_T2
        case .ranger2: RA_JOB_RANGER2
        case .rangerT2: RA_JOB_RANGER_T2
        case .mechanic2: RA_JOB_MECHANIC2
        case .mechanicT2: RA_JOB_MECHANIC_T2
        case .babyRuneKnight: RA_JOB_BABY_RUNE_KNIGHT
        case .babyWarlock: RA_JOB_BABY_WARLOCK
        case .babyRanger: RA_JOB_BABY_RANGER
        case .babyArchBishop: RA_JOB_BABY_ARCH_BISHOP
        case .babyMechanic: RA_JOB_BABY_MECHANIC
        case .babyGuillotineCross: RA_JOB_BABY_GUILLOTINE_CROSS
        case .babyRoyalGuard: RA_JOB_BABY_ROYAL_GUARD
        case .babySorcerer: RA_JOB_BABY_SORCERER
        case .babyMinstrel: RA_JOB_BABY_MINSTREL
        case .babyWanderer: RA_JOB_BABY_WANDERER
        case .babySura: RA_JOB_BABY_SURA
        case .babyGenetic: RA_JOB_BABY_GENETIC
        case .babyShadowChaser: RA_JOB_BABY_SHADOW_CHASER
        case .babyRuneKnight2: RA_JOB_BABY_RUNE_KNIGHT2
        case .babyRoyalGuard2: RA_JOB_BABY_ROYAL_GUARD2
        case .babyRanger2: RA_JOB_BABY_RANGER2
        case .babyMechanic2: RA_JOB_BABY_MECHANIC2
        case .superNoviceE: RA_JOB_SUPER_NOVICE_E
        case .superBabyE: RA_JOB_SUPER_BABY_E
        case .kagerou: RA_JOB_KAGEROU
        case .oboro: RA_JOB_OBORO
        case .rebellion: RA_JOB_REBELLION
        case .summoner: RA_JOB_SUMMONER
        case .babySummoner: RA_JOB_BABY_SUMMONER
        case .babyNinja: RA_JOB_BABY_NINJA
        case .babyKagerou: RA_JOB_BABY_KAGEROU
        case .babyOboro: RA_JOB_BABY_OBORO
        case .babyTaekwon: RA_JOB_BABY_TAEKWON
        case .babyStarGladiator: RA_JOB_BABY_STAR_GLADIATOR
        case .babySoulLinker: RA_JOB_BABY_SOUL_LINKER
        case .babyGunslinger: RA_JOB_BABY_GUNSLINGER
        case .babyRebellion: RA_JOB_BABY_REBELLION
        case .babyStarGladiator2: RA_JOB_BABY_STAR_GLADIATOR2
        case .starEmperor: RA_JOB_STAR_EMPEROR
        case .soulReaper: RA_JOB_SOUL_REAPER
        case .babyStarEmperor: RA_JOB_BABY_STAR_EMPEROR
        case .babySoulReaper: RA_JOB_BABY_SOUL_REAPER
        case .starEmperor2: RA_JOB_STAR_EMPEROR2
        case .babyStarEmperor2: RA_JOB_BABY_STAR_EMPEROR2
        case .dragonKnight: RA_JOB_DRAGON_KNIGHT
        case .meister: RA_JOB_MEISTER
        case .shadowCross: RA_JOB_SHADOW_CROSS
        case .archMage: RA_JOB_ARCH_MAGE
        case .cardinal: RA_JOB_CARDINAL
        case .windhawk: RA_JOB_WINDHAWK
        case .imperialGuard: RA_JOB_IMPERIAL_GUARD
        case .biolo: RA_JOB_BIOLO
        case .abyssChaser: RA_JOB_ABYSS_CHASER
        case .elementalMaster: RA_JOB_ELEMENTAL_MASTER
        case .inquisitor: RA_JOB_INQUISITOR
        case .troubadour: RA_JOB_TROUBADOUR
        case .trouvere: RA_JOB_TROUVERE
        case .windhawk2: RA_JOB_WINDHAWK2
        case .meister2: RA_JOB_MEISTER2
        case .dragonKnight2: RA_JOB_DRAGON_KNIGHT2
        case .imperialGuard2: RA_JOB_IMPERIAL_GUARD2
        case .skyEmperor: RA_JOB_SKY_EMPEROR
        case .soulAscetic: RA_JOB_SOUL_ASCETIC
        case .shinkiro: RA_JOB_SHINKIRO
        case .shiranui: RA_JOB_SHIRANUI
        case .nightWatch: RA_JOB_NIGHT_WATCH
        case .hyperNovice: RA_JOB_HYPER_NOVICE
        case .spiritHandler: RA_JOB_SPIRIT_HANDLER
        case .skyEmperor2: RA_JOB_SKY_EMPEROR2
        }
    }

    public var stringValue: String {
        switch self {
        case .novice: "Novice"
        case .swordman: "Swordman"
        case .mage: "Mage"
        case .archer: "Archer"
        case .acolyte: "Acolyte"
        case .merchant: "Merchant"
        case .thief: "Thief"
        case .knight: "Knight"
        case .priest: "Priest"
        case .wizard: "Wizard"
        case .blacksmith: "Blacksmith"
        case .hunter: "Hunter"
        case .assassin: "Assassin"
        case .knight2: "Knight2"
        case .crusader: "Crusader"
        case .monk: "Monk"
        case .sage: "Sage"
        case .rogue: "Rogue"
        case .alchemist: "Alchemist"
        case .bard: "Bard"
        case .dancer: "Dancer"
        case .crusader2: "Crusader2"
        case .wedding: "Wedding"
        case .superNovice: "Supernovice"
        case .gunslinger: "Gunslinger"
        case .ninja: "Ninja"
        case .christmas: "Christmas"
        case .summer: "Summer"
        case .hanbok: "Hanbok"
        case .oktoberfest: "Oktoberfest"
        case .summer2: "Summer2"
        case .noviceHigh: "Novice_High"
        case .swordmanHigh: "Swordman_High"
        case .mageHigh: "Mage_High"
        case .archerHigh: "Archer_High"
        case .acolyteHigh: "Acolyte_High"
        case .merchantHigh: "Merchant_High"
        case .thiefHigh: "Thief_High"
        case .lordKnight: "Lord_Knight"
        case .highPriest: "High_Priest"
        case .highWizard: "High_Wizard"
        case .whitesmith: "Whitesmith"
        case .sniper: "Sniper"
        case .assassinCross: "Assassin_Cross"
        case .lordKnight2: "Lord_Knight2"
        case .paladin: "Paladin"
        case .champion: "Champion"
        case .professor: "Professor"
        case .stalker: "Stalker"
        case .creator: "Creator"
        case .clown: "Clown"
        case .gypsy: "Gypsy"
        case .paladin2: "Paladin2"
        case .baby: "Baby"
        case .babySwordman: "Baby_Swordman"
        case .babyMage: "Baby_Mage"
        case .babyArcher: "Baby_Archer"
        case .babyAcolyte: "Baby_Acolyte"
        case .babyMerchant: "Baby_Merchant"
        case .babyThief: "Baby_Thief"
        case .babyKnight: "Baby_Knight"
        case .babyPriest: "Baby_Priest"
        case .babyWizard: "Baby_Wizard"
        case .babyBlacksmith: "Baby_Blacksmith"
        case .babyHunter: "Baby_Hunter"
        case .babyAssassin: "Baby_Assassin"
        case .babyKnight2: "Baby_Knight2"
        case .babyCrusader: "Baby_Crusader"
        case .babyMonk: "Baby_Monk"
        case .babySage: "Baby_Sage"
        case .babyRogue: "Baby_Rogue"
        case .babyAlchemist: "Baby_Alchemist"
        case .babyBard: "Baby_Bard"
        case .babyDancer: "Baby_Dancer"
        case .babyCrusader2: "Baby_Crusader2"
        case .superBaby: "Super_Baby"
        case .taekwon: "Taekwon"
        case .starGladiator: "Star_Gladiator"
        case .starGladiator2: "Star_Gladiator2"
        case .soulLinker: "Soul_Linker"
        case .gangsi: "Gangsi"
        case .deathKnight: "Death_Knight"
        case .darkCollector: "Dark_Collector"
        case .runeKnight: "Rune_Knight"
        case .warlock: "Warlock"
        case .ranger: "Ranger"
        case .archBishop: "Arch_Bishop"
        case .mechanic: "Mechanic"
        case .guillotineCross: "Guillotine_Cross"
        case .runeKnightT: "Rune_Knight_T"
        case .warlockT: "Warlock_T"
        case .rangerT: "Ranger_T"
        case .archBishopT: "Arch_Bishop_T"
        case .mechanicT: "Mechanic_T"
        case .guillotineCrossT: "Guillotine_Cross_T"
        case .royalGuard: "Royal_Guard"
        case .sorcerer: "Sorcerer"
        case .minstrel: "Minstrel"
        case .wanderer: "Wanderer"
        case .sura: "Sura"
        case .genetic: "Genetic"
        case .shadowChaser: "Shadow_Chaser"
        case .royalGuardT: "Royal_Guard_T"
        case .sorcererT: "Sorcerer_T"
        case .minstrelT: "Minstrel_T"
        case .wandererT: "Wanderer_T"
        case .suraT: "Sura_T"
        case .geneticT: "Genetic_T"
        case .shadowChaserT: "Shadow_Chaser_T"
        case .runeKnight2: "Rune_Knight2"
        case .runeKnightT2: "Rune_Knight_T2"
        case .royalGuard2: "Royal_Guard2"
        case .royalGuardT2: "Royal_Guard_T2"
        case .ranger2: "Ranger2"
        case .rangerT2: "Ranger_T2"
        case .mechanic2: "Mechanic2"
        case .mechanicT2: "Mechanic_T2"
        case .babyRuneKnight: "Baby_Rune_Knight"
        case .babyWarlock: "Baby_Warlock"
        case .babyRanger: "Baby_Ranger"
        case .babyArchBishop: "Baby_Arch_Bishop"
        case .babyMechanic: "Baby_Mechanic"
        case .babyGuillotineCross: "Baby_Guillotine_Cross"
        case .babyRoyalGuard: "Baby_Royal_Guard"
        case .babySorcerer: "Baby_Sorcerer"
        case .babyMinstrel: "Baby_Minstrel"
        case .babyWanderer: "Baby_Wanderer"
        case .babySura: "Baby_Sura"
        case .babyGenetic: "Baby_Genetic"
        case .babyShadowChaser: "Baby_Shadow_Chaser"
        case .babyRuneKnight2: "Baby_Rune_Knight2"
        case .babyRoyalGuard2: "Baby_Royal_Guard2"
        case .babyRanger2: "Baby_Ranger2"
        case .babyMechanic2: "Baby_Mechanic2"
        case .superNoviceE: "Super_Novice_E"
        case .superBabyE: "Super_Baby_E"
        case .kagerou: "Kagerou"
        case .oboro: "Oboro"
        case .rebellion: "Rebellion"
        case .summoner: "Summoner"
        case .babySummoner: "Baby_Summoner"
        case .babyNinja: "Baby_Ninja"
        case .babyKagerou: "Baby_Kagerou"
        case .babyOboro: "Baby_Oboro"
        case .babyTaekwon: "Baby_Taekwon"
        case .babyStarGladiator: "Baby_Star_Gladiator"
        case .babySoulLinker: "Baby_Soul_Linker"
        case .babyGunslinger: "Baby_Gunslinger"
        case .babyRebellion: "Baby_Rebellion"
        case .babyStarGladiator2: "Baby_Star_Gladiator2"
        case .starEmperor: "Star_Emperor"
        case .soulReaper: "Soul_Reaper"
        case .babyStarEmperor: "Baby_Star_Emperor"
        case .babySoulReaper: "Baby_Soul_Reaper"
        case .starEmperor2: "Star_Emperor2"
        case .babyStarEmperor2: "Baby_Star_Emperor2"
        case .dragonKnight: "Dragon_Knight"
        case .meister: "Meister"
        case .shadowCross: "Shadow_Cross"
        case .archMage: "Arch_Mage"
        case .cardinal: "Cardinal"
        case .windhawk: "Windhawk"
        case .imperialGuard: "Imperial_Guard"
        case .biolo: "Biolo"
        case .abyssChaser: "Abyss_Chaser"
        case .elementalMaster: "Elemental_Master"
        case .inquisitor: "Inquisitor"
        case .troubadour: "Troubadour"
        case .trouvere: "Trouvere"
        case .windhawk2: "Windhawk2"
        case .meister2: "Meister2"
        case .dragonKnight2: "Dragon_Knight2"
        case .imperialGuard2: "Imperial_Guard2"
        case .skyEmperor: "Sky_Emperor"
        case .soulAscetic: "Soul_Ascetic"
        case .shinkiro: "Shinkiro"
        case .shiranui: "Shiranui"
        case .nightWatch: "Night_Watch"
        case .hyperNovice: "Hyper_Novice"
        case .spiritHandler: "Spirit_Handler"
        case .skyEmperor2: "Sky_Emperor2"
        }
    }
}
