//
//  ChatBoxView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/16.
//

import ROGame
import SwiftUI

struct ChatBoxView: View {
    @Environment(GameSession.self) private var gameSession

    @State private var message = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
            }
            .frame(height: 42)
            .background(.black.opacity(0.5))

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
        .frame(width: 280)
    }
}

#Preview {
    ChatBoxView()
        .padding()
        .environment(GameSession())
}
