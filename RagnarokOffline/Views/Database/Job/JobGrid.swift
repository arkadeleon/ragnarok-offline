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
        DatabaseRecordGrid(partitions: database.jobs()) { jobs, searchText in
            jobs.filter { jobStats in
                jobStats.job.description.localizedCaseInsensitiveContains(searchText)
            }
        } content: { record in
            NavigationLink {
                JobInfoView(database: database, jobStats: record)
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
