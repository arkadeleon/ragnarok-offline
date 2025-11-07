//
//  ServerStartupTip.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/10/13.
//

import SwiftUI
import TipKit

struct ServerStartupTip: Tip {
    var title: Text {
        Text("Start All Servers")
    }

    var message: Text? {
        Text("Make sure all the servers are running before starting the game client.")
    }

    var image: Image? {
        Image(systemName: "server.rack")
    }
}
