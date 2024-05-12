//
//  StatusChangeProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import rAthenaCommon
import RODatabase

struct StatusChangeProvider: DatabaseRecordProvider {
    func records(for mode: ServerMode) async throws -> [StatusChange] {
        let database = StatusChangeDatabase.database(for: mode)
        let statusChanges = try await database.statusChanges()
        return statusChanges
    }

    func records(matching searchText: String, in statusChanges: [StatusChange]) -> [StatusChange] {
        statusChanges.filter { statusChange in
            statusChange.status.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == StatusChangeProvider {
    static var statusChange: StatusChangeProvider {
        StatusChangeProvider()
    }
}
