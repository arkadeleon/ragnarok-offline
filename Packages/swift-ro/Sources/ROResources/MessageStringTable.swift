//
//  MessageStringTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/6/14.
//

import Foundation
import ROConstants

final public class MessageStringTable: Resource {
    let messageStringsByID: [Int : String]

    init() {
        self.messageStringsByID = [:]
    }

    init(contentsOf url: URL) throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        self.messageStringsByID = try decoder.decode([Int : String].self, from: data)
    }

    public func localizedMessageString(forID messageID: Int) -> String? {
        messageStringsByID[messageID]
    }

    public func localizedJobName(for jobID: JobID) -> String? {
        switch jobID {
        case .novice:
            messageStringsByID[1681]
        case .swordman:
            messageStringsByID[1630]
        case .mage:
            messageStringsByID[1631]
        case .archer:
            messageStringsByID[1632]
        case .acolyte:
            messageStringsByID[1633]
        case .merchant:
            messageStringsByID[1634]
        case .thief:
            messageStringsByID[1635]
        case .knight, .knight2:
            messageStringsByID[1636]
        case .priest:
            messageStringsByID[1637]
        case .wizard:
            messageStringsByID[1638]
        case .blacksmith:
            messageStringsByID[1639]
        case .hunter:
            messageStringsByID[1640]
        case .assassin:
            messageStringsByID[1641]
        case .crusader, .crusader2:
            messageStringsByID[1642]
        case .monk:
            messageStringsByID[1643]
        case .sage:
            messageStringsByID[1644]
        case .rogue:
            messageStringsByID[1645]
        case .alchemist:
            messageStringsByID[1646]
        case .bard:
            messageStringsByID[1647]
        case .dancer:
            messageStringsByID[1648]
        case .wedding:
            nil
        case .super_novice:
            messageStringsByID[1683]
        case .gunslinger:
            messageStringsByID[1684]
        case .ninja:
            messageStringsByID[1685]
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
            messageStringsByID[1682]
        case .swordman_high:
            messageStringsByID[1662]
        case .mage_high:
            messageStringsByID[1663]
        case .archer_high:
            messageStringsByID[1664]
        case .acolyte_high:
            messageStringsByID[1665]
        case .merchant_high:
            messageStringsByID[1666]
        case .thief_high:
            messageStringsByID[1667]
        case .lord_knight, .lord_knight2:
            messageStringsByID[1668]
        case .high_priest:
            messageStringsByID[1669]
        case .high_wizard:
            messageStringsByID[1670]
        case .whitesmith:
            messageStringsByID[1671]
        case .sniper:
            messageStringsByID[1672]
        case .assassin_cross:
            messageStringsByID[1673]
        case .paladin, .paladin2:
            messageStringsByID[1674]
        case .champion:
            messageStringsByID[1675]
        case .professor:
            messageStringsByID[1676]
        case .stalker:
            messageStringsByID[1677]
        case .creator:
            messageStringsByID[1678]
        case .clown:
            messageStringsByID[1679]
        case .gypsy:
            messageStringsByID[1680]
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
            messageStringsByID[1686]
        case .star_gladiator, .star_gladiator2:
            messageStringsByID[1687]
        case .soul_linker:
            messageStringsByID[1688]
        case .gangsi:
            nil
        case .death_knight:
            nil
        case .dark_collector:
            nil
        case .rune_knight, .rune_knight_t, .rune_knight2, .rune_knight_t2:
            messageStringsByID[1649]
        case .warlock, .warlock_t:
            messageStringsByID[1650]
        case .ranger, .ranger_t, .ranger2, .ranger_t2:
            messageStringsByID[1651]
        case .arch_bishop, .arch_bishop_t:
            messageStringsByID[1652]
        case .mechanic, .mechanic_t, .mechanic2, .mechanic_t2:
            messageStringsByID[1653]
        case .guillotine_cross, .guillotine_cross_t:
            messageStringsByID[1654]
        case .royal_guard, .royal_guard_t, .royal_guard2, .royal_guard_t2:
            messageStringsByID[1655]
        case .sorcerer, .sorcerer_t:
            messageStringsByID[1656]
        case .minstrel, .minstrel_t:
            messageStringsByID[1657]
        case .wanderer, .wanderer_t:
            messageStringsByID[1658]
        case .sura, .sura_t:
            messageStringsByID[1659]
        case .genetic, .genetic_t:
            messageStringsByID[1660]
        case .shadow_chaser, .shadow_chaser_t:
            messageStringsByID[1661]
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
        }
    }
}

extension ResourceManager {
    public func messageStringTable(for locale: Locale) async -> MessageStringTable {
        let localeIdentifier = locale.identifier(.bcp47)
        let taskIdentifier = "MessageStringTable-\(localeIdentifier)"

        if let task = tasks.withLock({ $0[taskIdentifier] }) {
            return await task.value as! MessageStringTable
        }

        let task = Task<any Resource, Never> {
            if let url = Bundle.module.url(forResource: "MessageString", withExtension: "json", locale: locale),
               let messageStringTable = try? MessageStringTable(contentsOf: url) {
                return messageStringTable
            } else {
                return MessageStringTable()
            }
        }

        tasks.withLock {
            $0[taskIdentifier] = task
        }

        return await task.value as! MessageStringTable
    }
}
