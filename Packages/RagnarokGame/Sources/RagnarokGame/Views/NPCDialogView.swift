//
//  NPCDialogView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/12/16.
//

import SwiftUI

struct NPCDialogView: View {
    var dialog: NPCDialog

    @Environment(GameSession.self) private var gameSession

    @State private var selectedMenuItem = 0

    var body: some View {
        VStack {
            Text(dialog.message)

            if let action = dialog.action {
                HStack {
                    Spacer()

                    switch action {
                    case .next:
                        Button {
                            gameSession.requestNextMessage()
                        } label: {
                            Text(verbatim: "Next")
                        }
                    case .close:
                        Button {
                            gameSession.closeDialog()
                        } label: {
                            Text(verbatim: "Close")
                        }
                    }
                }
            }

            if let menu = dialog.menu {
                HStack {
                    Picker("", selection: $selectedMenuItem) {
                        ForEach(0..<menu.count, id: \.self) { i in
                            Text(menu[i]).tag(i)
                        }
                    }
                    .pickerStyle(.menu)

                    Spacer()
                }

                HStack {
                    Spacer()

                    Button {
                        gameSession.selectMenu(UInt8(selectedMenuItem + 1))
                    } label: {
                        Text(verbatim: "OK")
                    }

                    Button {
                        gameSession.cancelMenu()
                    } label: {
                        Text(verbatim: "Cancel")
                    }
                }
            }

            if dialog.input == .number {

            }

            if dialog.input == .text {

            }
        }
        .padding()
        .frame(width: 280)
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    let dialog: NPCDialog = {
        let message = """
        [Wounded]
        Wow! Thanks a lot!
        I don't know how this happened to our ship
        but we should go to see the captain.
        """
        let dialog = NPCDialog(npcID: 0, message: message)
        dialog.action = .next
        dialog.menu = [
            "1", "2"
        ]
        return dialog
    }()

    NPCDialogView(dialog: dialog)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
