//
//  GameContextMenuButton.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/21.
//

import SwiftUI

struct GameContextMenuButton<Label>: View where Label: View {
    var action: () -> Void
    @ViewBuilder var label: Label

    var body: some View {
        Button(action: action) {
            label
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
        GameContextMenuButton {
        } label: {
            Text(verbatim: "Use")
        }

        GameContextMenuButton {
        } label: {
            Text(verbatim: "Throw")
        }
    }
    .frame(width: 120)
    .background(RoundedRectangle(cornerRadius: 5).fill(Material.bar))
    .padding()
}
