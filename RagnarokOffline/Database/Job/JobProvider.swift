//
//  JobProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import RODatabase

struct JobProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async -> [JobModel] {
        let database = JobDatabase.shared
        let jobs = await database.jobs().map { job in
            JobModel(mode: mode, job: job)
        }
        return jobs
    }

    func records(matching searchText: String, in jobs: [JobModel]) async -> [JobModel] {
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
