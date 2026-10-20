//
//  Badge.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import SwiftUI

struct Badge: View {
    var text: String
    var color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .monospacedDigit()
            .foregroundStyle(color)
            .lineLimit(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(color.opacity(0.15), in: .capsule)
    }
}
