//
//  JobDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//

import SwiftUI

struct JobDatabaseView: View {
    @ObservedObject var jobDatabase: ObservableJobDatabase

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .center, spacing: 30) {
                ForEach(jobDatabase.filteredJobs) { jobStats in
                    JobGridCell(database: jobDatabase.database, jobStats: jobStats)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
        }
        .overlay {
            if jobDatabase.loadStatus == .loading {
                ProgressView()
            }
        }
        .overlay {
            if jobDatabase.loadStatus == .loaded && jobDatabase.filteredJobs.isEmpty {
                EmptyContentView("No Jobs")
            }
        }
        .navigationTitle("Job Database")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $jobDatabase.searchText)
        .onSubmit(of: .search) {
            jobDatabase.filterJobs()
        }
        .onChange(of: jobDatabase.searchText) { _ in
            jobDatabase.filterJobs()
        }
        .task {
            await jobDatabase.fetchJobs()
        }
    }
}
