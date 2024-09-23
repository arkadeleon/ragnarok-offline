//
//  MessagesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

import SwiftUI

struct MessagesView: View {
    @Environment(\.conversation) private var conversation

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
                Menu {
                    ForEach(MessageCommand.allCases) { command in
                        Button(command.rawValue) {
                            executeCommand(command)
                        }
                    }
                } label: {
                    Image(systemName: "paperplane")
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
            }
            .frame(maxWidth: .infinity)
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

            Button("Cancel") {
            }
        }
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
