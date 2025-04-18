//
//  ChatBoxView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/16.
//

import SwiftUI

struct ChatBoxView: View {
    var onSubmitMessage: (String) -> Void

    @State private var message = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
            }
            .frame(height: 42)
            .background(.black.opacity(0.5))

            TextField(String(), text: $message)
                .textFieldStyle(.roundedBorder)
                .font(.custom("Arial", fixedSize: 12))
                #if !os(macOS)
                .textInputAutocapitalization(.never)
                #endif
                .disableAutocorrection(true)
                .onSubmit {
                    onSubmitMessage(message)
                    message = ""
                }
        }
        .frame(width: 280)
    }

    init(onSubmitMessage: @escaping (String) -> Void) {
        self.onSubmitMessage = onSubmitMessage
    }
}

#Preview {
    ChatBoxView(onSubmitMessage: { _ in })
        .padding()
}
