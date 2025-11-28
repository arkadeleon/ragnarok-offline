//
//  MessageStringTable+JobName.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/9/26.
//

import RagnarokConstants
import RagnarokResources

extension MessageStringTable {
    func localizedJobName(for jobID: JobID) -> String? {
        switch jobID {
        case .novice:
            localizedMessageString(forID: 1680)
        case .swordman:
            localizedMessageString(forID: 1629)
        case .mage:
            localizedMessageString(forID: 1630)
        case .archer:
            localizedMessageString(forID: 1631)
        case .acolyte:
            localizedMessageString(forID: 1632)
        case .merchant:
            localizedMessageString(forID: 1633)
        case .thief:
            localizedMessageString(forID: 1634)
        case .knight, .knight2:
            localizedMessageString(forID: 1635)
        case .priest:
            localizedMessageString(forID: 1636)
        case .wizard:
            localizedMessageString(forID: 1637)
        case .blacksmith:
            localizedMessageString(forID: 1638)
        case .hunter:
            localizedMessageString(forID: 1639)
        case .assassin:
            localizedMessageString(forID: 1640)
        case .crusader, .crusader2:
            localizedMessageString(forID: 1641)
        case .monk:
            localizedMessageString(forID: 1642)
        case .sage:
            localizedMessageString(forID: 1643)
        case .rogue:
            localizedMessageString(forID: 1644)
        case .alchemist:
            localizedMessageString(forID: 1645)
        case .bard:
            localizedMessageString(forID: 1646)
        case .dancer:
            localizedMessageString(forID: 1647)
        case .wedding:
            nil
        case .super_novice:
            localizedMessageString(forID: 1682)
        case .gunslinger:
            localizedMessageString(forID: 1683)
        case .ninja:
            localizedMessageString(forID: 1684)
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
            localizedMessageString(forID: 1681)
        case .swordman_high:
            localizedMessageString(forID: 1661)
        case .mage_high:
            localizedMessageString(forID: 1662)
        case .archer_high:
            localizedMessageString(forID: 1663)
        case .acolyte_high:
            localizedMessageString(forID: 1664)
        case .merchant_high:
            localizedMessageString(forID: 1665)
        case .thief_high:
            localizedMessageString(forID: 1666)
        case .lord_knight, .lord_knight2:
            localizedMessageString(forID: 1667)
        case .high_priest:
            localizedMessageString(forID: 1668)
        case .high_wizard:
            localizedMessageString(forID: 1669)
        case .whitesmith:
            localizedMessageString(forID: 1670)
        case .sniper:
            localizedMessageString(forID: 1671)
        case .assassin_cross:
            localizedMessageString(forID: 1672)
        case .paladin, .paladin2:
            localizedMessageString(forID: 1673)
        case .champion:
            localizedMessageString(forID: 1674)
        case .professor:
            localizedMessageString(forID: 1675)
        case .stalker:
            localizedMessageString(forID: 1676)
        case .creator:
            localizedMessageString(forID: 1677)
        case .clown:
            localizedMessageString(forID: 1678)
        case .gypsy:
            localizedMessageString(forID: 1679)
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
            localizedMessageString(forID: 1685)
        case .star_gladiator, .star_gladiator2:
            localizedMessageString(forID: 1686)
        case .soul_linker:
            localizedMessageString(forID: 1687)
        case .gangsi:
            nil
        case .death_knight:
            nil
        case .dark_collector:
            nil
        case .rune_knight, .rune_knight_t, .rune_knight2, .rune_knight_t2:
            localizedMessageString(forID: 1648)
        case .warlock, .warlock_t:
            localizedMessageString(forID: 1649)
        case .ranger, .ranger_t, .ranger2, .ranger_t2:
            localizedMessageString(forID: 1650)
        case .arch_bishop, .arch_bishop_t:
            localizedMessageString(forID: 1651)
        case .mechanic, .mechanic_t, .mechanic2, .mechanic_t2:
            localizedMessageString(forID: 1652)
        case .guillotine_cross, .guillotine_cross_t:
            localizedMessageString(forID: 1653)
        case .royal_guard, .royal_guard_t, .royal_guard2, .royal_guard_t2:
            localizedMessageString(forID: 1654)
        case .sorcerer, .sorcerer_t:
            localizedMessageString(forID: 1655)
        case .minstrel, .minstrel_t:
            localizedMessageString(forID: 1656)
        case .wanderer, .wanderer_t:
            localizedMessageString(forID: 1657)
        case .sura, .sura_t:
            localizedMessageString(forID: 1658)
        case .genetic, .genetic_t:
            localizedMessageString(forID: 1659)
        case .shadow_chaser, .shadow_chaser_t:
            localizedMessageString(forID: 1660)
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
            nil
        case .super_baby_e:
            nil
        case .kagerou:
            nil
        case .oboro:
            nil
        case .rebellion:
            nil
        case .summoner:
            nil
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
            nil
        case .soul_reaper:
            nil
        case .baby_star_emperor:
            nil
        case .baby_soul_reaper:
            nil
        case .star_emperor2:
            nil
        case .baby_star_emperor2:
            nil
        case .dragon_knight:
            nil
        case .meister:
            nil
        case .shadow_cross:
            nil
        case .arch_mage:
            nil
        case .cardinal:
            nil
        case .windhawk:
            nil
        case .imperial_guard:
            nil
        case .biolo:
            nil
        case .abyss_chaser:
            nil
        case .elemental_master:
            nil
        case .inquisitor:
            nil
        case .troubadour:
            nil
        case .trouvere:
            nil
        case .windhawk2:
            nil
        case .meister2:
            nil
        case .dragon_knight2:
            nil
        case .imperial_guard2:
            nil
        case .sky_emperor:
            nil
        case .soul_ascetic:
            nil
        case .shinkiro:
            nil
        case .shiranui:
            nil
        case .night_watch:
            nil
        case .hyper_novice:
            nil
        case .spirit_handler:
            nil
        case .sky_emperor2:
            nil
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
