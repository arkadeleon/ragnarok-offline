//
//  MessagesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

import SwiftUI

struct MessagesView: View {
    @Environment(\.conversation) private var conversation

    @State private var editingMessageContent = ""

    @State private var pendingCommand: MessageCommand?
    @State private var commandArguments: [String] = []

    @State private var isArgumentsAlertPresented = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(conversation.messages) { message in
                        MessageCell(message: message)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 16) {
                TextField("Message", text: $editingMessageContent)
                    .textFieldStyle(.roundedBorder)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane")
                        .font(.system(size: 20))
                }

                Menu {
                    ForEach(MessageCommand.allCases) { command in
                        Button(command.rawValue) {
                            executeCommand(command)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20))
                }
            }
            .padding()
            .background(.bar)
        }
        .navigationTitle("Messages")
        .alert(pendingCommand?.rawValue ?? "", isPresented: $isArgumentsAlertPresented) {
            ForEach(0..<(pendingCommand?.arguments.count ?? 0), id: \.self) { index in
                TextField(pendingCommand?.arguments[index] ?? "", text: $commandArguments[index])
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }

            Button("Done") {
                conversation.executeCommand(pendingCommand!, arguments: commandArguments)
                pendingCommand = nil
            }
        }
    }

    private func sendMessage() {
        guard !editingMessageContent.isEmpty else {
            return
        }

        if let command = MessageCommand(rawValue: editingMessageContent) {
            executeCommand(command)
        } else {
            let message = Message(sender: .client, content: editingMessageContent)
            conversation.messages.append(message)
        }

        editingMessageContent = ""
    }

    private func executeCommand(_ command: MessageCommand) {
        if command.arguments.isEmpty {
            conversation.executeCommand(command)
        } else {
            pendingCommand = command
            commandArguments = .init(repeating: "", count: command.arguments.count)
            isArgumentsAlertPresented.toggle()
        }
    }
}

#Preview {
    MessagesView()
}
