//
//  MessageBoxView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/9.
//

import SwiftUI

struct MessageBoxView<Actions>: View where Actions: View {
    var message: String
    var actions: Actions

    var body: some View {
        GameWindow {
            Text(message)
                .font(.game())
                .foregroundStyle(Color.gameLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .frame(height: 82)
        } bottomBar: {
            GameBottomBar {
                actions
            }
        }
        .frame(width: 280)
    }

    init(_ message: String) where Actions == EmptyView {
        self.message = message
        self.actions = EmptyView()
    }

    init(_ message: String, @ViewBuilder actions: () -> Actions) {
        self.message = message
        self.actions = actions()
    }
}

#Preview {
    MessageBoxView("Please wait...")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
