//
//  MapOverlayState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import CoreGraphics
import Observation
import RagnarokModels

@MainActor
@Observable
public final class MapOverlayState {
    var gauges: [GameObjectID : MapGaugeOverlay] = [:]
}

struct MapGaugeOverlay: Identifiable, Sendable {
    var id: GameObjectID
    var hp: Int
    var maxHp: Int
    var sp: Int?
    var maxSp: Int?
    var objectType: MapObjectType

    var worldPosition: SIMD3<Float>?
    var screenPosition: CGPoint?
}
