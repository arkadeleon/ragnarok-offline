//
//  MapCellView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/6.
//

import RODatabase
import SwiftUI

struct MapCellView: View {
    var x: Int16
    var y: Int16
    var cell: Map.Cell
    var player: GameMap.Player?
    var objects: [GameMap.Object]

    @Environment(\.gameSession) private var gameSession

    var body: some View {
        ZStack {
            if cell.isWalkable {
                Button {
                    gameSession.requestMove(x: x, y: y)
                } label: {
                    Color.green
                        .frame(width: 20, height: 20)
                }
            } else {
                Color.gray
                    .frame(width: 20, height: 20)
            }

            if let player {
                Text(verbatim: "P")
            }

            if let object = objects.last {
                Text(verbatim: "O")
            }
        }
        .frame(width: 20, height: 20)
    }
}
