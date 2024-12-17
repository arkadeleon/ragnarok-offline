//
//  NPCDialogBox.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/16.
//

import RONetwork
import SwiftUI

struct NPCDialogBox: View {
    var mapSession: MapSession
    @Binding var dialog: NPCDialog?

    var body: some View {
        ZStack {
            if let dialog {
                switch dialog.content {
                case .message(let message, let hasNextMessage):
                    VStack {
                        Text(message)

                        if hasNextMessage == true {
                            Button {
                                self.dialog = nil
                                mapSession.requestNextMessage(npcID: dialog.npcID)
                            } label: {
                                Text(verbatim: "Next")
                            }
                        }

                        if hasNextMessage == false {
                            Button {
                                self.dialog = nil
                                mapSession.closeDialog(npcID: dialog.npcID)
                            } label: {
                                Text(verbatim: "Close")
                            }
                        }
                    }
                    .padding()
                    .frame(width: 280)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                case .menu(let menu):
                    VStack {
                        ForEach(0..<menu.count, id: \.self) { i in
                            Button {
                                self.dialog = nil
                                mapSession.selectMenu(npcID: dialog.npcID, select: UInt8(i + 1))
                            } label: {
                                Text(menu[i])
                            }
                        }

                        Button {
                            mapSession.selectMenu(npcID: dialog.npcID, select: 255)
                        } label: {
                            Text(verbatim: "Cancel")
                        }
                    }
                    .padding()
                    .frame(width: 280)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                case .numberInput:
                    EmptyView()
                case .textInput:
                    EmptyView()
                }
            }
        }
    }
}

//#Preview {
//    let dialog = NPCDialog(npcID: 0, content: .message(message: """
//    [Wounded]
//    Wow! Thanks a lot!
//    I don't know how this happened to our ship
//    but we should go to see the captain.
//    """, hasNextMessage: true))
//
//    NPCDialogBox(mapSession: MapSession(), dialog: .constant(dialog))
//}
