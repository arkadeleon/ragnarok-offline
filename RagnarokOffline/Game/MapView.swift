//
//  MapView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/30.
//

import ROConstants
import ROGame
import RONetwork
import SwiftUI

struct MapView: View {
    var scene: any MapSceneProtocol

    @Environment(GameSession.self) private var gameSession

    @State private var presentedMenuItem: MenuItem?

    var body: some View {
        MapSceneView(scene: scene)
            .overlay(alignment: .topLeading) {
                if let char = gameSession.char, let status = gameSession.status {
                    VStack(alignment: .leading, spacing: 0) {
                        BasicInfoView(char: char, status: status)

                        MenuView { item in
                            if item == presentedMenuItem {
                                presentedMenuItem = nil
                            } else {
                                presentedMenuItem = item
                            }
                        }

                        if let presentedMenuItem {
                            switch presentedMenuItem {
                            case .status:
                                StatusView(status: status)
                            case .inventory:
                                InventoryView(inventory: gameSession.inventory)
                            }
                        }
                    }
                }
            }
            .overlay(alignment: .bottomLeading) {
                ChatBoxView()
            }
            .overlay {
                NPCDialogOverlayView()
            }
    }
}
