//
//  EffectViewerEffectRenderingView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/29.
//

import Combine
import Metal
import RagnarokConstants
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokResources
import SwiftUI

struct EffectViewerEffectRenderingView: View {
    var effect: EffectViewerEffect
    var resourceManager: ResourceManager
    var ez2strEffectCatalog: EZ2STREffectCatalog? = nil
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
        let device = MTLCreateSystemDefaultDevice()!

        if EffectManager.supports(rawEffectID: effect.rawEffectID) || ez2strEffectCatalog?.entry(forRawEffectID: effect.rawEffectID) != nil {
            return try EffectViewerEffectRenderer(
                device: device,
                configuration: .default,
                rawEffectID: effect.rawEffectID,
                resourceManager: resourceManager,
                ez2strEffectCatalog: ez2strEffectCatalog
            )
        }

        let definitions = effect.effectID.map(EffectTable.definitions(for:)) ?? []
        let loader = EffectAssetLoader(resourceManager: resourceManager)
        let assetGroup = try await loader.loadAssetGroup(with: definitions)

        return try EffectViewerEffectRenderer(device: device, configuration: .default, assetGroup: assetGroup)
    }
}
