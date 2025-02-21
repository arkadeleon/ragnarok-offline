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
            VStack {
                ZStack {
                    if let animatedImage {
                        AnimatedImageView(animatedImage: animatedImage)
                    }
                }
                .frame(minHeight: 0, maxHeight: .infinity)

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
            }
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
        .onChange(of: configuration.weaponID) {
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
        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let resourceManager = ResourceManager(url: url)
        let spriteResolver = SpriteResolver(resourceManager: resourceManager)

        let jobID = UniformJobID(rawValue: configuration.jobID.rawValue)

        var spriteConfiguration = SpriteConfiguration()
        spriteConfiguration.gender = configuration.gender
        spriteConfiguration.clothesColorID = configuration.clothesColorID
        spriteConfiguration.hairStyleID = configuration.hairStyleID
        spriteConfiguration.hairColorID = configuration.hairColorID
        spriteConfiguration.weaponID = configuration.weaponID
        spriteConfiguration.shieldID = configuration.shieldID

        sprites = await spriteResolver.resolvePlayerSprites(jobID: jobID, configuration: spriteConfiguration)
    }

    private func reloadAnimatedImage() async {
        let spriteRenderer = SpriteRenderer()
        let images = spriteRenderer.drawPlayerSprites(sprites: sprites, actionType: configuration.actionType, direction: configuration.direction, headDirection: configuration.headDirection)

        animatedImage = AnimatedImage(images: images, delay: 1 / 12)
    }
}

struct CharacterSimulatorView2: View {
    @State private var action = 0

    var body: some View {
        RealityView { content in
            if let entity = try? await Entity.loadJob(jobID: .novice) {
                entity.name = "character"
                entity.position = [0, 0, 0]
                content.add(entity)
            }
        } update: { content in
            if let entity = content.entities.first {
                entity.runAction(action)
                entity.findEntity(named: "head")?.runAction(action)

                let transform = Transform(translation: [0, -1, 0])
                entity.move(to: transform, relativeTo: nil, duration: 30, timingFunction: .linear)
            }
        } placeholder: {
            ProgressView()
        }
        .toolbar {
            Picker(selection: $action) {
                ForEach(0..<24) { i in
                    Text(verbatim: "\(i)")
                        .tag(i)
                }
            } label: {
                Image(systemName: "figure.run.circle")
            }
        }
    }
}
