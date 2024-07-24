//
//  MapServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/24.
//

import rAthenaMap
import SwiftUI

struct MapServerView: View {
    var mapServer: ObservableServer

    var body: some View {
        ServerView(server: mapServer)
    }
}

#Preview {
    let mapServer = ObservableServer(server: MapServer.shared)
    return MapServerView(mapServer: mapServer)
}
