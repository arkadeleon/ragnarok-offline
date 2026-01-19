//
//  ChatBoxView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/16.
//

import SwiftUI

struct ChatBoxView: View {
    enum ViewStyle {
        case compact
        case full
    }

    static let perMessageHeight: CGFloat = 14
    static let messageHeaderHeight: CGFloat = 22

    static func contentHeight(for viewStyle: ViewStyle) -> CGFloat {
        switch viewStyle {
        case .compact: perMessageHeight * CGFloat(messageCount(for: viewStyle))
        case .full: perMessageHeight * CGFloat(messageCount(for: viewStyle)) + messageHeaderHeight
        }
    }

    static func messageCount(for viewStyle: ViewStyle) -> Int {
        switch viewStyle {
        case .compact: 6
        case .full: 15
        }
    }

    @Environment(GameSession.self) private var gameSession

    @State private var viewStyle: ViewStyle = .compact
    @State private var scrollPosition: UUID?
    @State private var message = ""

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 3) {
            if viewStyle == .full {
                TextField(String(), text: $message)
                    .textFieldStyle(.plain)
                    #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .disableAutocorrection(true)
                    .gameText()
                    .frame(height: 36)
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .focused($isFocused)
                    .onTapGesture {
                        isFocused = true
                    }
                    .onSubmit {
                        gameSession.sendMessage(message)
                        message = ""
                    }
            }

            VStack(spacing: 0) {
                if viewStyle == .full {
                    HStack(spacing: 0) {
                    }
                    .frame(height: ChatBoxView.messageHeaderHeight)

                    Divider()
                        .overlay(Color.white)
                }

                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(gameSession.messages) { message in
                            Text(message.content)
                                .id(message.id)
                                .gameText(color: .white)
                        }
                    }
                }
                .frame(height: ChatBoxView.perMessageHeight * CGFloat(ChatBoxView.messageCount(for: viewStyle)))
                .scrollPosition(id: $scrollPosition, anchor: .bottom)
                .onChange(of: gameSession.messages.count) {
                    scrollPosition = gameSession.messages.last?.id
                }
                .onTapGesture {
                    switch viewStyle {
                    case .compact:
                        self.viewStyle = .full
                    case .full:
                        self.viewStyle = .compact
                    }
                }
            }
            .background(Color.black.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .environment(\.colorScheme, .dark)
        }
        .geometryGroup()
        .animation(.spring(duration: 0.25), value: viewStyle)
    }
}

#Preview {
    let gameSession = {
        let gameSession = GameSession.testing
        gameSession.messages.append(.init(type: .public, content: "You got Apple (1)."))
        gameSession.messages.append(.init(type: .public, content: "You got Banana (1)."))
        gameSession.messages.append(.init(type: .public, content: "You got Grape (1)."))
        gameSession.messages.append(.init(type: .public, content: "You got Carrot (1)."))
        gameSession.messages.append(.init(type: .public, content: "You got Potato (1)."))
        gameSession.messages.append(.init(type: .public, content: "You got Meat (1)."))
        gameSession.messages.append(.init(type: .public, content: "You got Honey (1)."))
        gameSession.messages.append(.init(type: .public, content: "You got Milk (1)."))
        return gameSession
    }()

    VStack {
        Spacer()

        ChatBoxView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray)
    .environment(gameSession)
}
