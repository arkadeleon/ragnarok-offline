//
//  ObservableJobDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Combine
import rAthenaDatabase

@MainActor
class ObservableJobDatabase: ObservableObject {
    let database: Database

    @Published var loadStatus: LoadStatus = .notYetLoaded
    @Published var searchText = ""
    @Published var jobs: [JobStats] = []
    @Published var filteredJobs: [JobStats] = []

    init(database: Database) {
        self.database = database
    }

    func fetchJobs() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        do {
            jobs = try await database.jobs()
            filterJobs()

            loadStatus = .loaded
        } catch {
            loadStatus = .failed
        }
    }

    func filterJobs() {
        if searchText.isEmpty {
            filteredJobs = jobs
        } else {
            filteredJobs = jobs.filter { jobStats in
                jobStats.job.description.localizedStandardContains(searchText)
            }
        }
    }
}
