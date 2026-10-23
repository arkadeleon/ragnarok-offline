//
//  DatabaseBadge.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/23.
//

import Foundation
import RagnarokDatabase

struct DatabaseBadge {
    enum Semantic {
        case amount
        case `default`
        case map
        case mvp
        case petUsage(PetUsage.Kind)
        case position
        case price
        case rate
        case skillLevel
        case spawn
    }

    var text: String
    var semantic: DatabaseBadge.Semantic
}

extension DatabaseBadge {
    static func amount(_ amount: Int) -> DatabaseBadge {
        DatabaseBadge(text: amount.formatted() + "×", semantic: .amount)
    }

    static var `default`: DatabaseBadge {
        DatabaseBadge(text: String(localized: LocalizedStringResource("Default", table: "Database")), semantic: .default)
    }

    static func map(_ map: MapModel) -> DatabaseBadge {
        DatabaseBadge(text: map.displayName, semantic: .map)
    }

    static var mvp: DatabaseBadge {
        DatabaseBadge(text: "MVP", semantic: .mvp)
    }

    static func petUsage(_ kind: PetUsage.Kind) -> DatabaseBadge {
        DatabaseBadge(text: String(localized: kind.localizedName), semantic: .petUsage(kind))
    }

    static func position(x: Int, y: Int) -> DatabaseBadge {
        DatabaseBadge(text: "\(x), \(y)", semantic: .position)
    }

    static func price(_ price: Int, shopType: ShopNPC.ShopType) -> DatabaseBadge {
        let text = switch shopType {
        case .shop, .marketshop:
            formatZeny(price)
        case .cashshop:
            price.formatted() + " Cash"
        case .itemshop, .pointshop:
            price.formatted()
        }
        return DatabaseBadge(text: text, semantic: .price)
    }

    /// A chance from 0 to 1, shown with at most 3 significant digits, such as `33.3%`.
    static func probability(_ probability: Double) -> DatabaseBadge {
        DatabaseBadge(text: probability.formatted(.percent.precision(.significantDigits(1...3))), semantic: .rate)
    }

    /// A rate where `base` is 100%, such as a drop rate with a base of 10000.
    static func rate(_ rate: Int, base: Int) -> DatabaseBadge {
        DatabaseBadge(text: formatRate(rate, base: base), semantic: .rate)
    }

    static func skillLevel(_ level: Int) -> DatabaseBadge {
        DatabaseBadge(text: "Lv. \(level)", semantic: .skillLevel)
    }

    /// The respawn time is `delay1` plus a random time up to `delay2`, and at least 1 second.
    static func spawn(_ spawn: MonsterSpawn) -> DatabaseBadge {
        let minimumTime = max(spawn.delay1 ?? 0, 1000)
        let maximumTime = max((spawn.delay1 ?? 0) + (spawn.delay2 ?? 0), 1000)
        let respawnTimeText = if minimumTime == maximumTime {
            formatTime(minimumTime)
        } else {
            formatTime(minimumTime) + "–" + formatTime(maximumTime)
        }
        return DatabaseBadge(text: spawn.amount.formatted() + "× / " + respawnTimeText, semantic: .spawn)
    }
}
