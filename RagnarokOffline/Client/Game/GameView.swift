//
//  GameView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import MetalKit
import SwiftUI

struct GameView: View {
    let renderer = GameRenderer()

    @State private var magnification = 1.0
    @State private var dragTranslation = CGSize()

    var body: some View {
        MetalView(renderer: renderer)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        renderer.camera.update(magnification: magnification * value, dragTranslation: dragTranslation)
                    }
                    .onEnded { value in
                        magnification *= value
                    }
            )
            .navigationTitle("Game")
            .navigationBarTitleDisplayMode(.inline)
    }
}
