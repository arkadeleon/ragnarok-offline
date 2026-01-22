//
//  ChatBoxView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/16.
//

import RagnarokModels
import RagnarokPackets
import SwiftUI

struct ChatBoxView: View {
    enum ViewStyle {
        case compact
        case full
    }

    enum MessageGroup {
        case chat
        case packet

        var title: String {
            switch self {
            case .chat: "Chat"
            case .packet: "Packet"
            }
        }
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
    @State private var messageGroup: MessageGroup = .chat
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
                        MessageGroupButton(group: .chat, selection: $messageGroup)
                        MessageGroupButton(group: .packet, selection: $messageGroup)
                    }
                    .frame(height: ChatBoxView.messageHeaderHeight)

                    Rectangle()
                        .foregroundStyle(Color.white)
                        .frame(height: 1)
                }

                Group {
                    switch messageGroup {
                    case .chat:
                        ChatMessageListView(messages: gameSession.chatMessages)
                    case .packet:
                        PacketMessageListView(messages: gameSession.packetMessages)
                    }
                }
                .frame(height: ChatBoxView.perMessageHeight * CGFloat(ChatBoxView.messageCount(for: viewStyle)))
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

private struct MessageGroupButton: View {
    var group: ChatBoxView.MessageGroup
    @Binding var selection: ChatBoxView.MessageGroup

    var body: some View {
        Button {
            selection = group
        } label: {
            Text(group.title)
                .gameText(color: .white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .background(selection == group ? Color.white.opacity(0.3) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

private struct ChatMessageListView: View {
    var messages: [ChatMessage]

    @State private var scrollPosition: UUID?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(messages) { message in
                    Text(message.content)
                        .id(message.id)
                        .gameText(color: .white)
                }
            }
        }
        .scrollPosition(id: $scrollPosition, anchor: .bottom)
        .onChange(of: messages.count) {
            scrollPosition = messages.last?.id
        }
    }
}

private struct PacketMessageListView: View {
    var messages: [PacketMessage]

    @State private var scrollPosition: UUID?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(messages) { message in
                    Text(content(of: message))
                        .id(message.id)
                        .gameText(color: .white)
                }
            }
        }
        .scrollPosition(id: $scrollPosition, anchor: .bottom)
        .onChange(of: messages.count) {
            scrollPosition = messages.last?.id
        }
    }

    private func content(of message: PacketMessage) -> String {
        switch message.direction {
        case .outgoing:
            "[Send] " + String(describing: type(of: message.packet))
        case .incoming:
            "[Recv] " + String(describing: type(of: message.packet))
        }
    }
}

#Preview {
    let gameSession = {
        let gameSession = GameSession.testing
        gameSession.chatMessages.append(.init(type: .public, content: "You got Apple (1)."))
        gameSession.chatMessages.append(.init(type: .public, content: "You got Banana (1)."))
        gameSession.chatMessages.append(.init(type: .public, content: "You got Grape (1)."))
        gameSession.chatMessages.append(.init(type: .public, content: "You got Carrot (1)."))
        gameSession.chatMessages.append(.init(type: .public, content: "You got Potato (1)."))
        gameSession.chatMessages.append(.init(type: .public, content: "You got Meat (1)."))
        gameSession.chatMessages.append(.init(type: .public, content: "You got Honey (1)."))
        gameSession.chatMessages.append(.init(type: .public, content: "You got Milk (1)."))
        return gameSession
    }()

    VStack {
        Spacer()
        ChatBoxView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray.opacity(0.5))
    .environment(gameSession)
}
