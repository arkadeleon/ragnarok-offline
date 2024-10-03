//
//  JobGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//

import SwiftUI
import RODatabase
import ROClientResources

struct JobGridCell: View {
    var job: Job

    @State private var jobImage: CGImage?

    var body: some View {
        ImageGridCell(title: job.id.stringValue) {
            if let jobImage {
                if jobImage.width > 80 || jobImage.height > 80 {
                    Image(jobImage, scale: 1, label: Text(job.id.stringValue))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(jobImage, scale: 1, label: Text(job.id.stringValue))
                }
            } else {
                Image(systemName: "person")
                    .font(.system(size: 50, weight: .thin))
                    .foregroundStyle(Color.secondary)
            }
        }
        .task {
            jobImage = await ClientResourceManager.default.jobImage(sex: .male, jobID: job.id)
        }
    }
}
