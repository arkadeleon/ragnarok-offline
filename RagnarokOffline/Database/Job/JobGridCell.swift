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
            ZStack {
                if let animatedImage = job.animatedImage, let firstFrame = animatedImage.firstFrame {
                    Image(firstFrame, scale: animatedImage.scale, label: Text(job.displayName))
                        .frame(maxHeight: .infinity, alignment: .bottom)
                } else {
                    Image(systemName: "person")
                        .font(.system(size: 50, weight: .thin))
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(width: 80, height: 140)
        }
        .task {
            await job.fetchAnimatedImage()
        }
    }
}
