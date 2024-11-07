//
//  JobGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//

import SwiftUI

struct JobGridCell: View {
    var job: ObservableJob

    var body: some View {
        ImageGridCell(title: job.displayName) {
            if let jobImage = job.image {
                if jobImage.width > 80 || jobImage.height > 80 {
                    Image(jobImage, scale: 1, label: Text(job.displayName))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(jobImage, scale: 1, label: Text(job.displayName))
                }
            } else {
                Image(systemName: "person")
                    .font(.system(size: 50, weight: .thin))
                    .foregroundStyle(Color.secondary)
            }
        }
        .task {
            await job.fetchImage()
        }
    }
}
