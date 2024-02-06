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
    let database: Database

    var body: some View {
        DatabaseRecordGrid(itemSize: 80, horizontalSpacing: 16, verticalSpacing: 16) {
            try await database.fetchJobs()
        } filter: { records, searchText in
            records.filter { record in
                record.job.description.localizedCaseInsensitiveContains(searchText)
            }
        } content: { record in
            NavigationLink {
                JobDetailView(database: database, jobStats: record)
            } label: {
                JobGridCell(database: database, job: record.job)
            }
        }
        .navigationTitle("Jobs")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    JobGrid(database: .renewal)
}
