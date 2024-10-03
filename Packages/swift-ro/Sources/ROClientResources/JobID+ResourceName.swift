//
//  JobID+ResourceName.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/22.
//

import ROGenerated

extension JobID {
    var resourceName: String {
        switch self {
        case .novice, .novice_high, .baby: "초보자"

        case .swordman, .swordman_high, .baby_swordman: "검사"
        case .mage, .mage_high, .baby_mage: "마법사"
        case .archer, .archer_high, .baby_archer: "궁수"
        case .acolyte, .acolyte_high, .baby_acolyte: "성직자"
        case .merchant, .merchant_high, .baby_merchant: "상인"
        case .thief, .thief_high, .baby_thief: "도둑"

        case .knight, .baby_knight: "기사"
        case .priest, .baby_priest: "프리스트"
        case .wizard, .baby_wizard: "위저드"
        case .blacksmith, .baby_blacksmith: "제철공"
        case .hunter, .baby_hunter: "헌터"
        case .assassin, .baby_assassin: "어세신"
        case .knight2, .baby_knight2: "페코페코_기사"

        case .crusader, .baby_crusader: "크루세이더"
        case .monk, .baby_monk: "몽크"
        case .sage, .baby_sage: "세이지"
        case .rogue, .baby_rogue: "로그"
        case .alchemist, .baby_alchemist: "연금술사"
        case .bard, .baby_bard: "바드"
        case .dancer, .baby_dancer: "무희"
        case .crusader2, .baby_crusader2: "신페코크루세이더"

        case .super_novice: "슈퍼노비스"
        case .gunslinger: "건너"
        case .ninja: "닌자"
        case .taekwon: "태권소년"
        case .star_gladiator: "권성"
        case .star_gladiator2: "권성융합"
        case .soul_linker: "소울링커"

        case .wedding: "결혼"
        case .xmas: "산타"
        case .summer: "여름"

        case .lord_knight: "로드나이트"
        case .high_priest: "하이프리"
        case .high_wizard: "하이위저드"
        case .whitesmith: "화이트스미스"
        case .sniper: "스나이퍼"
        case .assassin_cross: "어쌔신크로스"
        case .lord_knight2: "로드페코"

        case .paladin: "팔라딘"
        case .champion: "챔피온"
        case .professor: "프로페서"
        case .stalker: "스토커"
        case .creator: "크리에이터"
        case .clown: "클라운"
        case .gypsy: "집시"
        case .paladin2: "페코팔라딘"

        case .rune_knight, .rune_knight_t, .baby_rune_knight: "룬나이트"
        case .warlock, .warlock_t, .baby_warlock: "워록"
        case .ranger, .ranger_t, .baby_ranger: "레인져"
        case .arch_bishop, .arch_bishop_t, .baby_arch_bishop: "아크비숍"
        case .mechanic, .mechanic_t, .baby_mechanic: "미케닉"
        case .guillotine_cross, .guillotine_cross_t, .baby_guillotine_cross: "길로틴크로스"

        case .royal_guard, .royal_guard_t, .baby_royal_guard: "가드"
        case .sorcerer, .sorcerer_t, .baby_sorcerer: "소서러"
        case .minstrel, .minstrel_t, .baby_minstrel: "민스트럴"
        case .wanderer, .wanderer_t, .baby_wanderer: "원더러"
        case .sura, .sura_t, .baby_sura: "슈라"
        case .genetic, .genetic_t, .baby_genetic: "제네릭"
        case .shadow_chaser, .shadow_chaser_t, .baby_shadow_chaser: "쉐도우체이서"

        case .rune_knight2, .rune_knight_t2, .baby_rune_knight2: "룬나이트쁘띠"
        case .royal_guard2, .royal_guard_t2, .baby_royal_guard2: "그리폰가드"
        case .ranger2, .ranger_t2, .baby_ranger2: "레인져늑대"
        case .mechanic2, .mechanic_t2, .baby_mechanic2: "마도기어"

        case .kagerou: "kagerou"
        case .oboro: "oboro"
        case .rebellion: "rebellion"

        case .dragon_knight: "dragon_knight"
        case .meister: "meister"
        case .shadow_cross: "shadow_cross"
        case .arch_mage: "arch_mage"
        case .cardinal: "cardinal"
        case .windhawk: "windhawk"

        case .imperial_guard: "imperial_guard"
        case .biolo: "biolo"
        case .abyss_chaser: "abyss_chaser"
        case .elemental_master: "elemetal_master"
        case .inquisitor: "inquisitor"
        case .troubadour: "troubadour"
        case .trouvere: "trouvere"

        case .windhawk2: "wolf_windhawk"
        case .meister2: "meister_madogear2"
        case .dragon_knight2: "dragon_knight_chicken"
        case .imperial_guard2: "imperial_guard_chicken"

        case .sky_emperor: "sky_emperor"
        case .soul_ascetic: "soul_ascetic"
        case .shinkiro: "shinkiro"
        case .shiranui: "shiranui"
        case .night_watch: "night_watch"
        case .hyper_novice: "hyper_novice"
        case .spirit_handler: "spirit_handler"

        case .sky_emperor2: "sky_emperor2"

        default: ""
        }
    }
}
