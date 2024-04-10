//
//  JobGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct JobGridCell: View {
    let database: Database
    let jobStats: JobStats

    @State private var jobImage: CGImage?

    var body: some View {
        NavigationLink {
            JobInfoView(database: database, jobStats: jobStats)
        } label: {
            VStack {
                ZStack {
                    if let jobImage {
                        if jobImage.width > 80 || jobImage.height > 80 {
                            Image(jobImage, scale: 1, label: Text(jobStats.job.description))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Image(jobImage, scale: 1, label: Text(jobStats.job.description))
                        }
                    } else {
                        Image(systemName: "person")
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 35))
                    }
                }
                .frame(width: 80, height: 80)

                Text(jobStats.job.description)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.primary)
                    .font(.subheadline)
                    .lineLimit(2, reservesSpace: true)
            }
        }
        .task {
            jobImage = await ClientResourceManager.shared.jobImage(gender: .male, job: jobStats.job)
        }
    }
}
