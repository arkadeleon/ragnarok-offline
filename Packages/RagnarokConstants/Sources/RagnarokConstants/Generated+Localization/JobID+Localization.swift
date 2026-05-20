//
//  JobID+Localization.swift
//  RagnarokConstants
//
//  Created by Leon Li on 2026/5/20.
//

import Foundation

extension JobID {
    public var localizedName: LocalizedStringResource? {
        switch self {
        case .novice:
            LocalizedStringResource("Novice", table: "JobID", bundle: .module)
        case .swordman:
            LocalizedStringResource("Swordman", table: "JobID", bundle: .module)
        case .mage:
            LocalizedStringResource("Magician", table: "JobID", bundle: .module)
        case .archer:
            LocalizedStringResource("Archer", table: "JobID", bundle: .module)
        case .acolyte:
            LocalizedStringResource("Acolyte", table: "JobID", bundle: .module)
        case .merchant:
            LocalizedStringResource("Merchant", table: "JobID", bundle: .module)
        case .thief:
            LocalizedStringResource("Thief", table: "JobID", bundle: .module)
        case .knight, .knight2:
            LocalizedStringResource("Knight", table: "JobID", bundle: .module)
        case .priest:
            LocalizedStringResource("Priest", table: "JobID", bundle: .module)
        case .wizard:
            LocalizedStringResource("Wizard", table: "JobID", bundle: .module)
        case .blacksmith:
            LocalizedStringResource("Blacksmith", table: "JobID", bundle: .module)
        case .hunter:
            LocalizedStringResource("Hunter", table: "JobID", bundle: .module)
        case .assassin:
            LocalizedStringResource("Assassin", table: "JobID", bundle: .module)
        case .crusader, .crusader2:
            LocalizedStringResource("Crusader", table: "JobID", bundle: .module)
        case .monk:
            LocalizedStringResource("Monk", table: "JobID", bundle: .module)
        case .sage:
            LocalizedStringResource("Sage", table: "JobID", bundle: .module)
        case .rogue:
            LocalizedStringResource("Rogue", table: "JobID", bundle: .module)
        case .alchemist:
            LocalizedStringResource("Alchemist", table: "JobID", bundle: .module)
        case .bard:
            LocalizedStringResource("Bard", table: "JobID", bundle: .module)
        case .dancer:
            LocalizedStringResource("Dancer", table: "JobID", bundle: .module)
        case .wedding:
            nil
        case .super_novice:
            LocalizedStringResource("Super Novice", table: "JobID", bundle: .module)
        case .gunslinger:
            LocalizedStringResource("Gunslinger", table: "JobID", bundle: .module)
        case .ninja:
            LocalizedStringResource("Ninja", table: "JobID", bundle: .module)
        case .xmas:
            nil
        case .summer:
            nil
        case .hanbok:
            nil
        case .oktoberfest:
            nil
        case .summer2:
            nil
        case .novice_high:
            LocalizedStringResource("High Novice", table: "JobID", bundle: .module)
        case .swordman_high:
            LocalizedStringResource("High Swordman", table: "JobID", bundle: .module)
        case .mage_high:
            LocalizedStringResource("High Mage", table: "JobID", bundle: .module)
        case .archer_high:
            LocalizedStringResource("High Archer", table: "JobID", bundle: .module)
        case .acolyte_high:
            LocalizedStringResource("High Acolyte", table: "JobID", bundle: .module)
        case .merchant_high:
            LocalizedStringResource("High Merchant", table: "JobID", bundle: .module)
        case .thief_high:
            LocalizedStringResource("High Thief", table: "JobID", bundle: .module)
        case .lord_knight, .lord_knight2:
            LocalizedStringResource("Lord Knight", table: "JobID", bundle: .module)
        case .high_priest:
            LocalizedStringResource("High Priest", table: "JobID", bundle: .module)
        case .high_wizard:
            LocalizedStringResource("High Wizard", table: "JobID", bundle: .module)
        case .whitesmith:
            LocalizedStringResource("Whitesmith", table: "JobID", bundle: .module)
        case .sniper:
            LocalizedStringResource("Sniper", table: "JobID", bundle: .module)
        case .assassin_cross:
            LocalizedStringResource("Assassin Cross", table: "JobID", bundle: .module)
        case .paladin, .paladin2:
            LocalizedStringResource("Paladin", table: "JobID", bundle: .module)
        case .champion:
            LocalizedStringResource("Champion", table: "JobID", bundle: .module)
        case .professor:
            LocalizedStringResource("Professor", table: "JobID", bundle: .module)
        case .stalker:
            LocalizedStringResource("Stalker", table: "JobID", bundle: .module)
        case .creator:
            LocalizedStringResource("Creator", table: "JobID", bundle: .module)
        case .clown:
            LocalizedStringResource("Clown", table: "JobID", bundle: .module)
        case .gypsy:
            LocalizedStringResource("Gypsy", table: "JobID", bundle: .module)
        case .baby:
            nil
        case .baby_swordman:
            nil
        case .baby_mage:
            nil
        case .baby_archer:
            nil
        case .baby_acolyte:
            nil
        case .baby_merchant:
            nil
        case .baby_thief:
            nil
        case .baby_knight:
            nil
        case .baby_priest:
            nil
        case .baby_wizard:
            nil
        case .baby_blacksmith:
            nil
        case .baby_hunter:
            nil
        case .baby_assassin:
            nil
        case .baby_knight2:
            nil
        case .baby_crusader:
            nil
        case .baby_monk:
            nil
        case .baby_sage:
            nil
        case .baby_rogue:
            nil
        case .baby_alchemist:
            nil
        case .baby_bard:
            nil
        case .baby_dancer:
            nil
        case .baby_crusader2:
            nil
        case .super_baby:
            nil
        case .taekwon:
            LocalizedStringResource("Taekwon", table: "JobID", bundle: .module)
        case .star_gladiator, .star_gladiator2:
            LocalizedStringResource("Star Gladiator", table: "JobID", bundle: .module)
        case .soul_linker:
            LocalizedStringResource("Soul Linker", table: "JobID", bundle: .module)
        case .gangsi:
            nil
        case .death_knight:
            nil
        case .dark_collector:
            nil
        case .rune_knight, .rune_knight_t, .rune_knight2, .rune_knight_t2:
            LocalizedStringResource("Rune Knight", table: "JobID", bundle: .module)
        case .warlock, .warlock_t:
            LocalizedStringResource("Warlock", table: "JobID", bundle: .module)
        case .ranger, .ranger_t, .ranger2, .ranger_t2:
            LocalizedStringResource("Ranger", table: "JobID", bundle: .module)
        case .arch_bishop, .arch_bishop_t:
            LocalizedStringResource("Arch Bishop", table: "JobID", bundle: .module)
        case .mechanic, .mechanic_t, .mechanic2, .mechanic_t2:
            LocalizedStringResource("Mechanic", table: "JobID", bundle: .module)
        case .guillotine_cross, .guillotine_cross_t:
            LocalizedStringResource("Guillotine Cross", table: "JobID", bundle: .module)
        case .royal_guard, .royal_guard_t, .royal_guard2, .royal_guard_t2:
            LocalizedStringResource("Royal Guard", table: "JobID", bundle: .module)
        case .sorcerer, .sorcerer_t:
            LocalizedStringResource("Sorcerer", table: "JobID", bundle: .module)
        case .minstrel, .minstrel_t:
            LocalizedStringResource("Minstrel", table: "JobID", bundle: .module)
        case .wanderer, .wanderer_t:
            LocalizedStringResource("Wanderer", table: "JobID", bundle: .module)
        case .sura, .sura_t:
            LocalizedStringResource("Shura", table: "JobID", bundle: .module)
        case .genetic, .genetic_t:
            LocalizedStringResource("Genetic", table: "JobID", bundle: .module)
        case .shadow_chaser, .shadow_chaser_t:
            LocalizedStringResource("Shadow Chaser", table: "JobID", bundle: .module)
        case .baby_rune_knight:
            nil
        case .baby_warlock:
            nil
        case .baby_ranger:
            nil
        case .baby_arch_bishop:
            nil
        case .baby_mechanic:
            nil
        case .baby_guillotine_cross:
            nil
        case .baby_royal_guard:
            nil
        case .baby_sorcerer:
            nil
        case .baby_minstrel:
            nil
        case .baby_wanderer:
            nil
        case .baby_sura:
            nil
        case .baby_genetic:
            nil
        case .baby_shadow_chaser:
            nil
        case .baby_rune_knight2:
            nil
        case .baby_royal_guard2:
            nil
        case .baby_ranger2:
            nil
        case .baby_mechanic2:
            nil
        case .super_novice_e:
            LocalizedStringResource("Expanded Super Novice", table: "JobID", bundle: .module)
        case .super_baby_e:
            nil
        case .kagerou:
            LocalizedStringResource("Kagerou", table: "JobID", bundle: .module)
        case .oboro:
            LocalizedStringResource("Oboro", table: "JobID", bundle: .module)
        case .rebellion:
            LocalizedStringResource("Rebellion", table: "JobID", bundle: .module)
        case .summoner:
            LocalizedStringResource("Summoner", table: "JobID", bundle: .module)
        case .baby_summoner:
            nil
        case .baby_ninja:
            nil
        case .baby_kagerou:
            nil
        case .baby_oboro:
            nil
        case .baby_taekwon:
            nil
        case .baby_star_gladiator:
            nil
        case .baby_soul_linker:
            nil
        case .baby_gunslinger:
            nil
        case .baby_rebellion:
            nil
        case .baby_star_gladiator2:
            nil
        case .star_emperor:
            LocalizedStringResource("Star Emperor", table: "JobID", bundle: .module)
        case .soul_reaper:
            LocalizedStringResource("Soul Reaper", table: "JobID", bundle: .module)
        case .baby_star_emperor:
            nil
        case .baby_soul_reaper:
            nil
        case .star_emperor2:
            LocalizedStringResource("Star Emperor", table: "JobID", bundle: .module)
        case .baby_star_emperor2:
            nil
        case .dragon_knight:
            LocalizedStringResource("Dragon Knight", table: "JobID", bundle: .module)
        case .meister:
            LocalizedStringResource("Meister", table: "JobID", bundle: .module)
        case .shadow_cross:
            LocalizedStringResource("Shadow Cross", table: "JobID", bundle: .module)
        case .arch_mage:
            LocalizedStringResource("Arch Mage", table: "JobID", bundle: .module)
        case .cardinal:
            LocalizedStringResource("Cardinal", table: "JobID", bundle: .module)
        case .windhawk:
            LocalizedStringResource("Wind Hawk", table: "JobID", bundle: .module)
        case .imperial_guard:
            LocalizedStringResource("Imperial Guard", table: "JobID", bundle: .module)
        case .biolo:
            LocalizedStringResource("Biolo", table: "JobID", bundle: .module)
        case .abyss_chaser:
            LocalizedStringResource("Abyss Chaser", table: "JobID", bundle: .module)
        case .elemental_master:
            LocalizedStringResource("Elemental Master", table: "JobID", bundle: .module)
        case .inquisitor:
            LocalizedStringResource("Inquisitor", table: "JobID", bundle: .module)
        case .troubadour:
            LocalizedStringResource("Troubadour", table: "JobID", bundle: .module)
        case .trouvere:
            LocalizedStringResource("Trouvere", table: "JobID", bundle: .module)
        case .windhawk2:
            LocalizedStringResource("Wind Hawk", table: "JobID", bundle: .module)
        case .meister2:
            LocalizedStringResource("Meister", table: "JobID", bundle: .module)
        case .dragon_knight2:
            LocalizedStringResource("Dragon Knight", table: "JobID", bundle: .module)
        case .imperial_guard2:
            LocalizedStringResource("Imperial Guard", table: "JobID", bundle: .module)
        case .sky_emperor:
            LocalizedStringResource("Sky Emperor", table: "JobID", bundle: .module)
        case .soul_ascetic:
            LocalizedStringResource("Soul Ascetic", table: "JobID", bundle: .module)
        case .shinkiro:
            LocalizedStringResource("Shinkiro", table: "JobID", bundle: .module)
        case .shiranui:
            LocalizedStringResource("Shiranui", table: "JobID", bundle: .module)
        case .night_watch:
            LocalizedStringResource("Night Watch", table: "JobID", bundle: .module)
        case .hyper_novice:
            LocalizedStringResource("Hyper Novice", table: "JobID", bundle: .module)
        case .spirit_handler:
            LocalizedStringResource("Spirit Handler", table: "JobID", bundle: .module)
        case .sky_emperor2:
            LocalizedStringResource("Sky Emperor", table: "JobID", bundle: .module)
        case .rune_knight_2nd:
            nil
        case .mechanic_2nd:
            nil
        case .guillotine_cross_2nd:
            nil
        case .warlock_2nd:
            nil
        case .archbishop_2nd:
            nil
        case .ranger_2nd:
            nil
        case .royal_guard_2nd:
            nil
        case .genetic_2nd:
            nil
        case .shadow_chaser_2nd:
            nil
        case .sorcerer_2nd:
            nil
        case .sura_2nd:
            nil
        case .minstrel_2nd:
            nil
        case .wanderer_2nd:
            nil
        }
    }
}
