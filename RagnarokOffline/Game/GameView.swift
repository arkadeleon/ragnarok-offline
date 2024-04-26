//
//  GameView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/7.
//

import SwiftUI

struct GameView: View {
    private let renderer: GameRenderer = {
        let device = MTLCreateSystemDefaultDevice()!
        let renderer = GameRenderer(device: device)
        return renderer
    }()

    @State private var translation: CGSize = .zero
    @State private var magnification: CGFloat = 1

    var body: some View {
        MetalView(renderer: renderer)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let offset = CGPoint(x: translation.width + value.translation.width, y: translation.height - value.translation.height)
                        renderer.scene.camera.move(offset: offset)
                    }
                    .onEnded { value in
                        translation.width += value.translation.width
                        translation.height -= value.translation.height
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        renderer.scene.camera.update(magnification: magnification * value, dragTranslation: .zero)
                    }
                    .onEnded { value in
                        magnification *= value
                    }
            )
            .navigationTitle("Cube")
            .navigationBarTitleDisplayMode(.inline)
    }
}
