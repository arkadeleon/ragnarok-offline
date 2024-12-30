//
//  AnimatedImageView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import ROCore
import SwiftUI

struct AnimatedImageView: View {
    var animatedImage: AnimatedImage

    private var timer: Timer.TimerPublisher

    @State private var index = 0

    private var image: CGImage? {
        guard !animatedImage.images.isEmpty else {
            return nil
        }

        let imageCount = animatedImage.images.count
        let image = animatedImage.images[index % imageCount]
        return image
    }

    var body: some View {
        ZStack {
            if let image {
                Image(image, scale: 1, label: Text(index.formatted()))
            }
        }
        .onReceive(timer.autoconnect()) { _ in
            index += 1
        }
    }

    init(animatedImage: AnimatedImage) {
        self.animatedImage = animatedImage
        self.timer = Timer.publish(every: animatedImage.delay, on: .main, in: .common)
    }
}

//#Preview {
//    AnimatedImageView()
//}
