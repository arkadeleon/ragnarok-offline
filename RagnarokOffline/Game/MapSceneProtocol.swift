//
//  MapSceneProtocol.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/27.
//

import ROConstants
import ROGame

protocol MapSceneProtocol {
    func onPlayerMoved(_ event: PlayerEvents.Moved)

    func onMapObjectSpawned(_ event: MapObjectEvents.Spawned)
    func onMapObjectMoved(_ event: MapObjectEvents.Moved)
    func onMapObjectStopped(_ event: MapObjectEvents.Stopped)
    func onMapObjectVanished(_ event: MapObjectEvents.Vanished)
    func onMapObjectStateChanged(_ event: MapObjectEvents.StateChanged)
}
