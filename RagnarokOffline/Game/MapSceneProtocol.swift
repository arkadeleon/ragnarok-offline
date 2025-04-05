//
//  MapSceneProtocol.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/27.
//

import ROConstants
import ROGame

@MainActor
protocol MapSceneProtocol {
    func onPlayerMoved(_ event: PlayerEvents.Moved)

    func onMapObjectSpawned(_ event: MapObjectEvents.Spawned)
    func onMapObjectMoved(_ event: MapObjectEvents.Moved)
    func onMapObjectStopped(_ event: MapObjectEvents.Stopped)
    func onMapObjectVanished(_ event: MapObjectEvents.Vanished)
    func onMapObjectStateChanged(_ event: MapObjectEvents.StateChanged)
    func onMapObjectActionPerformed(_ event: MapObjectEvents.ActionPerformed)

    func onMapItemSpawned(_ event: MapItemEvents.Spawned)
    func onMapItemVanished(_ event: MapItemEvents.Vanished)
}
