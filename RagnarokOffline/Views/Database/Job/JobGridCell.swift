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
    let job: Job

    var body: some View {
        VStack {
            DatabaseRecordImage {
                await ClientResourceManager.shared.jobImage(gender: .male, job: job)
            }
            .frame(width: 64, height: 64)

            Text(job.description)
                .lineLimit(2, reservesSpace: true)
                .font(.subheadline)
                .foregroundColor(.init(uiColor: .label))
        }
    }
}
