//
//  PlayerStatusOverlayView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/19.
//

import ROGame
import SwiftUI

struct PlayerStatusOverlayView: View {
    var mapSession: MapSession

    @State private var status: Player.Status?

    var body: some View {
        ZStack {
            if let status {
                PlayerStatusView(status: status)
            }
        }
        .task {
            status = await mapSession.storage.player?.status
        }
        .onReceive(mapSession.publisher(for: PlayerEvents.StatusChanged.self)) { event in
            status = event.status
        }
    }
}

struct PlayerStatusView: View {
    var status: Player.Status

    var body: some View {
        VStack(alignment: .leading) {
            Text(verbatim: "HP: \(status.hp) / \(status.maxHp)")
            Text(verbatim: "SP: \(status.sp) / \(status.maxSp)")
            Text(verbatim: "Base Level: \(status.baseLevel) [\(status.baseExp) | \(status.baseExpNext)]")
            Text(verbatim: "Job Level: \(status.jobLevel) [\(status.jobExp) | \(status.jobExpNext)]")
            Text(verbatim: "Weight: \(status.weight) / \(status.maxWeight)")
            Text(verbatim: "Zeny: \(status.zeny)")
            Text(verbatim: "Str: \(status.str) + \(status.str2) [\(status.str3)]")
            Text(verbatim: "Agi: \(status.agi) + \(status.agi2) [\(status.agi3)]")
            Text(verbatim: "Vit: \(status.vit) + \(status.vit2) [\(status.vit3)]")
            Text(verbatim: "Int: \(status.int) + \(status.int2) [\(status.int3)]")
            Text(verbatim: "Dex: \(status.dex) + \(status.dex2) [\(status.dex3)]")
            Text(verbatim: "Luk: \(status.luk) + \(status.luk2) [\(status.luk3)]")
            Text(verbatim: "Atk: \(status.atk) + \(status.atk2)")
            Text(verbatim: "Def: \(status.def) + \(status.def2)")
            Text(verbatim: "Matk: \(status.matk) + \(status.matk2)")
            Text(verbatim: "Mdef: \(status.mdef) + \(status.mdef2)")
            Text(verbatim: "Hit: \(status.hit)")
            Text(verbatim: "Flee: \(status.flee) + \(status.flee2)")
            Text(verbatim: "Critical: \(status.critical)")
            Text(verbatim: "Aspd: \(status.aspd)")
            Text(verbatim: "Status Point: \(status.statusPoint)")
        }
    }
}

#Preview {
    var status = Player.Status()

    PlayerStatusView(status: status)
}
