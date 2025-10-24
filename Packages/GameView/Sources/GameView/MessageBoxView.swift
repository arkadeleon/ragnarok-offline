//
//  MessageBoxView.swift
//  GameView
//
//  Created by Leon Li on 2024/9/9.
//

import GameCore
import SwiftUI

struct MessageBoxView: View {
    var message: String

    var body: some View {
        ZStack {
            GameImage("win_msgbox.bmp")

            Text(message)
                .gameText()
        }
        .frame(width: 280, height: 120)
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
