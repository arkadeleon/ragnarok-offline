//
//  JobDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//

import SwiftUI

struct JobDatabaseView: View {
    @Environment(DatabaseModel<JobProvider>.self) private var database

    var body: some View {
        ImageGrid(database.filteredRecords) { job in
            NavigationLink(value: job) {
                JobGridCell(job: job)
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Job Database")
        .databaseRoot(database) {
            ContentUnavailableView("No Results", systemImage: "person.fill")
        }
        .task {
            await database.fetchRecords()
            await database.recordProvider.prefetchRecords(database.records)
        }
    }
}

#Preview("Pre-Renewal Job Database") {
    NavigationStack {
        JobDatabaseView()
    }
    .environment(DatabaseModel(mode: .prerenewal, recordProvider: .job))
}

#Preview("Renewal Job Database") {
    NavigationStack {
        JobDatabaseView()
    }
    .environment(DatabaseModel(mode: .renewal, recordProvider: .job))
}
