//
//  AnimatedImageShareLink.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/10.
//

import ROCore
import SwiftUI

struct AnimatedImageShareLink: View {
    var animatedImage: AnimatedImage
    var filename: String

    private var previewImage: Image {
        if let firstFrame = animatedImage.frames.first, let firstFrame {
            Image(firstFrame, scale: animatedImage.frameScale, label: Text(filename))
        } else {
            Image(systemName: "livephoto")
        }
    }

    var body: some View {
        ShareLink(
            item: TransferableAnimatedImage(animatedImage: animatedImage, filename: filename),
            preview: SharePreview(filename, image: previewImage)
        )
    }
}
