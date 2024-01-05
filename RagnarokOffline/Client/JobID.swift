//
//  JobID.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/22.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import rAthenaMap

struct JobID: RawRepresentable {
    let rawValue: Int

    var resourceName: String {
        switch rawValue {
        case RA_JOB_NOVICE, RA_JOB_NOVICE_HIGH, RA_JOB_BABY: "초보자"

        case RA_JOB_SWORDMAN, RA_JOB_SWORDMAN_HIGH, RA_JOB_BABY_SWORDMAN: "검사"
        case RA_JOB_MAGE, RA_JOB_MAGE_HIGH, RA_JOB_BABY_MAGE: "마법사"
        case RA_JOB_ARCHER, RA_JOB_ARCHER_HIGH, RA_JOB_BABY_ARCHER: "궁수"
        case RA_JOB_ACOLYTE, RA_JOB_ACOLYTE_HIGH, RA_JOB_BABY_ACOLYTE: "성직자"
        case RA_JOB_MERCHANT, RA_JOB_MERCHANT_HIGH, RA_JOB_BABY_MERCHANT: "상인"
        case RA_JOB_THIEF, RA_JOB_THIEF_HIGH, RA_JOB_BABY_THIEF: "도둑"

        case RA_JOB_KNIGHT, RA_JOB_BABY_KNIGHT: "기사"
        case RA_JOB_PRIEST, RA_JOB_BABY_PRIEST: "프리스트"
        case RA_JOB_WIZARD, RA_JOB_BABY_WIZARD: "위저드"
        case RA_JOB_BLACKSMITH, RA_JOB_BABY_BLACKSMITH: "제철공"
        case RA_JOB_HUNTER, RA_JOB_BABY_HUNTER: "헌터"
        case RA_JOB_ASSASSIN, RA_JOB_BABY_ASSASSIN: "어세신"
        case RA_JOB_KNIGHT2, RA_JOB_BABY_KNIGHT2: "페코페코_기사"

        case RA_JOB_CRUSADER, RA_JOB_BABY_CRUSADER: "크루세이더"
        case RA_JOB_MONK, RA_JOB_BABY_MONK: "몽크"
        case RA_JOB_SAGE, RA_JOB_BABY_SAGE: "세이지"
        case RA_JOB_ROGUE, RA_JOB_BABY_ROGUE: "로그"
        case RA_JOB_ALCHEMIST, RA_JOB_BABY_ALCHEMIST: "연금술사"
        case RA_JOB_BARD, RA_JOB_BABY_BARD: "바드"
        case RA_JOB_DANCER, RA_JOB_BABY_DANCER: "무희"
        case RA_JOB_CRUSADER2, RA_JOB_BABY_CRUSADER2: "신페코크루세이더"

        case RA_JOB_SUPER_NOVICE: "슈퍼노비스"
        case RA_JOB_GUNSLINGER: "건너"
        case RA_JOB_NINJA: "닌자"
        case RA_JOB_TAEKWON: "태권소년"
        case RA_JOB_STAR_GLADIATOR: "권성"
        case RA_JOB_STAR_GLADIATOR2: "권성융합"
        case RA_JOB_SOUL_LINKER: "소울링커"

        case RA_JOB_WEDDING: "결혼"
        case RA_JOB_XMAS: "산타"
        case RA_JOB_SUMMER: "여름"

        case RA_JOB_LORD_KNIGHT: "로드나이트"
        case RA_JOB_HIGH_PRIEST: "하이프리"
        case RA_JOB_HIGH_WIZARD: "하이위저드"
        case RA_JOB_WHITESMITH: "화이트스미스"
        case RA_JOB_SNIPER: "스나이퍼"
        case RA_JOB_ASSASSIN_CROSS: "어쌔신크로스"
        case RA_JOB_LORD_KNIGHT2: "로드페코"

        case RA_JOB_PALADIN: "팔라딘"
        case RA_JOB_CHAMPION: "챔피온"
        case RA_JOB_PROFESSOR: "프로페서"
        case RA_JOB_STALKER: "스토커"
        case RA_JOB_CREATOR: "크리에이터"
        case RA_JOB_CLOWN: "클라운"
        case RA_JOB_GYPSY: "집시"
        case RA_JOB_PALADIN2: "페코팔라딘"

        case RA_JOB_RUNE_KNIGHT, RA_JOB_RUNE_KNIGHT_T, RA_JOB_BABY_RUNE_KNIGHT: "룬나이트"
        case RA_JOB_WARLOCK, RA_JOB_WARLOCK_T, RA_JOB_BABY_WARLOCK: "워록"
        case RA_JOB_RANGER, RA_JOB_RANGER_T, RA_JOB_BABY_RANGER: "레인져"
        case RA_JOB_ARCH_BISHOP, RA_JOB_ARCH_BISHOP_T, RA_JOB_BABY_ARCH_BISHOP: "아크비숍"
        case RA_JOB_MECHANIC, RA_JOB_MECHANIC_T, RA_JOB_BABY_MECHANIC: "미케닉"
        case RA_JOB_GUILLOTINE_CROSS, RA_JOB_GUILLOTINE_CROSS_T, RA_JOB_BABY_GUILLOTINE_CROSS: "길로틴크로스"

        case RA_JOB_ROYAL_GUARD, RA_JOB_ROYAL_GUARD_T, RA_JOB_BABY_ROYAL_GUARD: "가드"
        case RA_JOB_SORCERER, RA_JOB_SORCERER_T, RA_JOB_BABY_SORCERER: "소서러"
        case RA_JOB_MINSTREL, RA_JOB_MINSTREL_T, RA_JOB_BABY_MINSTREL: "민스트럴"
        case RA_JOB_WANDERER, RA_JOB_WANDERER_T, RA_JOB_BABY_WANDERER: "원더러"
        case RA_JOB_SURA, RA_JOB_SURA_T, RA_JOB_BABY_SURA: "슈라"
        case RA_JOB_GENETIC, RA_JOB_GENETIC_T, RA_JOB_BABY_GENETIC: "제네릭"
        case RA_JOB_SHADOW_CHASER, RA_JOB_SHADOW_CHASER_T, RA_JOB_BABY_SHADOW_CHASER: "쉐도우체이서"

        case RA_JOB_RUNE_KNIGHT2, RA_JOB_RUNE_KNIGHT_T2, RA_JOB_BABY_RUNE_KNIGHT2: "룬나이트쁘띠"
        case RA_JOB_ROYAL_GUARD2, RA_JOB_ROYAL_GUARD_T2, RA_JOB_BABY_ROYAL_GUARD2: "그리폰가드"
        case RA_JOB_RANGER2, RA_JOB_RANGER_T2, RA_JOB_BABY_RANGER2: "레인져늑대"
        case RA_JOB_MECHANIC2, RA_JOB_MECHANIC_T2, RA_JOB_BABY_MECHANIC2: "마도기어"

        case RA_JOB_KAGEROU: "kagerou"
        case RA_JOB_OBORO: "oboro"
        case RA_JOB_REBELLION: "rebellion"

        case RA_JOB_DRAGON_KNIGHT: "dragon_knight"
        case RA_JOB_MEISTER: "meister"
        case RA_JOB_SHADOW_CROSS: "shadow_cross"
        case RA_JOB_ARCH_MAGE: "arch_mage"
        case RA_JOB_CARDINAL: "cardinal"
        case RA_JOB_WINDHAWK: "windhawk"

        case RA_JOB_IMPERIAL_GUARD: "imperial_guard"
        case RA_JOB_BIOLO: "biolo"
        case RA_JOB_ABYSS_CHASER: "abyss_chaser"
        case RA_JOB_ELEMENTAL_MASTER: "elemetal_master"
        case RA_JOB_INQUISITOR: "inquisitor"
        case RA_JOB_TROUBADOUR: "troubadour"
        case RA_JOB_TROUVERE: "trouvere"

        case RA_JOB_WINDHAWK2: "wolf_windhawk"
        case RA_JOB_MEISTER2: "meister_madogear2"
        case RA_JOB_DRAGON_KNIGHT2: "dragon_knight_chicken"
        case RA_JOB_IMPERIAL_GUARD2: "imperial_guard_chicken"

        case RA_JOB_SKY_EMPEROR: "sky_emperor"
        case RA_JOB_SOUL_ASCETIC: "soul_ascetic"
        case RA_JOB_SHINKIRO: "shinkiro"
        case RA_JOB_SHIRANUI: "shiranui"
        case RA_JOB_NIGHT_WATCH: "night_watch"
        case RA_JOB_HYPER_NOVICE: "hyper_novice"
        case RA_JOB_SPIRIT_HANDLER: "spirit_handler"

        case RA_JOB_SKY_EMPEROR2: "sky_emperor2"

        default: "초보자"
        }
    }
}
