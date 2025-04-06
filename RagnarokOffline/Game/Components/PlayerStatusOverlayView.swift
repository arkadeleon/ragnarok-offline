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
        .onReceive(mapSession.publisher(for: PlayerEvents.StatusChanged.self)) { event in
            status = event.status
        }
    }
}

struct PlayerStatusView: View {
    var status: Player.Status

    var body: some View {
        VStack(alignment: .leading) {
            GameText("HP: \(status.hp) / \(status.maxHp)")
            GameText("SP: \(status.sp) / \(status.maxSp)")
            GameText("Base Level: \(status.baseLevel) [\(status.baseExp) | \(status.baseExpNext)]")
            GameText("Job Level: \(status.jobLevel) [\(status.jobExp) | \(status.jobExpNext)]")
            GameText("Weight: \(status.weight) / \(status.maxWeight)")
            GameText("Zeny: \(status.zeny)")
            GameText("Str: \(status.str) + \(status.str2) [\(status.str3)]")
            GameText("Agi: \(status.agi) + \(status.agi2) [\(status.agi3)]")
            GameText("Vit: \(status.vit) + \(status.vit2) [\(status.vit3)]")
            GameText("Int: \(status.int) + \(status.int2) [\(status.int3)]")
            GameText("Dex: \(status.dex) + \(status.dex2) [\(status.dex3)]")
            GameText("Luk: \(status.luk) + \(status.luk2) [\(status.luk3)]")
            GameText("Atk: \(status.atk) + \(status.atk2)")
            GameText("Def: \(status.def) + \(status.def2)")
            GameText("Matk: \(status.matk) + \(status.matk2)")
            GameText("Mdef: \(status.mdef) + \(status.mdef2)")
            GameText("Hit: \(status.hit)")
            GameText("Flee: \(status.flee) + \(status.flee2)")
            GameText("Critical: \(status.critical)")
            GameText("Aspd: \(status.aspd)")
            GameText("Status Point: \(status.statusPoint)")
        }
    }
}

#Preview {
    var status = Player.Status()

    PlayerStatusView(status: status)
}
