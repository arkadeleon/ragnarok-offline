//
//  CharacterSimulatorView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/25.
//

import RealityKit
import ROCore
import ROGame
import RORendering
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

struct CharacterSimulatorView2: View {
    @State private var configuration = CharacterSimulator.Configuration()

    var body: some View {
        RealityView { content in
            let entity = SpriteEntity()
            entity.name = "character"
            entity.position = [0, 0, 0]
            content.add(entity)
        } update: { content in
            if let entity = content.entities.first as? SpriteEntity {
                Task {
                    let configuration = ComposedSprite.Configuration(configuration: configuration)
                    let composedSprite = await ComposedSprite(
                        configuration: configuration,
                        resourceManager: .shared,
                        scriptManager: .shared
                    )

                    let animations = try await SpriteAnimation.animations(for: composedSprite)

                    let spriteComponent = SpriteComponent(animations: animations)
                    entity.components.set(spriteComponent)

                    entity.playSpriteAnimation(.walk, direction: .south, repeats: true)
                }
            }
        } placeholder: {
            ProgressView()
        }
    }
}

#Preview {
    NavigationStack {
        CharacterSimulatorView()
            .environment(AppModel())
    }
}
