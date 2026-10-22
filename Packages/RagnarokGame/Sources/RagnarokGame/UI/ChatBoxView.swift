//
//  ChatBoxView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/16.
//

import RagnarokModels
import SwiftUI

struct ChatBoxView: View {
    enum ViewStyle {
        case compact
        case full
    }

    enum MessageGroup {
        case chat
        case command

        var title: String {
            switch self {
            case .chat: "Chat"
            case .command: "Command"
            }
        }
    }

    static let perMessageHeight: CGFloat = 14
    static let messageHeaderHeight: CGFloat = 22
    static let chatInputHeight: CGFloat = 28

    static func contentHeight(for viewStyle: ViewStyle) -> CGFloat {
        switch viewStyle {
        case .compact: perMessageHeight * CGFloat(messageCount(for: viewStyle)) + 1 + chatInputHeight
        case .full: messageHeaderHeight + 1 + perMessageHeight * CGFloat(messageCount(for: viewStyle)) + 1 + chatInputHeight
        }
    }

    static func messageCount(for viewStyle: ViewStyle) -> Int {
        switch viewStyle {
        case .compact: 5
        case .full: 15
        }
    }

    @Environment(GameSession.self) private var gameSession
    @Environment(GameContext.self) private var gameContext

    @State private var viewStyle: ViewStyle = .compact
    @State private var messageGroup: MessageGroup = .chat
    @State private var message = ""

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if viewStyle == .full {
                HStack(spacing: 0) {
                    MessageGroupButton(group: .chat, selection: $messageGroup)
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
                    ChatMessageListView(messages: gameContext.messageCenter.messages)
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

            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 1)

            HStack(spacing: 0) {
                Button {
                } label: {
                    Color.clear
                        .frame(width: 60)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)

                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 1)

                TextField(String(), text: $message)
                    .textFieldStyle(.plain)
                    #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .disableAutocorrection(true)
                    .font(.game())
                    .foregroundStyle(Color.white)
                    .tint(Color.white)
                    .padding(.horizontal, 3)
                    .frame(height: ChatBoxView.chatInputHeight)
                    .focused($isFocused)
                    .onSubmit {
                        send(message)
                    }

                ChatInputHistoryButton(systemImage: "arrow.up") {
                    message = gameContext.messageCenter.inputHistory.previous()
                }
                .disabled(!gameContext.messageCenter.inputHistory.hasPrevious)

                ChatInputHistoryButton(systemImage: "arrow.down") {
                    message = gameContext.messageCenter.inputHistory.next()
                }
                .disabled(!gameContext.messageCenter.inputHistory.hasNext)
            }
            .frame(height: ChatBoxView.chatInputHeight)
        }
        .background(Color.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 3, style: .circular))
        .environment(\.colorScheme, .dark)
        .geometryGroup()
        .animation(.spring(duration: 0.25), value: viewStyle)
    }

    private func send(_ message: String) {
        guard !message.isEmpty else {
            return
        }

        gameSession.sendMessage(message)
        gameContext.messageCenter.inputHistory.push(message)
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

    @State private var scrollPosition = ScrollPosition(edge: .bottom)
    @State private var isAtBottom = true

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
            .padding(.horizontal, 3)
        }
        .scrollPosition($scrollPosition)
        .clipped()
        .onScrollGeometryChange(for: ScrollGeometry.self) { geometry in
            geometry
        } action: { oldGeometry, newGeometry in
            if oldGeometry.containerSize != newGeometry.containerSize && isAtBottom {
                scrollPosition.scrollTo(edge: .bottom)
            } else {
                isAtBottom = newGeometry.visibleRect.maxY >= newGeometry.contentSize.height + newGeometry.contentInsets.bottom - 1
            }
        }
        .onChange(of: messages.last?.id) {
            if isAtBottom {
                scrollPosition.scrollTo(edge: .bottom)
            }
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
                                        .clipShape(RoundedRectangle(cornerRadius: 3, style: .circular))
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
        .clipped()
    }
}

private struct ChatInputHistoryButton: View {
    var systemImage: String
    var action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.game(size: 10, weight: .bold))
                .foregroundStyle(Color.white.opacity(isEnabled ? 1 : 0.3))
                .frame(width: ChatBoxView.chatInputHeight, height: ChatBoxView.chatInputHeight)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let gameSession = {
        let gameSession = GameSession.testing
        gameSession.context.messageCenter.add(ChatMessage(type: .public, content: "You got Apple (1)."))
        gameSession.context.messageCenter.add(ChatMessage(type: .public, content: "You got Banana (1)."))
        gameSession.context.messageCenter.add(ChatMessage(type: .public, content: "You got Grape (1)."))
        gameSession.context.messageCenter.add(ChatMessage(type: .public, content: "You got Carrot (1)."))
        gameSession.context.messageCenter.add(ChatMessage(type: .public, content: "You got Potato (1)."))
        gameSession.context.messageCenter.add(ChatMessage(type: .public, content: "You got Meat (1)."))
        gameSession.context.messageCenter.add(ChatMessage(type: .public, content: "You got Honey (1)."))
        gameSession.context.messageCenter.add(ChatMessage(type: .public, content: "You got Milk (1)."))
        return gameSession
    }()

    VStack {
        Spacer()
        ChatBoxView()
    }
    .ignoresSafeArea()
    .environment(gameSession)
    .environment(gameSession.context)
}
