//
//  JobGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//

import SwiftUI
import RODatabase
import ROClient

struct JobGridCell: View {
    var jobStats: JobStats

    @State private var jobImage: CGImage?

    var body: some View {
        ImageGridCell(title: jobStats.job.stringValue) {
            if let jobImage {
                if jobImage.width > 80 || jobImage.height > 80 {
                    Image(jobImage, scale: 1, label: Text(jobStats.job.stringValue))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(jobImage, scale: 1, label: Text(jobStats.job.stringValue))
                }
            } else {
                Image(systemName: "person")
                    .font(.system(size: 50, weight: .thin))
                    .foregroundStyle(Color.secondary)
            }
        }
        .task {
            jobImage = await ClientResourceManager.shared.jobImage(gender: .male, job: jobStats.job)
        }
    }
}
