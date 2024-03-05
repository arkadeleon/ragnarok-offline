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
    let job: Job

    var body: some View {
        VStack {
            DatabaseRecordImage {
                await ClientResourceManager.shared.jobImage(gender: .male, job: job, size: CGSize(width: 80, height: 80))
            }
            .frame(width: 80, height: 80)

            Text(job.description)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.primary)
                .font(.subheadline)
                .lineLimit(2, reservesSpace: true)
        }
    }
}
