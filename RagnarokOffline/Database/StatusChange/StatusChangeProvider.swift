//
//  StatusChangeProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import RODatabase

struct StatusChangeProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async -> [ObservableStatusChange] {
        let database = StatusChangeDatabase.shared
        let statusChanges = await database.statusChanges().map { statusChange in
            ObservableStatusChange(mode: mode, statusChange: statusChange)
        }
        return statusChanges
    }

    func records(matching searchText: String, in statusChanges: [ObservableStatusChange]) async -> [ObservableStatusChange] {
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
