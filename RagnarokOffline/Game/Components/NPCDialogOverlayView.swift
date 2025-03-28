//
//  NPCDialogOverlayView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/16.
//

import ROGame
import SwiftUI

struct NPCDialogOverlayView: View {
    var mapSession: MapSession

    @State private var dialog: NPCDialog?

    var body: some View {
        ZStack {
            if let dialog {
                switch dialog.content {
                case .message(let message, let hasNextMessage):
                    NPCMessageDialogView(message: message, hasNextMessage: hasNextMessage) {
                        mapSession.requestNextMessage(npcID: dialog.npcID)
                        self.dialog = nil
                    } closeAction: {
                        mapSession.closeDialog(npcID: dialog.npcID)
                        self.dialog = nil
                    }
                case .menu(let menu):
                    NPCMenuDialogView(menu: menu) { i in
                        mapSession.selectMenu(npcID: dialog.npcID, select: UInt8(i))
                        self.dialog = nil
                    }
                case .numberInput:
                    EmptyView()
                case .textInput:
                    EmptyView()
                }
            }
        }
        .onReceive(mapSession.publisher(for: NPCEvents.DialogReceived.self)) { event in
            dialog = event.dialog
        }
        .onReceive(mapSession.publisher(for: NPCEvents.DialogClosed.self)) { event in
            dialog = nil
        }
    }
}

struct NPCMessageDialogView: View {
    var message: String
    var hasNextMessage: Bool?
    var nextAction: () -> Void
    var closeAction: () -> Void

    var body: some View {
        VStack {
            Text(message)

            if hasNextMessage == true {
                Button {
                    nextAction()
                } label: {
                    Text(verbatim: "Next")
                }
            }

            if hasNextMessage == false {
                Button {
                    closeAction()
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
    var action: (Int) -> Void

    var body: some View {
        VStack {
            ForEach(0..<menu.count, id: \.self) { i in
                Button {
                    action(i + 1)
                } label: {
                    Text(menu[i])
                }
            }

            Button {
                action(255)
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
    var message = """
    [Wounded]
    Wow! Thanks a lot!
    I don't know how this happened to our ship
    but we should go to see the captain.
    """
    var hasNextMessage = true

    NPCMessageDialogView(message: message, hasNextMessage: hasNextMessage) {
    } closeAction: {
    }
}
