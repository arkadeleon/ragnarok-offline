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
    @State private var configuration = CharacterConfiguration()

    @State private var composedSprite: ComposedSprite?
    @State private var animatedImage: AnimatedImage?

    var body: some View {
        ResponsiveView {
            VStack(spacing: 0) {
                ZStack {
                    if let animatedImage {
                        AnimatedImageView(animatedImage: animatedImage)
                            .scaleEffect(2)
                    }
                }
                .frame(minHeight: 0, maxHeight: 300)

                Divider()

                CharacterConfigurationView(configuration: $configuration)
                    .frame(minHeight: 0, maxHeight: .infinity)
            }
        } regular: {
            HStack {
                ZStack {
                    if let animatedImage {
                        AnimatedImageView(animatedImage: animatedImage)
                            .scaleEffect(2)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)

                CharacterConfigurationView(configuration: $configuration)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(.background.secondary)
                    .scrollContentBackground(.hidden)
            }
            .background(.background)
            .toolbarTitleDisplayMode(.automatic)
        }
        .navigationTitle("Character Simulator")
        .task {
            await composeSprite()
            await renderSprite()
        }
        .onChange(of: configuration.jobID) {
            Task {
                await composeSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.gender) {
            Task {
                await composeSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.hairStyle) {
            Task {
                await composeSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.hairColor) {
            Task {
                await composeSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.clothesColor) {
            Task {
                await composeSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.weaponType) {
            Task {
                await composeSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.shield) {
            Task {
                await composeSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.headTop) {
            Task {
                await composeSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.headMid) {
            Task {
                await composeSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.headBottom) {
            Task {
                await composeSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.garment) {
            Task {
                await composeSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.actionType) {
            Task {
                await renderSprite()
            }
        }
        .onChange(of: configuration.direction) {
            Task {
                await renderSprite()
            }
        }
        .onChange(of: configuration.headDirection) {
            Task {
                await renderSprite()
            }
        }
    }

    private func composeSprite() async {
        let configuration = ComposedSprite.Configuration(configuration: configuration)
        composedSprite = await ComposedSprite(
            configuration: configuration,
            resourceManager: .default,
            scriptManager: .default
        )
    }

    private func renderSprite() async {
        guard let composedSprite else {
            return
        }

        let spriteRenderer = SpriteRenderer()
        animatedImage = await spriteRenderer.render(
            composedSprite: composedSprite,
            actionType: configuration.actionType,
            direction: configuration.direction,
            headDirection: configuration.headDirection
        )
    }
}

struct CharacterSimulatorView2: View {
    @State private var configuration = CharacterConfiguration()

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
                        resourceManager: .default,
                        scriptManager: .default
                    )

                    let actions = try await SpriteAction.actions(for: composedSprite)

                    let spriteComponent = SpriteComponent(actions: actions)
                    entity.components.set(spriteComponent)

                    entity.runActionType(.walk, direction: .south, repeats: true)
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
    }
}
