//
//  AnimatedImageView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import SwiftUI
import ROGraphics

struct AnimatedImageView: UIViewRepresentable {
    let animatedImage: AnimatedImage

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {
        imageView.animationImages = animatedImage.images.map(UIImage.init)
        imageView.animationDuration = animatedImage.delay * CGFloat(animatedImage.images.count)
        imageView.startAnimating()
    }
}

//#Preview {
//    AnimatedImageView()
//}
