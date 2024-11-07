//
//  JobProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import RODatabase

struct JobProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async throws -> [ObservableJob] {
        let database = JobDatabase.database(for: mode)
        let jobs = try await database.jobs().map { job in
            ObservableJob(mode: mode, job: job)
        }
        return jobs
    }

    func records(matching searchText: String, in jobs: [ObservableJob]) async -> [ObservableJob] {
        jobs.filter { job in
            job.displayName.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == JobProvider {
    static var job: JobProvider {
        JobProvider()
    }
}
