//
//  GameBottomBar.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/16.
//

import SwiftUI

struct GameBottomBar<Actions>: View where Actions: View {
    var actions: Actions

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        HStack(spacing: 3) {
            actions
        }
        .padding(.horizontal, 5)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .frame(height: height)
        .background {
            GameStripeView()
        }
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 3, bottomTrailingRadius: 3))
        .overlay {
            UnevenRoundedRectangle(bottomLeadingRadius: 3, bottomTrailingRadius: 3)
                .strokeBorder(Color.gameBoxBorder, lineWidth: 1 / displayScale)
        }
    }

    private var height: CGFloat {
        actions is EmptyView ? 21 : 28
    }

    init() where Actions == EmptyView {
        self.actions = EmptyView()
    }

    init(@ViewBuilder actions: () -> Actions) {
        self.actions = actions()
    }
}

#Preview {
    GameBottomBar {
        Button("OK") {
        }
        .buttonStyle(.game)
        .frame(width: 42, height: 20)
    }
    .frame(width: 280)
    .padding()
}
