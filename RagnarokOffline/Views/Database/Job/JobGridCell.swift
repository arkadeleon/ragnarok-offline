//
//  JobGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaMap

struct JobGridCell: View {
    let job: RAJob

    var body: some View {
        VStack {
            DatabaseRecordImage {
                await ClientResourceManager.shared.jobImage(sexID: RA_SEX_MALE, jobID: job.jobID)
            }
            .frame(width: 64, height: 64)

            Text(job.jobName)
                .lineLimit(2, reservesSpace: true)
                .font(.subheadline)
                .foregroundColor(.init(uiColor: .label))
        }
    }
}

#Preview {
    JobGridCell(job: RAJob())
}
