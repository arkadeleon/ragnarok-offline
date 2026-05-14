//
//  MessageBoxView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/9.
//

import SwiftUI

struct MessageBoxView: View {
    var message: String

    var body: some View {
        GameWindow {
            Text(message)
                .font(.game())
                .foregroundStyle(Color.gameLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .frame(height: 82)
        }
        .frame(width: 280)
    }

    init(_ message: String) {
        self.message = message
    }
}

#Preview {
    MessageBoxView("Please wait...")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
