//
//  CharacterSimulatorView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/25.
//

import SwiftUI

struct CharacterSimulatorView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        @Bindable var characterSimulator = appModel.characterSimulator

        AdaptiveView {
            VStack(spacing: 0) {
                CharacterRenderingView()
                    .frame(minHeight: 0, maxHeight: 300)

                Divider()

                CharacterConfigurationView()
                    .frame(minHeight: 0, maxHeight: .infinity)
            }
        } regular: {
            HStack {
                CharacterRenderingView()
                    .frame(minWidth: 0, maxWidth: .infinity)

                CharacterConfigurationView()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(.background.secondary)
                    .scrollContentBackground(.hidden)
            }
            .background(.background)
            .toolbarTitleDisplayMode(.automatic)
        }
        .navigationTitle("Character Simulator")
        .task {
            characterSimulator.renderSprite()
        }
    }
}

#Preview {
    NavigationStack {
        CharacterSimulatorView()
            .environment(AppModel())
    }
}
