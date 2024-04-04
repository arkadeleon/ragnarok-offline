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

    @Published var status: AsyncContentStatus<[JobStats]> = .notYetLoaded
    @Published var searchText = ""
    @Published var filteredJobs: [JobStats] = []

    init(database: Database) {
        self.database = database
    }

    func fetchJobs() {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        Task {
            do {
                let jobs = try await database.jobs().joined()
                status = .loaded(jobs)
                filterJobs()
            } catch {
                status = .failed(error)
            }
        }
    }

    func filterJobs() {
        guard case .loaded(let jobs) = status else {
            return
        }

        if searchText.isEmpty {
            filteredJobs = jobs
        } else {
            Task {
                filteredJobs = jobs.filter { jobStats in
                    jobStats.job.description.localizedStandardContains(searchText)
                }
            }
        }
    }
}
