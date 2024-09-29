//
//  MessageCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/12.
//

import SwiftUI

struct MessageCell: View {
    var message: any Message

    private var foregroundColor: Color {
        switch message.sender {
        case .client: .white
        case .server: .black
        }
    }

    private var backgroundColor: Color {
        switch message.sender {
        case .client: .blue
        case .server: Color(uiColor: .systemGray6)
        }
    }

    var body: some View {
        HStack {
            if message.sender == .client {
                Spacer()
            }

            Text(message.content)
                .padding(10)
                .foregroundStyle(foregroundColor)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            if message.sender == .server {
                Spacer()
            }
        }
    }
}

#Preview {
    LazyVStack {
        MessageCell(message: .clientText("Login"))
        MessageCell(message: .serverText("Login accepted"))
    }
    .padding()
}
