//
//  GameMap.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/2.
//

import Observation
import RODatabase

@Observable
final class GameMap {
    let name: String
    let grid: Map.Grid

    var player: Player

    var objects: [Object]

    init(name: String, grid: Map.Grid, position: SIMD2<Int16>) {
        self.name = name
        self.grid = grid
        self.player = Player(position: position)
        self.objects = []
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
    final class Object {
        var position: SIMD2<Int16>

        init(position: SIMD2<Int16>) {
            self.position = position
        }
    }
}
