//
//  Job+ResourceName.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/22.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

extension Job {
    var resourceName: String {
        switch self {
        case .novice, .noviceHigh, .baby: "초보자"

        case .swordman, .swordmanHigh, .babySwordman: "검사"
        case .mage, .mageHigh, .babyMage: "마법사"
        case .archer, .archerHigh, .babyArcher: "궁수"
        case .acolyte, .acolyteHigh, .babyAcolyte: "성직자"
        case .merchant, .merchantHigh, .babyMerchant: "상인"
        case .thief, .thiefHigh, .babyThief: "도둑"

        case .knight, .babyKnight: "기사"
        case .priest, .babyPriest: "프리스트"
        case .wizard, .babyWizard: "위저드"
        case .blacksmith, .babyBlacksmith: "제철공"
        case .hunter, .babyHunter: "헌터"
        case .assassin, .babyAssassin: "어세신"
        case .knight2, .babyKnight2: "페코페코_기사"

        case .crusader, .babyCrusader: "크루세이더"
        case .monk, .babyMonk: "몽크"
        case .sage, .babySage: "세이지"
        case .rogue, .babyRogue: "로그"
        case .alchemist, .babyAlchemist: "연금술사"
        case .bard, .babyBard: "바드"
        case .dancer, .babyDancer: "무희"
        case .crusader2, .babyCrusader2: "신페코크루세이더"

        case .superNovice: "슈퍼노비스"
        case .gunslinger: "건너"
        case .ninja: "닌자"
        case .taekwon: "태권소년"
        case .starGladiator: "권성"
        case .starGladiator2: "권성융합"
        case .soulLinker: "소울링커"

        case .wedding: "결혼"
        case .christmas: "산타"
        case .summer: "여름"

        case .lordKnight: "로드나이트"
        case .highPriest: "하이프리"
        case .highWizard: "하이위저드"
        case .whitesmith: "화이트스미스"
        case .sniper: "스나이퍼"
        case .assassinCross: "어쌔신크로스"
        case .lordKnight2: "로드페코"

        case .paladin: "팔라딘"
        case .champion: "챔피온"
        case .professor: "프로페서"
        case .stalker: "스토커"
        case .creator: "크리에이터"
        case .clown: "클라운"
        case .gypsy: "집시"
        case .paladin2: "페코팔라딘"

        case .runeKnight, .runeKnightT, .babyRuneKnight: "룬나이트"
        case .warlock, .warlockT, .babyWarlock: "워록"
        case .ranger, .rangerT, .babyRanger: "레인져"
        case .archBishop, .archBishopT, .babyArchBishop: "아크비숍"
        case .mechanic, .mechanicT, .babyMechanic: "미케닉"
        case .guillotineCross, .guillotineCrossT, .babyGuillotineCross: "길로틴크로스"

        case .royalGuard, .royalGuardT, .babyRoyalGuard: "가드"
        case .sorcerer, .sorcererT, .babySorcerer: "소서러"
        case .minstrel, .minstrelT, .babyMinstrel: "민스트럴"
        case .wanderer, .wandererT, .babyWanderer: "원더러"
        case .sura, .suraT, .babySura: "슈라"
        case .genetic, .geneticT, .babyGenetic: "제네릭"
        case .shadowChaser, .shadowChaserT, .babyShadowChaser: "쉐도우체이서"

        case .runeKnight2, .runeKnightT2, .babyRuneKnight2: "룬나이트쁘띠"
        case .royalGuard2, .royalGuardT2, .babyRoyalGuard2: "그리폰가드"
        case .ranger2, .rangerT2, .babyRanger2: "레인져늑대"
        case .mechanic2, .mechanicT2, .babyMechanic2: "마도기어"

        case .kagerou: "kagerou"
        case .oboro: "oboro"
        case .rebellion: "rebellion"

        case .dragonKnight: "dragon_knight"
        case .meister: "meister"
        case .shadowCross: "shadow_cross"
        case .archMage: "arch_mage"
        case .cardinal: "cardinal"
        case .windhawk: "windhawk"

        case .imperialGuard: "imperial_guard"
        case .biolo: "biolo"
        case .abyssChaser: "abyss_chaser"
        case .elementalMaster: "elemetal_master"
        case .inquisitor: "inquisitor"
        case .troubadour: "troubadour"
        case .trouvere: "trouvere"

        case .windhawk2: "wolf_windhawk"
        case .meister2: "meister_madogear2"
        case .dragonKnight2: "dragon_knight_chicken"
        case .imperialGuard2: "imperial_guard_chicken"

        case .skyEmperor: "sky_emperor"
        case .soulAscetic: "soul_ascetic"
        case .shinkiro: "shinkiro"
        case .shiranui: "shiranui"
        case .nightWatch: "night_watch"
        case .hyperNovice: "hyper_novice"
        case .spiritHandler: "spirit_handler"

        case .skyEmperor2: "sky_emperor2"

        default: ""
        }
    }
}
