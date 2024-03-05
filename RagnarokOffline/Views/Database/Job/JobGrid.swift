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
            columns: [GridItem(.adaptive(minimum: 80), spacing: 16)],
            alignment: .center,
            spacing: 32,
            insets: EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16),
            partitions: database.jobs(),
            filter: filter) { jobStats in
                NavigationLink {
                    JobInfoView(database: database, jobStats: jobStats)
                } label: {
                    JobGridCell(database: database, job: jobStats.job)
                }
            }
            .navigationTitle("Jobs")
            .navigationBarTitleDisplayMode(.inline)
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
