//
//  ChatBoxView.swift
//  GameView
//
//  Created by Leon Li on 2025/4/16.
//

import GameCore
import SwiftUI

struct ChatBoxView: View {
    @Environment(GameSession.self) private var gameSession

    @State private var message = ""

    var body: some View {
        VStack(spacing: 0) {
            TextField(String(), text: $message)
                .textFieldStyle(.roundedBorder)
                #if !os(macOS)
                .textInputAutocapitalization(.never)
                #endif
                .disableAutocorrection(true)
                .gameText()
                .onSubmit {
                    gameSession.sendMessage(message)
                    message = ""
                }
        }
        .frame(width: 220)
    }
}

#Preview {
    ChatBoxView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.previewing)
}
