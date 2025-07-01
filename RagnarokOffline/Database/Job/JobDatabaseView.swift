//
//  JobDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//

import SwiftUI

struct JobDatabaseView: View {
    @Environment(ObservableDatabase<JobProvider>.self) private var database

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
    }
}

#Preview("Pre-Renewal Job Database") {
    JobDatabaseView()
        .environment(ObservableDatabase(mode: .prerenewal, recordProvider: .job))
}

#Preview("Renewal Job Database") {
    JobDatabaseView()
        .environment(ObservableDatabase(mode: .renewal, recordProvider: .job))
}
