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
                            .id(message.id)
                    }
                }
                .padding()
            }
            .onAppear {
                proxy.scrollTo(conversation.messages.last?.id)
            }
            .onChange(of: conversation.messages.count) {
                withAnimation {
                    proxy.scrollTo(conversation.messages.last?.id)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(conversation.availableCommands) { command in
                        Button(command.rawValue) {
                            executeCommand(command)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .scrollIndicators(.never)
            .background(.bar)
        }
        .navigationTitle("Messages")
        .alert(pendingCommand?.rawValue ?? "", isPresented: $isArgumentsAlertPresented) {
            ForEach(0..<(pendingCommand?.arguments.count ?? 0), id: \.self) { index in
                TextField(pendingCommand?.arguments[index] ?? "", text: $commandArguments[index])
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }

            Button("Cancel") {
            }

            Button("Send") {
                conversation.executeCommand(pendingCommand!, arguments: commandArguments)
                pendingCommand = nil
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
