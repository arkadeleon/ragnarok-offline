//
//  CharacterView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/25.
//

import RealityKit
import ROCore
import RORendering
import SwiftUI

struct CharacterView: View {
    @State private var action = 0
    @State private var animatedImage: AnimatedImage?

    var body: some View {
        ZStack {
            if let animatedImage {
                AnimatedImageView(animatedImage: animatedImage)
                    .scaleEffect(CGSize(width: 2, height: 2))
            }
        }
        .task {
            let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let resourceManager = ResourceManager(url: url)
            let spriteResolver = SpriteResolver(resourceManager: resourceManager)

            var configuration = SpriteConfiguration()
            configuration.headID = 2
            let sprites = await spriteResolver.resolvePlayerSprites(jobID: 0, configuration: configuration)

            let spriteRenderer = SpriteRenderer()
            let images = spriteRenderer.drawPlayerSprites(sprites: sprites, actionIndex: 8)

            animatedImage = AnimatedImage(images: images, delay: 1 / 12)
        }
//        RealityView { content in
//            if let entity = try? await Entity.loadJob(jobID: .novice) {
//                entity.name = "character"
//                entity.position = [0, 0, 0]
//                content.add(entity)
//            }
//        } update: { content in
//            if let entity = content.entities.first {
//                entity.runAction(action)
//                entity.findEntity(named: "head")?.runAction(action)
//
//                let transform = Transform(translation: [0, -1, 0])
//                entity.move(to: transform, relativeTo: nil, duration: 30, timingFunction: .linear)
//            }
//        } placeholder: {
//            ProgressView()
//        }
//        .toolbar {
//            Picker(selection: $action) {
//                ForEach(0..<24) { i in
//                    Text(verbatim: "\(i)")
//                        .tag(i)
//                }
//            } label: {
//                Image(systemName: "figure.run.circle")
//            }
//        }
    }
}
