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
        TimelineView(.periodic(from: startDate, by: animatedImage.frameInterval)) { context in
            if let frame = frame(at: context.date) {
                Image(frame, scale: animatedImage.scale, label: Text(verbatim: ""))
            }
        }
    }

    private func frame(at date: Date) -> CGImage? {
        if animatedImage.frames.isEmpty {
            return nil
        }

        let frameIndex = Int(round(date.timeIntervalSince(startDate) / animatedImage.frameInterval))
        let frameCount = animatedImage.frames.count
        let frame = animatedImage.frames[frameIndex % frameCount]
        return frame
    }
}

//#Preview {
//    AnimatedImageView()
//}
