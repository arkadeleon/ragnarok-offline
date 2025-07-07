//
//  StatusChangeProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import RODatabase

struct StatusChangeProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async -> [StatusChangeModel] {
        let database = StatusChangeDatabase.shared
        let statusChanges = await database.statusChanges().map { statusChange in
            StatusChangeModel(mode: mode, statusChange: statusChange)
        }
        return statusChanges
    }

    func records(matching searchText: String, in statusChanges: [StatusChangeModel]) async -> [StatusChangeModel] {
        statusChanges.filter { statusChange in
            statusChange.displayName.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == StatusChangeProvider {
    static var statusChange: StatusChangeProvider {
        StatusChangeProvider()
    }
}
