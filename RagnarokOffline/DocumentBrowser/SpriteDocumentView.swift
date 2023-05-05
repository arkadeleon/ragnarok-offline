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
    @State private var images: [UIImage] = []

    @State private var imageSize = CGSize(width: 80, height: 80)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: imageSize.width), spacing: 16)], spacing: 32) {
                ForEach(images, id: \.self) { image in
                    Image(uiImage: image)
                        .frame(width: imageSize.width, height: imageSize.height)
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
        .task {
            load()
        }
    }

    func load() {
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

        guard let sprDocument = try? SPRDocument(data: data) else {
            return
        }

        images = (0..<sprDocument.sprites.count).map { index in
            sprDocument.imageForSprite(at: index) ?? UIImage()
        }

        imageSize = images.reduce(CGSize(width: 80, height: 80)) { imageSize, image in
            CGSize(
                width: max(imageSize.width, image.size.width),
                height: max(imageSize.height, image.size.height)
            )
        }
    }
}
