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

    @State private var resolvedSprite: ResolvedSprite?
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
            await resolveSprite()
            await renderSprite()
        }
        .onChange(of: configuration.jobID) {
            Task {
                await resolveSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.gender) {
            Task {
                await resolveSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.clothesColorID) {
            Task {
                await resolveSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.hairStyleID) {
            Task {
                await resolveSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.hairColorID) {
            Task {
                await resolveSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.upperHeadgear) {
            Task {
                await resolveSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.middleHeadgear) {
            Task {
                await resolveSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.lowerHeadgear) {
            Task {
                await resolveSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.weaponType) {
            Task {
                await resolveSprite()
                await renderSprite()
            }
        }
        .onChange(of: configuration.shieldID) {
            Task {
                await resolveSprite()
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

    private func resolveSprite() async {
        let jobID = UniformJobID(rawValue: configuration.jobID.rawValue)

        var spriteConfiguration = SpriteConfiguration()
        spriteConfiguration.gender = configuration.gender
        spriteConfiguration.clothesColorID = configuration.clothesColorID
        spriteConfiguration.hairStyleID = configuration.hairStyleID
        spriteConfiguration.hairColorID = configuration.hairColorID
        spriteConfiguration.headgearIDs = configuration.headgearIDs
        spriteConfiguration.weaponID = configuration.weaponType.rawValue
        spriteConfiguration.shieldID = configuration.shieldID

        let spriteResolver = SpriteResolver(resourceManager: .default)
        resolvedSprite = await spriteResolver.resolve(jobID: jobID, configuration: spriteConfiguration)
    }

    private func renderSprite() async {
        guard let resolvedSprite else {
            return
        }

        let spriteRenderer = SpriteRenderer(resolvedSprite: resolvedSprite)
        let actionIndex = configuration.actionType.rawValue * 8 + configuration.direction.rawValue
        animatedImage = await spriteRenderer.renderAction(at: actionIndex, headDirection: configuration.headDirection)
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
                    let jobID = UniformJobID(rawValue: configuration.jobID.rawValue)

                    var spriteConfiguration = SpriteConfiguration()
                    spriteConfiguration.gender = configuration.gender
                    spriteConfiguration.clothesColorID = configuration.clothesColorID
                    spriteConfiguration.hairStyleID = configuration.hairStyleID
                    spriteConfiguration.hairColorID = configuration.hairColorID
                    spriteConfiguration.headgearIDs = configuration.headgearIDs
                    spriteConfiguration.weaponID = configuration.weaponType.rawValue
                    spriteConfiguration.shieldID = configuration.shieldID

                    let actions = try await SpriteAction.actions(forJobID: jobID, configuration: spriteConfiguration)

                    let spriteComponent = SpriteComponent(actions: actions)
                    entity.components.set(spriteComponent)

                    entity.runPlayerAction(.walk, direction: .south, repeats: true)
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
