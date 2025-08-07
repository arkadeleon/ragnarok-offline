//
//  MapView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/30.
//

import RealityKit
import ROGame
import SwiftUI

struct MapView: View {
    var scene: MapScene

    @Environment(GameSession.self) private var gameSession

    @State private var distance: Float = 80
    @State private var presentedMenuItem: MenuItem?

    var body: some View {
        RealityView { content in
            content.add(scene.rootEntity)
        } update: { content in
        } placeholder: {
            ProgressView()
        }
        .ignoresSafeArea()
        .gesture(scene.tileTapGesture)
        .gesture(scene.mapObjectTapGesture)
        .gesture(scene.mapItemTapGesture)
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
        .overlay(alignment: .bottomTrailing) {
            Slider(value: $distance, in: 2...300)
                .onChange(of: distance) {
                    scene.distance = distance
                }
        }
        .overlay {
            NPCDialogOverlayView()
        }
    }
}
