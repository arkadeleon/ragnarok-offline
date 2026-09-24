//
//  GameContextMenuButton.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/21.
//

import SwiftUI

/// A left-aligned, full-width action row in a context menu.
struct GameContextMenuButton: View {
    var label: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(verbatim: label)
                .font(.game())
                .foregroundStyle(Color.gameLabel)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 0) {
        GameContextMenuButton(label: "Use") {}
        GameContextMenuButton(label: "Throw") {}
    }
    .frame(width: 120)
    .background(RoundedRectangle(cornerRadius: 5).fill(Material.bar))
    .padding()
}
