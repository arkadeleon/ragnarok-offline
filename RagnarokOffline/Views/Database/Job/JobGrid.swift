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
        DatabaseRecordGrid(
            columns: [GridItem(.adaptive(minimum: 80), spacing: 20)],
            alignment: .center,
            spacing: 30,
            insets: EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20),
            partitions: partitions,
            filter: filter) { jobStats in
                JobGridCell(database: database, jobStats: jobStats)
            }
            .navigationTitle("Jobs")
            .navigationBarTitleDisplayMode(.inline)
    }

    private func partitions() async -> AsyncDatabaseRecordPartitions<JobStats> {
        await database.jobs()
    }

    private func filter(jobs: [JobStats], searchText: String) -> [JobStats] {
        jobs.filter { jobStats in
            jobStats.job.description.localizedCaseInsensitiveContains(searchText)
        }
    }
}

#Preview {
    JobGrid(database: .renewal)
}
