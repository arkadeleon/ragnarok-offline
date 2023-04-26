//
//  ActionDocumentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct ActionDocumentView: View {

    let document: DocumentWrapper

    @State private var isLoading = true
    @State private var images: [UIImage] = []
    @State private var animatingImage: UIImage?

    @State private var imageSize = CGSize(width: 80, height: 80)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: imageSize.width), spacing: 16)], spacing: 32) {
                ForEach(images, id: \.self) { image in
                    AnimatedImageView(animatedImage: image, isAnimating: animatingImage == image)
                        .frame(width: imageSize.width, height: imageSize.height)
                        .onTapGesture {
                            animatingImage = image
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

        guard case let .grfNode(grf, node) = document,
              let actData = document.contents()
        else {
            return
        }

        let sprPath = (node.path as NSString).deletingPathExtension.appending(".spr")
        guard let sprData = grf.node(atPath: sprPath)?.contents else {
            return
        }

        guard let actDocument = try? ACTDocument(data: actData),
              let sprDocument = try? SPRDocument(data: sprData)
        else {
            return
        }

        var frames: [UIImage?] = []
        for index in 0..<sprDocument.frames.count {
            let frame = sprDocument.imageForFrame(at: index)
            frames.append(frame)
        }

        var animations: [UIImage] = []
        for index in 0..<actDocument.actions.count {
            let animation = actDocument.animatedImageForAction(at: index, with: frames)
            animations.append(animation ?? UIImage())
        }
        images = animations

        imageSize = images.reduce(CGSize(width: 80, height: 80)) { imageSize, image in
            CGSize(
                width: max(imageSize.width, image.size.width),
                height: max(imageSize.height, image.size.height)
            )
        }
    }
}
