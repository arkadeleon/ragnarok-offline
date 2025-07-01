//
//  ChatView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

import SwiftUI

struct ChatView: View {
    @Environment(ChatSession.self) private var chatSession

    @State private var position = ScrollPosition(idType: UUID.self)

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
        .scrollPosition($position)
        .onAppear {
            if let id = chatSession.messages.last?.id {
                position.scrollTo(id: id)
            }
        }
        .onChange(of: chatSession.messages.count) {
            if let id = chatSession.messages.last?.id {
                withAnimation {
                    position.scrollTo(id: id)
                }
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
        .navigationTitle("Chat")
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
    ChatView()
        .environment(ChatSession())
}
