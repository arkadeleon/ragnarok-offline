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
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(uiColor: .secondarySystemBackground))

            VStack(spacing: 0) {
                DatabaseRecordImage {
                    await ClientResourceManager.shared.jobImage(gender: .male, job: job, size: CGSize(width: 80, height: 80))
                }
                .frame(width: 80, height: 80)
                .padding(4)

                ZStack {
                    Color(uiColor: .secondarySystemBackground)
                        .clipShape(.rect(bottomLeadingRadius: 4, bottomTrailingRadius: 4))

                    Text(job.description)
                        .lineLimit(2, reservesSpace: true)
                        .font(.subheadline)
                        .foregroundColor(.init(uiColor: .label))
                        .padding(4)
                }
            }
        }
    }
}
