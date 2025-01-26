//
//  MessagesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

import SwiftUI

struct MessagesView: View {
    var conversation: Conversation

    @State private var position = ScrollPosition(idType: UUID.self)

    @State private var pendingCommand: CommandMessage.Command?
    @State private var commandParameters: [String] = []

    @State private var isCommandAlertPresented = false

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(conversation.messages, id: \.id) { message in
                    MessageCell(message: message)
                        .id(message.id)
                }
            }
            .padding()
        }
        .scrollPosition($position)
        .onAppear {
            if let id = conversation.messages.last?.id {
                position.scrollTo(id: id)
            }
        }
        .onChange(of: conversation.messages.count) {
            if let id = conversation.messages.last?.id {
                withAnimation {
                    position.scrollTo(id: id)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(conversation.availableCommands, id: \.rawValue) { command in
                        Button(command.rawValue) {
                            Task {
                                await executeCommand(command)
                            }
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
        .background(.background)
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
                Task {
                    await sendPendingCommand()
                }
            }
        }
    }

    private func executeCommand(_ command: CommandMessage.Command) async {
        if command.arguments.isEmpty {
            await conversation.sendCommand(command)
        } else {
            pendingCommand = command
            commandParameters = Array(repeating: "", count: command.arguments.count)
            isCommandAlertPresented.toggle()
        }
    }

    private func sendPendingCommand() async {
        await conversation.sendCommand(pendingCommand!, parameters: commandParameters)
        pendingCommand = nil
        commandParameters = []
    }
}

#Preview {
    MessagesView(conversation: Conversation())
}
