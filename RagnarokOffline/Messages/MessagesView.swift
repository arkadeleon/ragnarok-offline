//
//  MessagesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

import SwiftUI

struct MessagesView: View {
    @Environment(\.conversation) private var conversation

    @State private var pendingCommand: CommandMessage.Command?
    @State private var commandParameters: [String] = []

    @State private var isCommandAlertPresented = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(conversation.messages, id: \.id) { message in
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
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(conversation.availableCommands, id: \.rawValue) { command in
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
                conversation.sendCommand(pendingCommand!, parameters: commandParameters)
                pendingCommand = nil
                commandParameters = []
            }
        }
    }

    private func executeCommand(_ command: CommandMessage.Command) {
        if command.arguments.isEmpty {
            conversation.sendCommand(command)
        } else {
            pendingCommand = command
            commandParameters = Array(repeating: "", count: command.arguments.count)
            isCommandAlertPresented.toggle()
        }
    }
}

#Preview {
    MessagesView()
}
