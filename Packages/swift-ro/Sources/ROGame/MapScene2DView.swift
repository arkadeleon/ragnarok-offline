//
//  MapScene2DView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/27.
//

import SpriteKit
import SwiftUI

struct MapScene2DView: View {
    var scene: MapScene2D

    var body: some View {
        SpriteView(scene: scene)
    }
}
