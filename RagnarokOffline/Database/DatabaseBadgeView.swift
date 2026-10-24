//
//  DatabaseBadgeView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import SwiftUI

struct DatabaseBadgeView: View {
    var badge: DatabaseBadge

    var body: some View {
        Text(badge.text)
            .font(.caption)
            .foregroundStyle(color)
            .lineLimit(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(color.opacity(0.15), in: .capsule)
    }

    private var color: Color {
        switch badge.semantic {
        case .amount: .teal
        case .default: .gray
        case .map: .mint
        case .mvp: .red
        case .notConsumed: .yellow
        case .petItem(.tame): .pink
        case .petItem(.egg): .brown
        case .petItem(.equip): .purple
        case .petItem(.food): .green
        case .position: .cyan
        case .price: .orange
        case .rate: .blue
        case .skillLevel: .indigo
        case .spawn: .teal
        }
    }
}

struct DatabaseBadgeStackView: View {
    var badges: [DatabaseBadge]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(badges.indices, id: \.self) { index in
                DatabaseBadgeView(badge: badges[index])
            }
        }
    }
}

extension ImageGridCell where Title == Text, Subtitle == DatabaseBadgeStackView {
    init(title: String, badges: [DatabaseBadge], @ViewBuilder image: () -> Image) {
        self.init(title: title, subtitle: { DatabaseBadgeStackView(badges: badges) }, image: image)
    }
}
