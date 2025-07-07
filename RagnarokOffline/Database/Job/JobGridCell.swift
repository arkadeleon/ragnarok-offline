//
//  JobGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//

import SwiftUI

struct JobGridCell: View {
    var job: JobModel

    var body: some View {
        ImageGridCell(title: job.displayName) {
            if let animatedImage = job.animatedImage, let firstFrame = animatedImage.firstFrame {
                Image(firstFrame, scale: animatedImage.frameScale * 1.5, label: Text(job.displayName))
            } else {
                Image(systemName: "person")
                    .font(.system(size: 50, weight: .thin))
                    .foregroundStyle(Color.secondary)
            }
        }
        .task {
            await job.fetchAnimatedImage()
        }
    }
}
