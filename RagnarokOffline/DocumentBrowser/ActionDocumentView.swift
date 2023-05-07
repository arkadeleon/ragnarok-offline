//
//  ActionDocumentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct ActionDocumentView: View {

    enum Status {
        case notYetLoaded
        case loading
        case loaded(ACTDocument, [SPRSpriteType : [CGImage?]])
        case failed
    }

    let document: DocumentWrapper

    @State private var status: Status = .notYetLoaded
    @State private var selectedAction = 0

    private var imageForSelectedAction: UIImage {
        guard case .loaded(let actDocument, let imagesForSpritesByType) = status else {
            return UIImage()
        }
        let animatedImage = actDocument.animatedImageForAction(at: selectedAction, imagesForSpritesByType: imagesForSpritesByType)
        return animatedImage ?? UIImage()
    }

    var body: some View {
        VStack {
            Spacer()

            AnimatedImageView(animatedImage: imageForSelectedAction)

            Spacer()

            if case .loaded(let actDocument, _) = status {
                HStack {
                    Button {
                        if selectedAction > 0 {
                            selectedAction -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                    }

                    Picker("", selection: $selectedAction) {
                        ForEach(0..<actDocument.actions.count) { index in
                            Text("Action \(index)")
                        }
                    }
                    .pickerStyle(.menu)

                    Button {
                        if selectedAction < actDocument.actions.count - 1 {
                            selectedAction += 1
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
            }
        }
        .overlay {
            if case .loading = status {
                ProgressView()
            }
        }
        .navigationTitle(document.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await load()
        }
    }

    func load() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        guard let actData = document.contents() else {
            status = .failed
            return
        }

        let sprData: Data
        switch document {
        case .url(let url):
            let sprPath = url.deletingPathExtension().path().appending(".spr")
            guard let data = try? Data(contentsOf: URL(filePath: sprPath)) else {
                status = .failed
                return
            }
            sprData = data
        case .grfNode(let grf, let node):
            let sprPath = (node.path as NSString).deletingPathExtension.appending(".spr")
            guard let data = grf.node(atPath: sprPath)?.contents else {
                status = .failed
                return
            }
            sprData = data
        default:
            status = .failed
            return
        }

        guard let actDocument = try? ACTDocument(data: actData),
              let sprDocument = try? SPRDocument(data: sprData)
        else {
            status = .failed
            return
        }

        let sprites = sprDocument.sprites.enumerated()
        let spritesByType = Dictionary(grouping: sprites, by: { $0.element.type })
        let imagesForSpritesByType = spritesByType.mapValues { sprites in
            sprites.map { sprite in
                sprDocument.imageForSprite(at: sprite.offset)
            }
        }

        status = .loaded(actDocument, imagesForSpritesByType)
    }
}
