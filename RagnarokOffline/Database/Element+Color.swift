//
//  Element+Color.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import RagnarokConstants
import SwiftUI

extension Element {
    var color: Color {
        switch self {
        case .neutral: .gray
        case .water: .blue
        case .earth: .brown
        case .fire: .red
        case .wind: .green
        case .poison: .purple
        case .holy: .orange
        case .dark: .indigo
        case .ghost: .cyan
        case .undead: .mint
        case .weapon, .endowed, .random: .primary
        }
    }
}
