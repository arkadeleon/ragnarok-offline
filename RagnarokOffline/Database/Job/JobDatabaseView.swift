//
//  JobDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//

import RagnarokResources
import SwiftUI

struct JobDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @State private var searchText = ""
    @State private var filteredJobs: [JobModel] = []

    var body: some View {
        ImageGrid(filteredJobs) { job in
            NavigationLink(value: job) {
                JobGridCell(job: job)
            }
        }
        .background(.background)
        .navigationTitle(Text("Job Database", tableName: "Database"))
        .adaptiveSearch(text: $searchText)
        .overlay {
            if database.jobs.isEmpty {
                ProgressView()
            } else if !searchText.isEmpty && filteredJobs.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text("No Results", tableName: "Database")
                    } icon: {
                        Image(systemName: "person.fill")
                    }
                }
            }
        }
        .task(id: "\(searchText)") {
            await database.fetchJobs()
            filteredJobs = await jobs(matching: searchText, in: database.jobs)
        }
    }

    private func jobs(matching searchText: String, in jobs: [JobModel]) async -> [JobModel] {
        if searchText.isEmpty {
            return jobs
        }

        let filteredJobs = jobs.filter { job in
            job.displayName.localizedStandardContains(searchText)
        }
        return filteredJobs
    }
}

#Preview("Pre-Renewal Job Database") {
    NavigationStack {
        JobDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .prerenewal, resourceManager: .previewing))
}

#Preview("Renewal Job Database") {
    NavigationStack {
        JobDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .renewal, resourceManager: .previewing))
}
