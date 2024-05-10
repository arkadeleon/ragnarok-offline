//
//  ObservableJobDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import Combine
import rAthenaCommon
import RODatabase

@MainActor
class ObservableJobDatabase: ObservableObject {
    let mode: ServerMode

    @Published var loadStatus: LoadStatus = .notYetLoaded
    @Published var searchText = ""
    @Published var jobs: [JobStats] = []
    @Published var filteredJobs: [JobStats] = []

    init(mode: ServerMode) {
        self.mode = mode
    }

    func fetchJobs() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        let database = JobDatabase.database(for: mode)

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
