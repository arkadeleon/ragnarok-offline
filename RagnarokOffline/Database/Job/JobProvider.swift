//
//  JobProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import RODatabase

struct JobProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async throws -> [Job] {
        let database = JobDatabase.database(for: mode)
        let jobs = try await database.jobs()
        return jobs
    }

    func records(matching searchText: String, in jobs: [Job]) async -> [Job] {
        jobs.filter { job in
            job.id.stringValue.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == JobProvider {
    static var job: JobProvider {
        JobProvider()
    }
}
