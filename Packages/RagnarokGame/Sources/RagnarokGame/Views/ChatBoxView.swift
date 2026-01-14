//
//  ChatBoxView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/16.
//

import SwiftUI

struct ChatBoxView: View {
    @Environment(GameSession.self) private var gameSession

    @State private var message = ""
    @State private var scrollPosition: UUID?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
            }
            .frame(height: 17)

            Divider()

            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(gameSession.messages) { message in
                        Text(message.content)
                            .id(message.id)
                            .gameText(color: .white)
                    }
                }
            }
            .scrollPosition(id: $scrollPosition, anchor: .bottom)
            .onChange(of: gameSession.messages.count) {
                scrollPosition = gameSession.messages.last?.id
            }
            .frame(height: 56)

            Divider()

            TextField(String(), text: $message)
                .textFieldStyle(.plain)
                #if !os(macOS)
                .textInputAutocapitalization(.never)
                #endif
                .disableAutocorrection(true)
                .gameText(color: .white)
                .frame(height: 25)
                .onSubmit {
                    gameSession.sendMessage(message)
                    message = ""
                }
        }
        .frame(width: 280)
        .background(.black.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .environment(\.colorScheme, .dark)
    }
}

#Preview {
    ChatBoxView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
