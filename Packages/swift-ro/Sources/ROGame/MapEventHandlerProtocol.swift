//
//  MapEventHandlerProtocol.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/7/8.
//

import RONetwork

@MainActor
protocol MapEventHandlerProtocol {
    func onPlayerMoved(_ event: PlayerEvents.Moved)

    func onItemSpawned(_ event: ItemEvents.Spawned)
    func onItemVanished(_ event: ItemEvents.Vanished)

    func onMapObjectSpawned(_ event: MapObjectEvents.Spawned)
    func onMapObjectMoved(_ event: MapObjectEvents.Moved)
    func onMapObjectStopped(_ event: MapObjectEvents.Stopped)
    func onMapObjectVanished(_ event: MapObjectEvents.Vanished)
    func onMapObjectStateChanged(_ event: MapObjectEvents.StateChanged)
    func onMapObjectActionPerformed(_ event: MapObjectEvents.ActionPerformed)
}
