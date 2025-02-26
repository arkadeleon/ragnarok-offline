//
//  CharacterSimulatorView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/25.
//

import RealityKit
import ROCore
import RORendering
import SwiftUI

struct CharacterSimulatorView: View {
    @State private var configuration = CharacterConfiguration()

    @State private var sprites: [SpriteResource] = []
    @State private var animatedImage: AnimatedImage?

    var body: some View {
        ResponsiveView {
            VStack(spacing: 0) {
                ZStack {
                    if let animatedImage {
                        AnimatedImageView(animatedImage: animatedImage)
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
            await reloadSprites()
            await reloadAnimatedImage()
        }
        .onChange(of: configuration.jobID) {
            Task {
                await reloadSprites()
                await reloadAnimatedImage()
            }
        }
        .onChange(of: configuration.gender) {
            Task {
                await reloadSprites()
                await reloadAnimatedImage()
            }
        }
        .onChange(of: configuration.clothesColorID) {
            Task {
                await reloadSprites()
                await reloadAnimatedImage()
            }
        }
        .onChange(of: configuration.hairStyleID) {
            Task {
                await reloadSprites()
                await reloadAnimatedImage()
            }
        }
        .onChange(of: configuration.hairColorID) {
            Task {
                await reloadSprites()
                await reloadAnimatedImage()
            }
        }
        .onChange(of: configuration.upperHeadgear) {
            Task {
                await reloadSprites()
                await reloadAnimatedImage()
            }
        }
        .onChange(of: configuration.middleHeadgear) {
            Task {
                await reloadSprites()
                await reloadAnimatedImage()
            }
        }
        .onChange(of: configuration.lowerHeadgear) {
            Task {
                await reloadSprites()
                await reloadAnimatedImage()
            }
        }
        .onChange(of: configuration.weaponType) {
            Task {
                await reloadSprites()
                await reloadAnimatedImage()
            }
        }
        .onChange(of: configuration.shieldID) {
            Task {
                await reloadSprites()
                await reloadAnimatedImage()
            }
        }
        .onChange(of: configuration.actionType) {
            Task {
                await reloadAnimatedImage()
            }
        }
        .onChange(of: configuration.direction) {
            Task {
                await reloadAnimatedImage()
            }
        }
        .onChange(of: configuration.headDirection) {
            Task {
                await reloadAnimatedImage()
            }
        }
    }

    private func reloadSprites() async {
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
        sprites = await spriteResolver.resolve(jobID: jobID, configuration: spriteConfiguration)
    }

    private func reloadAnimatedImage() async {
        let spriteRenderer = SpriteRenderer()
        let actionIndex = configuration.actionType.rawValue * 8 + configuration.direction.rawValue
        let images = spriteRenderer.render(sprites: sprites, actionIndex: actionIndex, headDirection: configuration.headDirection)

        animatedImage = AnimatedImage(images: images, delay: 1 / 12)
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

                    let actions = try await SpriteAction.actions(for: jobID, configuration: spriteConfiguration)

                    let spriteComponent = SpriteComponent(actions: actions)
                    entity.components.set(spriteComponent)

                    entity.runPlayerAction(.walk, direction: .south)
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
