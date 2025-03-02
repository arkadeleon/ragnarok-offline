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

    private let startDate = Date()

    var body: some View {
        TimelineView(.periodic(from: startDate, by: animatedImage.delay)) { context in
            if let image = image(at: context.date) {
                Image(image, scale: 1, label: Text(verbatim: ""))
            }
        }
    }

    private func image(at date: Date) -> CGImage? {
        if animatedImage.images.isEmpty {
            return nil
        }

        let index = Int(round(date.timeIntervalSince(startDate) / animatedImage.delay))
        let count = animatedImage.images.count
        let image = animatedImage.images[index % count]
        return image
    }
}

//#Preview {
//    AnimatedImageView()
//}
