//
//  MessageStringTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/6/14.
//

import Foundation
import ROConstants
import ROCore

public struct MessageStringTable: Sendable {
    public static let current = MessageStringTable(locale: .current)

    let locale: Locale
    let messageStrings: [String]

    init(locale: Locale) {
        self.locale = locale

        self.messageStrings = {
            guard let url = Bundle.module.url(forResource: "msgstringtable", withExtension: "txt", locale: locale),
                  let stream = FileStream(url: url) else {
                return []
            }

            let reader = StreamReader(stream: stream, delimiter: "\r\n")
            defer {
                reader.close()
            }

            let encoding = locale.language.preferredEncoding

            var messageStrings: [String] = []

            while let line = reader.readLine() {
                var messageString = line.transcoding(from: .isoLatin1, to: encoding) ?? ""
                if messageString.hasSuffix("#") {
                    messageString.removeLast()
                }
                messageStrings.append(messageString)
            }

            return messageStrings
        }()
    }

    public func localizedMessageString(at index: Int) -> String {
        messageStrings[index]
    }

    public func localizedJobName(forJobID jobID: JobID) -> String? {
        switch jobID {
        case .novice:
            messageStrings[1681]
        case .swordman:
            messageStrings[1630]
        case .mage:
            messageStrings[1631]
        case .archer:
            messageStrings[1632]
        case .acolyte:
            messageStrings[1633]
        case .merchant:
            messageStrings[1634]
        case .thief:
            messageStrings[1635]
        case .knight, .knight2:
            messageStrings[1636]
        case .priest:
            messageStrings[1637]
        case .wizard:
            messageStrings[1638]
        case .blacksmith:
            messageStrings[1639]
        case .hunter:
            messageStrings[1640]
        case .assassin:
            messageStrings[1641]
        case .crusader, .crusader2:
            messageStrings[1642]
        case .monk:
            messageStrings[1643]
        case .sage:
            messageStrings[1644]
        case .rogue:
            messageStrings[1645]
        case .alchemist:
            messageStrings[1646]
        case .bard:
            messageStrings[1647]
        case .dancer:
            messageStrings[1648]
        case .wedding:
            nil
        case .super_novice:
            messageStrings[1683]
        case .gunslinger:
            messageStrings[1684]
        case .ninja:
            messageStrings[1685]
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
            messageStrings[1682]
        case .swordman_high:
            messageStrings[1662]
        case .mage_high:
            messageStrings[1663]
        case .archer_high:
            messageStrings[1664]
        case .acolyte_high:
            messageStrings[1665]
        case .merchant_high:
            messageStrings[1666]
        case .thief_high:
            messageStrings[1667]
        case .lord_knight, .lord_knight2:
            messageStrings[1668]
        case .high_priest:
            messageStrings[1669]
        case .high_wizard:
            messageStrings[1670]
        case .whitesmith:
            messageStrings[1671]
        case .sniper:
            messageStrings[1672]
        case .assassin_cross:
            messageStrings[1673]
        case .paladin, .paladin2:
            messageStrings[1674]
        case .champion:
            messageStrings[1675]
        case .professor:
            messageStrings[1676]
        case .stalker:
            messageStrings[1677]
        case .creator:
            messageStrings[1678]
        case .clown:
            messageStrings[1679]
        case .gypsy:
            messageStrings[1680]
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
            messageStrings[1686]
        case .star_gladiator, .star_gladiator2:
            messageStrings[1687]
        case .soul_linker:
            messageStrings[1688]
        case .gangsi:
            nil
        case .death_knight:
            nil
        case .dark_collector:
            nil
        case .rune_knight, .rune_knight_t, .rune_knight2, .rune_knight_t2:
            messageStrings[1649]
        case .warlock, .warlock_t:
            messageStrings[1650]
        case .ranger, .ranger_t, .ranger2, .ranger_t2:
            messageStrings[1651]
        case .arch_bishop, .arch_bishop_t:
            messageStrings[1652]
        case .mechanic, .mechanic_t, .mechanic2, .mechanic_t2:
            messageStrings[1653]
        case .guillotine_cross, .guillotine_cross_t:
            messageStrings[1654]
        case .royal_guard, .royal_guard_t, .royal_guard2, .royal_guard_t2:
            messageStrings[1655]
        case .sorcerer, .sorcerer_t:
            messageStrings[1656]
        case .minstrel, .minstrel_t:
            messageStrings[1657]
        case .wanderer, .wanderer_t:
            messageStrings[1658]
        case .sura, .sura_t:
            messageStrings[1659]
        case .genetic, .genetic_t:
            messageStrings[1660]
        case .shadow_chaser, .shadow_chaser_t:
            messageStrings[1661]
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
