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
                    Color.green.opacity(0.5)
                }
                .buttonStyle(.plain)
            } else {
                Color.gray.opacity(0.5)
            }
        }
        .frame(width: 32, height: 32)
        .overlay {
            if let player {
                Circle()
                    .fill(.white)
                    .frame(width: 30, height: 30)
            }

            ForEach(objects) { object in
                if object.effectState != .cloak {
                    Button {
                        gameSession.contactNPC(npcID: object.id)
                    } label: {
                        Text(object.name)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
