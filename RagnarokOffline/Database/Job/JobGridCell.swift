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
        VStack {
            ZStack {
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
                        .foregroundStyle(.tertiary)
                        .font(.system(size: 35))
                }
            }
            .frame(width: 80, height: 80)

            Text(jobStats.job.stringValue)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.primary)
                .font(.subheadline)
                .lineLimit(2, reservesSpace: true)
        }
        .task {
            jobImage = await ClientResourceManager.shared.jobImage(gender: .male, job: jobStats.job)
        }
    }
}
