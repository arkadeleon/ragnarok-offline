//
//  ObservableStatusChange.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import CoreGraphics
import Observation
import RODatabase
import ROGame
import ROGenerated
import ROResources

@Observable
@dynamicMemberLookup
class ObservableStatusChange {
    private let mode: DatabaseMode
    private let statusChange: StatusChange

    var iconImage: CGImage?
    var fail: [ObservableStatusChange] = []
    var endOnStart: [ObservableStatusChange] = []
    var endReturn: [ObservableStatusChange] = []
    var endOnEnd: [ObservableStatusChange] = []
    var localizedDescription: String?

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

    func fetchIconImage() async throws {
        if iconImage == nil {
            iconImage = try await GameResourceManager.default.statusIconImage(forStatusID: statusChange.icon.rawValue)
        }
    }

    func fetchDetail() async {
        let database = StatusChangeDatabase.database(for: mode)

        let fail = await database.statusChanges(forIDs: Array(statusChange.fail ?? []))
        self.fail = fail.map { statusChange in
            ObservableStatusChange(mode: mode, statusChange: statusChange)
        }

        let endOnStart = await database.statusChanges(forIDs: Array(statusChange.endOnStart ?? []))
        self.endOnStart = endOnStart.map { statusChange in
            ObservableStatusChange(mode: mode, statusChange: statusChange)
        }

        let endReturn = await database.statusChanges(forIDs: Array(statusChange.endReturn ?? []))
        self.endReturn = endReturn.map { statusChange in
            ObservableStatusChange(mode: mode, statusChange: statusChange)
        }

        let endOnEnd = await database.statusChanges(forIDs: Array(statusChange.endOnEnd ?? []))
        self.endOnEnd = endOnEnd.map { statusChange in
            ObservableStatusChange(mode: mode, statusChange: statusChange)
        }

        localizedDescription = await statusInfoTable.localizedDescription(forStatusID: statusChange.icon.rawValue)
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
