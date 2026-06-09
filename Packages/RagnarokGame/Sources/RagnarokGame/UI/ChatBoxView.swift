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
        case command

        var title: String {
            switch self {
            case .chat: "Chat"
            case .packet: "Packet"
            case .command: "Command"
            }
        }
    }

    static let perMessageHeight: CGFloat = 14
    static let messageHeaderHeight: CGFloat = 22
    static let chatInputHeight: CGFloat = 36

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
                    .font(.game())
                    .foregroundStyle(Color.gameLabel)
                    .padding(.horizontal, 6)
                    .frame(height: ChatBoxView.chatInputHeight)
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .focused($isFocused)
                    .onSubmit {
                        send(message)
                    }
            }

            VStack(spacing: 0) {
                if viewStyle == .full {
                    HStack(spacing: 0) {
                        MessageGroupButton(group: .chat, selection: $messageGroup)
                        MessageGroupButton(group: .packet, selection: $messageGroup)
                        MessageGroupButton(group: .command, selection: $messageGroup)
                    }
                    .frame(height: ChatBoxView.messageHeaderHeight)

                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 1)
                }

                Group {
                    switch messageGroup {
                    case .chat:
                        ChatMessageListView(messages: gameSession.messageCenter.messages)
                    case .packet:
                        PacketMessageListView(messages: gameSession.packetMessages)
                    case .command:
                        AtCommandShortcutListView(groups: AtCommandShortcutGroup.allGroups) { shortcut in
                            send(shortcut.command)
                        }
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

    private func send(_ message: String) {
        guard !message.isEmpty else {
            return
        }

        gameSession.sendMessage(message)
        self.message = ""
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
                .font(.game())
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .background(selection == group ? Color.white.opacity(0.3) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

private struct ChatMessageListView: View {
    var messages: [MessageCenter.Message]

    @State private var scrollPosition: UUID?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(messages) { message in
                    Text(message.content)
                        .id(message.id)
                        .font(.game())
                        .foregroundStyle(Color.white)
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
                        .font(.game())
                        .foregroundStyle(Color.white)
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

private struct AtCommandShortcutListView: View {
    var groups: [AtCommandShortcutGroup]
    var shortcutAction: (AtCommandShortcut) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(groups) { group in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(group.title)
                            .font(.game(size: 10))
                            .foregroundStyle(Color.white.opacity(0.7))

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 3)], spacing: 3) {
                            ForEach(group.shortcuts) { shortcut in
                                Button {
                                    shortcutAction(shortcut)
                                } label: {
                                    Text(shortcut.title)
                                        .font(.game())
                                        .foregroundStyle(Color.white)
                                        .lineLimit(1)
                                        .padding(.horizontal, 6)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 22)
                                        .background(Color.white.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 3))
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(8)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    let gameSession = {
        let gameSession = GameSession.testing
        gameSession.messageCenter.add(ChatMessage(type: .public, content: "You got Apple (1)."))
        gameSession.messageCenter.add(ChatMessage(type: .public, content: "You got Banana (1)."))
        gameSession.messageCenter.add(ChatMessage(type: .public, content: "You got Grape (1)."))
        gameSession.messageCenter.add(ChatMessage(type: .public, content: "You got Carrot (1)."))
        gameSession.messageCenter.add(ChatMessage(type: .public, content: "You got Potato (1)."))
        gameSession.messageCenter.add(ChatMessage(type: .public, content: "You got Meat (1)."))
        gameSession.messageCenter.add(ChatMessage(type: .public, content: "You got Honey (1)."))
        gameSession.messageCenter.add(ChatMessage(type: .public, content: "You got Milk (1)."))
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
