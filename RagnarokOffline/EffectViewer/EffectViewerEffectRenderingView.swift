//
//  EffectViewerEffectRenderingView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/29.
//

import Metal
import RagnarokConstants
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokResources
import SwiftUI

struct EffectViewerEffectRenderingView: View {
    var effectID: EffectID
    var resourceManager: ResourceManager
    var onReplay: () -> Void

    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    @State private var isComplete = false

    var body: some View {
        AsyncContentView {
            try await loadRenderer()
        } content: { renderer in
            ZStack {
                if isComplete {
                    Button(action: onReplay) {
                        Label {
                            Text("Replay", tableName: "EffectViewer")
                        } icon: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .font(.title3)
                        .fontWeight(.medium)
                    }
                    .adaptiveProminentButtonStyle()
                } else {
                    MetalViewContainer(renderer: renderer)
                }
            }
            .onReceive(timer) { _ in
                isComplete = renderer.isComplete(atTime: CACurrentMediaTime())
            }
        }
    }

    private func loadRenderer() async throws -> EffectViewerEffectRenderer {
        let definitions = EffectTable.definitions(for: effectID).map { $0.resolved() }

        let device = MTLCreateSystemDefaultDevice()!
        let loader = EffectAssetLoader(resourceManager: resourceManager)
        var assets: [EffectAsset] = []

        for definition in definitions {
            let asset = try await loader.loadAsset(with: definition)
            assets.append(asset)
        }

        let renderer = try EffectViewerEffectRenderer(device: device, assets: assets)
        return renderer
    }
}
