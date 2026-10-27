//
//  ChatClientView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

import SwiftUI

struct ChatClientView: View {
    @Environment(ChatSession.self) private var chatSession

    @State private var scrollPosition = ScrollPosition(edge: .bottom)
    @State private var isAtBottom = true

    @State private var pendingMessageContent: String = ""
    @State private var pendingCommand: CommandMessage.Command?
    @State private var commandParameters: [String] = []

    @State private var isCommandAlertPresented = false

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(chatSession.messages, id: \.id) { message in
                    MessageCell(message: message)
                        .id(message.id)
                }
            }
            .padding()
        }
        .scrollPosition($scrollPosition)
        .onScrollGeometryChange(for: ScrollGeometry.self) { geometry in
            geometry
        } action: { oldGeometry, newGeometry in
            if isAtBottom && (oldGeometry.containerSize != newGeometry.containerSize || oldGeometry.contentSize != newGeometry.contentSize) {
                scrollPosition.scrollTo(edge: .bottom)
            } else {
                isAtBottom = newGeometry.visibleRect.maxY >= newGeometry.contentSize.height + newGeometry.contentInsets.bottom - 1
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack(spacing: 16) {
                TextField("Message", text: $pendingMessageContent)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        sendPendingMessage()
                    }

                Menu {
                    ForEach(chatSession.availableCommands, id: \.rawValue) { command in
                        Button(command.rawValue) {
                            executeCommand(command)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .padding()
            .background(.bar)
        }
        .background(.background)
        .navigationTitle("Chat Client")
        .alert(pendingCommand?.rawValue ?? "", isPresented: $isCommandAlertPresented) {
            ForEach(0..<(pendingCommand?.arguments.count ?? 0), id: \.self) { index in
                TextField(pendingCommand?.arguments[index] ?? "", text: $commandParameters[index])
                    #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .disableAutocorrection(true)
            }

            Button("Cancel") {
            }

            Button("Send") {
                sendPendingCommand()
            }
        }
    }

    private func sendPendingMessage() {
        guard !pendingMessageContent.isEmpty else {
            return
        }

        if let command = CommandMessage.Command(rawValue: pendingMessageContent.lowercased()) {
            executeCommand(command)
        } else {
            chatSession.sendMessage(pendingMessageContent)
        }

        pendingMessageContent = ""
    }

    private func executeCommand(_ command: CommandMessage.Command) {
        if command.arguments.isEmpty {
            chatSession.sendCommand(command)
        } else {
            pendingCommand = command
            commandParameters = Array(repeating: "", count: command.arguments.count)
            isCommandAlertPresented.toggle()
        }
    }

    private func sendPendingCommand() {
        chatSession.sendCommand(pendingCommand!, parameters: commandParameters)
        pendingCommand = nil
        commandParameters = []
    }
}

#Preview {
    ChatClientView()
        .environment(ChatSession.previewing)
}
