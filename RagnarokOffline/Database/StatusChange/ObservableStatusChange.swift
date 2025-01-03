//
//  ObservableStatusChange.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import Observation
import RODatabase
import ROGenerated

@Observable
@dynamicMemberLookup
class ObservableStatusChange {
    private let mode: DatabaseMode
    private let statusChange: StatusChange

    var fail: [ObservableStatusChange] = []
    var endOnStart: [ObservableStatusChange] = []
    var endReturn: [ObservableStatusChange] = []
    var endOnEnd: [ObservableStatusChange] = []

    var displayName: String {
        statusChange.status.stringValue
    }

    var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: "Status", value: statusChange.status.stringValue))
        attributes.append(.init(name: "Icon", value: statusChange.icon.stringValue))

        return attributes
    }

    init(mode: DatabaseMode, statusChange: StatusChange) {
        self.mode = mode
        self.statusChange = statusChange
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<StatusChange, Value>) -> Value {
        statusChange[keyPath: keyPath]
    }

    func fetchDetail() async {
        let database = StatusChangeDatabase.database(for: mode)

        if let fail = try? await database.statusChanges(forIDs: Array(statusChange.fail ?? [])) {
            self.fail = fail.map { statusChange in
                ObservableStatusChange(mode: mode, statusChange: statusChange)
            }
        }

        if let endOnStart = try? await database.statusChanges(forIDs: Array(statusChange.endOnStart ?? [])) {
            self.endOnStart = endOnStart.map { statusChange in
                ObservableStatusChange(mode: mode, statusChange: statusChange)
            }
        }

        if let endReturn = try? await database.statusChanges(forIDs: Array(statusChange.endReturn ?? [])) {
            self.endReturn = endReturn.map { statusChange in
                ObservableStatusChange(mode: mode, statusChange: statusChange)
            }
        }

        if let endOnEnd = try? await database.statusChanges(forIDs: Array(statusChange.endOnEnd ?? [])) {
            self.endOnEnd = endOnEnd.map { statusChange in
                ObservableStatusChange(mode: mode, statusChange: statusChange)
            }
        }
    }
}

extension ObservableStatusChange: Hashable {
    static func == (lhs: ObservableStatusChange, rhs: ObservableStatusChange) -> Bool {
        lhs.statusChange.status == rhs.statusChange.status
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(statusChange.status)
    }
}

extension ObservableStatusChange: Identifiable {
    var id: StatusChangeID {
        statusChange.status
    }
}
