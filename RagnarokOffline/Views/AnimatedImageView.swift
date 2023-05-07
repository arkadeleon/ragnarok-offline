//
//  AnimatedImageView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/26.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct AnimatedImageView: UIViewRepresentable {

    let animatedImage: UIImage

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {
        imageView.image = animatedImage
    }
}
