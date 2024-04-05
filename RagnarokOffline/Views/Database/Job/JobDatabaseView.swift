//
//  JobDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct JobDatabaseView: View {
    @ObservedObject var jobDatabase: ObservableJobDatabase

    var body: some View {
        AsyncContentView(status: jobDatabase.status) { jobs in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .center, spacing: 30) {
                    ForEach(jobDatabase.filteredJobs) { jobStats in
                        JobGridCell(database: jobDatabase.database, jobStats: jobStats)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
            .searchable(text: $jobDatabase.searchText)
            .onSubmit(of: .search) {
                jobDatabase.filterJobs()
            }
            .onChange(of: jobDatabase.searchText) { _ in
                jobDatabase.filterJobs()
            }
        }
        .navigationTitle("Job Database")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await jobDatabase.fetchJobs()
        }
    }
}
