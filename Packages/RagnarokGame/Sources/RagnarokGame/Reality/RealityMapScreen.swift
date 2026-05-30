//
//  RealityMapScreen.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

#if os(visionOS)

import SwiftUI

struct RealityMapScreen: View {
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

#endif
