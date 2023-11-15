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
        case loaded([AnimatedImage], CGSize)
        case failed
    }

    let document: DocumentWrapper

    @State private var status: Status = .notYetLoaded

    var body: some View {
        ScrollView {
            if case .loaded(let animatedImages, let imageSize) = status {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: imageSize.width), spacing: 16)], spacing: 32) {
                    ForEach(0..<animatedImages.count, id: \.self) { index in
                        AnimatedImageView(animatedImage: animatedImages[index])
                            .frame(width: imageSize.width, height: imageSize.height)
                            .contextMenu {
                                ShareLink(item: animatedImages[index].named(String(format: "%@.%03d.png", document.name, index)), preview: SharePreview(document.name, image: Image(uiImage: UIImage(cgImage: animatedImages[index].images[0]))))
                            }
                    }
                }
                .padding(32)
            }
        }
        .overlay {
            if case .loading = status {
                ProgressView()
            }
        }
        .navigationTitle(document.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Menu {
                if case .loaded(let animatedImages, _) = status {
                    ShareLink(items: animatedImages) { animatedImage in
                        SharePreview(document.name, image: Image(uiImage: UIImage(cgImage: animatedImage.images[0])))
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
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
        case .grfEntry(let grf, let entry):
            let sprPath = entry.path.replacingExtension("spr")
            guard let data = try? grf.contentsOfEntry(at: sprPath) else {
                status = .failed
                return
            }
            sprData = data
        default:
            status = .failed
            return
        }

        guard let act = try? ACT(data: actData),
              let spr = try? SPR(data: sprData)
        else {
            status = .failed
            return
        }

        let sprites = spr.sprites.enumerated()
        let spritesByType = Dictionary(grouping: sprites, by: { $0.element.type })
        let imagesForSpritesByType = spritesByType.mapValues { sprites in
            sprites.map { sprite in
                spr.image(forSpriteAt: sprite.offset)?.image
            }
        }

        var animatedImages: [AnimatedImage] = []
        for index in 0..<act.actions.count {
            if let animatedImage = act.animatedImage(forActionAt: index, imagesForSpritesByType: imagesForSpritesByType) {
                animatedImages.append(animatedImage)
            }
        }

        let imageSize = animatedImages.reduce(CGSize(width: 80, height: 80)) { imageSize, image in
            CGSize(
                width: max(imageSize.width, CGFloat(image.size.width)),
                height: max(imageSize.height, CGFloat(image.size.height))
            )
        }

        status = .loaded(animatedImages, imageSize)
    }
}
