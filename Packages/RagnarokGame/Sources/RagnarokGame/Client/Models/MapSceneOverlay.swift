//
//  MapSceneOverlay.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/1/30.
//

import Foundation
import RagnarokModels

@MainActor
@Observable
class MapSceneOverlay {
    struct Gauge: Identifiable, Sendable {
        let objectID: UInt32
        var screenPosition: CGPoint
        var hp: Int
        var maxHp: Int
        var sp: Int?
        var maxSp: Int?
        var objectType: MapObjectType

        var id: UInt32 {
            objectID
        }
    }

    var gauges: [UInt32 : MapSceneOverlay.Gauge] = [:]

    func clearAll() {
        gauges.removeAll()
    }
}
