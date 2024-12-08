//
//  GameMap.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/2.
//

import Observation
import RODatabase
import ROGenerated
import RONetwork

@Observable
final class GameMap {
    let name: String
    let grid: Map.Grid

    let player: Player

    var objects: [UInt32 : Object]

    init(name: String, grid: Map.Grid, position: SIMD2<Int16>) {
        self.name = name
        self.grid = grid
        self.player = Player(position: position)
        self.objects = [:]
    }
}

extension GameMap {
    @Observable
    final class Player {
        var position: SIMD2<Int16>

        init(position: SIMD2<Int16>) {
            self.position = position
        }
    }
}

extension GameMap {
    @Observable
    final class Object: Identifiable {
        let id: UInt32
        let type: UInt8
        let speed: Int16
        let job: Int16
        let name: String

        var bodyState: StatusChangeOption1
        var healthState: StatusChangeOption2
        var effectState: StatusChangeOption

        var position: SIMD2<Int16>

        init(object: MapObject, position: SIMD2<Int16>) {
            self.id = object.id
            self.type = object.type
            self.speed = object.speed
            self.job = object.job
            self.name = object.name

            self.bodyState = object.bodyState
            self.healthState = object.healthState
            self.effectState = object.effectState

            self.position = position
        }
    }
}
