//
//  MapView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import RODatabase
import SwiftUI

struct MapView: View {
    var map: GameMap

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            LazyVStack(spacing: 1) {
                ForEach(0..<map.grid.ys, id: \.self) { y in
                    LazyHStack(spacing: 1) {
                        ForEach(0..<map.grid.xs, id: \.self) { x in
                            MapCellView(
                                x: x,
                                y: y,
                                cell: map.grid.cell(atX: x, y: y),
                                player: player(at: [x, y]),
                                objects: objects(at: [x, y])
                            )
                        }
                    }
                }
            }

//            LazyVGrid(columns: [GridItem](repeating: .init(.fixed(20), spacing: 1), count: Int(map.grid.xs)), spacing: 1) {
//                ForEach(map.grid.cells, id: \.xy) { cell in
//                    MapCellView()
//                }
//            }

//            Grid(horizontalSpacing: 1, verticalSpacing: 1) {
//                ForEach(0..<map.grid.ys, id: \.self) { y in
//                    GridRow {
//                        ForEach(0..<map.grid.xs, id: \.self) { x in
//                            MapCellView()
//                        }
//                    }
//                }
//            }
        }
    }

    private func player(at position: SIMD2<Int16>) -> GameMap.Player? {
        map.player.position == position ? map.player : nil
    }

    private func objects(at position: SIMD2<Int16>) -> [GameMap.Object] {
        map.objects.filter {
            $0.position == position
        }
    }
}

#Preview {
    struct AsyncMapView: View {
        @State private var map: GameMap?

        var body: some View {
            ZStack {
                if let map {
                    MapView(map: map)
                } else {
                    ProgressView()
                }
            }
            .task {
                let map = try! await MapDatabase.renewal.map(forName: "iz_int")!
                let grid = map.grid()!
                self.map = GameMap(name: "iz_int", grid: grid, position: [18, 26])
            }
        }
    }

    return AsyncMapView()
}
