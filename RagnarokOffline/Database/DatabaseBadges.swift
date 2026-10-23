//
//  DatabaseBadges.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import RagnarokDatabase
import SwiftUI

struct RateBadge: View {
    var rate: Int

    var body: some View {
        Badge(text: formatRate(rate, base: 10000), color: .blue)
    }
}

struct SummonRateBadge: View {
    var rate: Int

    var body: some View {
        Badge(text: formatRate(rate, base: 1000000), color: .blue)
    }
}

struct ItemGroupRateBadge: View {
    var probability: Double

    var body: some View {
        Badge(text: probability.formatted(.percent.precision(.significantDigits(1...3))), color: .blue)
    }
}

struct AmountBadge: View {
    var amount: Int

    var body: some View {
        Badge(text: amount.formatted() + "×", color: .teal)
    }
}

struct DefaultBadge: View {
    var body: some View {
        Badge(text: String(localized: LocalizedStringResource("Default", table: "Database")), color: .gray)
    }
}

struct MVPBadge: View {
    var body: some View {
        Badge(text: "MVP", color: .red)
    }
}

struct SpawnBadge: View {
    var spawn: MonsterSpawn

    var body: some View {
        Badge(text: spawn.amount.formatted() + "× / " + respawnTimeText, color: .teal)
    }

    /// The respawn time is `delay1` plus a random time up to `delay2`, and at least 1 second.
    private var respawnTimeText: String {
        let minimumTime = max(spawn.delay1 ?? 0, 1000)
        let maximumTime = max((spawn.delay1 ?? 0) + (spawn.delay2 ?? 0), 1000)
        if minimumTime == maximumTime {
            return formatTime(minimumTime)
        } else {
            return formatTime(minimumTime) + "–" + formatTime(maximumTime)
        }
    }
}

struct PriceBadge: View {
    var price: Int
    var shopType: ShopNPC.ShopType

    var body: some View {
        Badge(text: text, color: .orange)
    }

    private var text: String {
        switch shopType {
        case .shop, .marketshop:
            formatZeny(price)
        case .cashshop:
            price.formatted() + " Cash"
        case .itemshop, .pointshop:
            price.formatted()
        }
    }
}

struct MapBadge: View {
    var map: MapModel

    var body: some View {
        Badge(text: map.displayName, color: .mint)
    }
}

struct PositionBadge: View {
    var x: Int
    var y: Int

    var body: some View {
        Badge(text: "\(x), \(y)", color: .cyan)
    }
}

struct PetUsageBadge: View {
    var kind: PetUsage.Kind

    var body: some View {
        Badge(text: String(localized: kind.localizedName), color: color)
    }

    private var color: Color {
        switch kind {
        case .tame: .pink
        case .egg: .brown
        case .equip: .purple
        case .food: .green
        }
    }
}

struct SkillLevelBadge: View {
    var level: Int

    var body: some View {
        Badge(text: "Lv. \(level)", color: .indigo)
    }
}
