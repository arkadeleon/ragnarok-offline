//
//  Map.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import RONetwork
import SwiftUI

struct Map: View {
    var mapName: String

    var body: some View {
        ZStack {
            Text(mapName)
        }
    }
}

#Preview {
    Map(mapName: "")
}
