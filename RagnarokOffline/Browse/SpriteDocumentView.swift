//
//  SpriteDocumentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct SpriteDocumentView: View {

    let document: DocumentWrapper

    @State private var isLoading = true
    @State private var images: [StillImage] = []

    @State private var imageSize = CGSize(width: 80, height: 80)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: imageSize.width), spacing: 16)], spacing: 32) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(uiImage: UIImage(cgImage: images[index].image))
                        .frame(width: imageSize.width, height: imageSize.height)
                        .contextMenu {
                            ShareLink(item: images[index].named(String(format: "%@.%03d.png", document.name, index)), preview: SharePreview(document.name, image: Image(uiImage: UIImage(cgImage: images[index].image))))
                        }
                }
            }
            .padding(32)
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .navigationTitle(document.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Menu {
                ShareLink(items: images) { image in
                    SharePreview(document.name, image: Image(uiImage: UIImage(cgImage: image.image)))
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
        guard images.isEmpty else {
            return
        }

        isLoading = true
        defer {
            isLoading = false
        }

        guard let data = document.contents() else {
            return
        }

        guard let spr = try? SPR(data: data) else {
            return
        }

        images = (0..<spr.sprites.count).compactMap { index in
            spr.image(forSpriteAt: index)
        }

        imageSize = images.reduce(CGSize(width: 80, height: 80)) { imageSize, image in
            CGSize(
                width: max(imageSize.width, CGFloat(image.image.width)),
                height: max(imageSize.height, CGFloat(image.image.height))
            )
        }
    }
}
