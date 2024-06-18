//
//  JobProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import rAthenaCommon
import RODatabase

struct JobProvider: DatabaseRecordProvider {
    func records(for mode: ServerMode) async throws -> [JobStats] {
        let database = JobDatabase.database(for: mode)
        let jobs = try await database.jobs()
        return jobs
    }

    func records(matching searchText: String, in jobs: [JobStats]) async -> [JobStats] {
        jobs.filter { jobStats in
            jobStats.job.description.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == JobProvider {
    static var job: JobProvider {
        JobProvider()
    }
}
