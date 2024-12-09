//
//  MapView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import RODatabase
import SpriteKit
import SwiftUI

struct MapView: View {
    var scene: GameMapScene

    @Environment(\.gameSession) private var gameSession

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .overlay {
                if let dialog = gameSession.npcDialog {
                    VStack {
                        Text(dialog.message)

                        if dialog.showsNextButton {
                            Button {
                                gameSession.requestNextScript(npcID: dialog.npcID)
                            } label: {
                                Text(verbatim: "Next")
                            }
                        }

                        if dialog.showsCloseButton {
                            Button {
                                gameSession.closeDialog(npcID: dialog.npcID)
                            } label: {
                                Text(verbatim: "Close")
                            }
                        }
                    }
                    .padding()
                    .frame(width: 280)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }

                if let dialog = gameSession.npcMenuDialog {
                    VStack {
                        ForEach(0..<dialog.items.count, id: \.self) { i in
                            Button {
                                gameSession.selectMenu(npcID: dialog.npcID, select: UInt8(i + 1))
                            } label: {
                                Text(dialog.items[i])
                            }
                        }

                        Button {
                            gameSession.selectMenu(npcID: dialog.npcID, select: 255)
                        } label: {
                            Text(verbatim: "Cancel")
                        }
                    }
                    .padding()
                    .frame(width: 280)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
    }
}

#Preview {
    struct AsyncMapView: View {
        @State private var scene: GameMapScene?

        @Environment(\.gameSession) private var gameSession

        var body: some View {
            ZStack {
                if let scene {
                    MapView(scene: scene)
                } else {
                    ProgressView()
                }
            }
            .task {
                let map = try! await MapDatabase.renewal.map(forName: "iz_int")!
                let grid = map.grid()!
                self.scene = GameMapScene(name: "iz_int", grid: grid, position: [18, 26])

                let dialog = GameNPCDialog(npcID: 0, message: """
                [Wounded]
                Wow! Thanks a lot!
                I don't know how this happened to our ship
                but we should go to see the captain.
                """)
                dialog.showsNextButton = true
                gameSession.npcDialog = dialog
            }
        }
    }

    return AsyncMapView()
}
