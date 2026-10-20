//
//  DatabaseBadges.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import SwiftUI

struct RateBadge: View {
    var rate: Int

    var body: some View {
        Badge(text: (Double(rate) / 100).formatted() + "%", color: .blue)
    }
}

struct SummonRateBadge: View {
    var rate: Int

    var body: some View {
        Badge(text: (Double(rate) / 10000).formatted() + "%", color: .blue)
    }
}

struct MVPBadge: View {
    var body: some View {
        Badge(text: "MVP", color: .red)
    }
}

struct AmountBadge: View {
    var amount: Int

    var body: some View {
        Badge(text: "×" + amount.formatted(), color: .teal)
    }
}

struct PriceBadge: View {
    var price: Int

    var body: some View {
        Badge(text: price.formatted() + "z", color: .orange)
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
