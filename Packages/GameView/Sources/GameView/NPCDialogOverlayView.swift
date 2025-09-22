//
//  NPCDialogOverlayView.swift
//  GameView
//
//  Created by Leon Li on 2024/12/16.
//

import GameCore
import NetworkClient
import SwiftUI

struct NPCDialogOverlayView: View {
    @Environment(GameSession.self) private var gameSession

    var body: some View {
        if let dialog = gameSession.dialog {
            switch dialog.content {
            case .message(let message, let hasNextMessage):
                NPCMessageDialogView(message: message, hasNextMessage: hasNextMessage)
            case .menu(let menu):
                NPCMenuDialogView(menu: menu)
            case .numberInput:
                EmptyView()
            case .textInput:
                EmptyView()
            }
        }
    }
}

struct NPCMessageDialogView: View {
    var message: String
    var hasNextMessage: Bool?

    @Environment(GameSession.self) private var gameSession

    var body: some View {
        VStack {
            Text(message)

            if hasNextMessage == true {
                Button {
                    gameSession.requestNextMessage()
                } label: {
                    Text(verbatim: "Next")
                }
            }

            if hasNextMessage == false {
                Button {
                    gameSession.closeDialog()
                } label: {
                    Text(verbatim: "Close")
                }
            }
        }
        .padding()
        .frame(width: 280)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct NPCMenuDialogView: View {
    var menu: [String]

    @Environment(GameSession.self) private var gameSession

    var body: some View {
        VStack {
            ForEach(0..<menu.count, id: \.self) { i in
                Button {
                    gameSession.selectMenu(select: UInt8(i + 1))
                } label: {
                    Text(menu[i])
                }
            }

            Button {
                gameSession.selectMenu(select: 255)
            } label: {
                Text(verbatim: "Cancel")
            }
        }
        .padding()
        .frame(width: 280)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    let message = """
    [Wounded]
    Wow! Thanks a lot!
    I don't know how this happened to our ship
    but we should go to see the captain.
    """
    let hasNextMessage = true

    NPCMessageDialogView(message: message, hasNextMessage: hasNextMessage)
        .environment(GameSession.previewing)
}
