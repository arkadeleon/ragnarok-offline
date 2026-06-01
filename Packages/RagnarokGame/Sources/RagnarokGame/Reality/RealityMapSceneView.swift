//
//  RealityMapSceneView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import SwiftUI

@available(visionOS 1.0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
struct RealityMapSceneView: View {
    var scene: RealityMapScene

    @Environment(GameSession.self) private var gameSession
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        Color.clear
            .onAppear {
                Task {
                    await openImmersiveSpace(id: gameSession.immersiveSpaceID)
                }
            }
            .onDisappear {
                Task {
                    await dismissImmersiveSpace()
                }
            }
    }
}
