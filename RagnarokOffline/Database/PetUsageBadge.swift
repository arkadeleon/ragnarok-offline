//
//  PetUsageBadge.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import SwiftUI

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
