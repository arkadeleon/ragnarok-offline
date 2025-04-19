//
//  MapView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/30.
//

import ROConstants
import RONetwork
import SwiftUI

struct MapView<Content>: View where Content: View {
    var mapSession: MapSession
    var scene: any MapSceneProtocol
    var content: () -> Content

    @State private var status: Player.Status?
    @State private var inventory = Inventory()

    @State private var presentedMenuItem: MenuItem?

    var body: some View {
        content()
            .overlay(alignment: .topLeading) {
                if let status {
                    VStack(alignment: .leading, spacing: 0) {
                        BasicInfoView(char: mapSession.char, status: status)

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
                                StatusView(status: status, onIncrementStatusProperty: onIncrementStatusProperty)
                            case .inventory:
                                InventoryView(inventory: inventory, onUseItem: onUseItem, onEquipItem: onEquipItem)
                            }
                        }
                    }
                    .ignoresSafeArea()
                }
            }
            .overlay(alignment: .bottomLeading) {
                ChatBoxView(onSubmitMessage: onSubmitMessage)
            }
            .overlay {
                NPCDialogOverlayView(mapSession: mapSession)
            }
            .onReceive(mapSession.publisher(for: PlayerEvents.Moved.self), perform: scene.onPlayerMoved)
            .onReceive(mapSession.publisher(for: PlayerEvents.StatusChanged.self)) { event in
                status = event.status
            }
            .onReceive(mapSession.publisher(for: ItemEvents.ListReceived.self)) { event in
                inventory = event.inventory
            }
            .onReceive(mapSession.publisher(for: ItemEvents.ListUpdated.self)) { event in
                inventory = event.inventory
            }
            .onReceive(mapSession.publisher(for: ItemEvents.Spawned.self), perform: scene.onItemSpawned)
            .onReceive(mapSession.publisher(for: ItemEvents.Vanished.self), perform: scene.onItemVanished)
            .onReceive(mapSession.publisher(for: MapObjectEvents.Spawned.self), perform: scene.onMapObjectSpawned)
            .onReceive(mapSession.publisher(for: MapObjectEvents.Moved.self), perform: scene.onMapObjectMoved)
            .onReceive(mapSession.publisher(for: MapObjectEvents.Stopped.self), perform: scene.onMapObjectStopped)
            .onReceive(mapSession.publisher(for: MapObjectEvents.Vanished.self), perform: scene.onMapObjectVanished)
            .onReceive(mapSession.publisher(for: MapObjectEvents.StateChanged.self), perform: scene.onMapObjectStateChanged)
            .onReceive(mapSession.publisher(for: MapObjectEvents.ActionPerformed.self), perform: scene.onMapObjectActionPerformed)
    }

    init(mapSession: MapSession, scene: any MapSceneProtocol, @ViewBuilder content: @escaping () -> Content) {
        self.mapSession = mapSession
        self.scene = scene
        self.content = content
    }

    private func onIncrementStatusProperty(_ sp: StatusProperty) {
        mapSession.incrementStatusProperty(sp, by: 1)
    }

    private func onUseItem(_ item: InventoryItem) {
        let accountID = mapSession.account.accountID
        mapSession.useItem(at: item.index, by: accountID)
    }

    private func onEquipItem(_ item: InventoryItem) {
        mapSession.equipItem(at: item.index, location: item.location)
    }

    private func onSubmitMessage(_ message: String) {
        mapSession.sendMessage(message)
    }
}
