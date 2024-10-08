//
//  MapNameView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/30.
//

import RODatabase
import ROLocalizations
import SwiftUI

struct MapNameView: View {
    var map: Map

    @State private var localizedMapName: String?

    var body: some View {
        Text(localizedMapName ?? map.name)
            .task {
                localizedMapName = MapNameTable.shared.localizedMapName(forMapName: map.name)
            }
    }
}

//#Preview {
//    MapNameView()
//}
