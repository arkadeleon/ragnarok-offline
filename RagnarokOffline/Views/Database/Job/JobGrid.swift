//
//  JobGrid.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct JobGrid: View {
    public var body: some View {
        DatabaseRecordGrid(itemSize: 80, horizontalSpacing: 32, verticalSpacing: 16) {
            try await Database.renewal.fetchJobs()
        } filter: { records, searchText in
            records.filter { record in
                record.job.description.localizedCaseInsensitiveContains(searchText)
            }
        } content: { record in
            NavigationLink {
                JobDetailView(jobStats: record)
            } label: {
                JobGridCell(job: record.job)
            }
        }
        .navigationTitle("Jobs")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    JobGrid()
}
