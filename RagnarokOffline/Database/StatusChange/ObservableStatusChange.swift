//
//  ObservableStatusChange.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import CoreGraphics
import Observation
import ROConstants
import RODatabase
import RORendering
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

    @MainActor
    func fetchIconImage() async {
        if iconImage == nil {
            let pathGenerator = ResourcePathGenerator(scriptManager: .shared)
            if let path = await pathGenerator.generateStatusIconImagePath(statusID: statusChange.icon.rawValue) {
                iconImage = try? await ResourceManager.shared.image(at: path)
            }
        }
    }

    @MainActor
    func fetchDetail() async {
        let database = StatusChangeDatabase.shared

        let fail = await database.statusChanges(for: Array(statusChange.fail ?? []))
        self.fail = fail.map { statusChange in
            ObservableStatusChange(mode: mode, statusChange: statusChange)
        }

        let endOnStart = await database.statusChanges(for: Array(statusChange.endOnStart ?? []))
        self.endOnStart = endOnStart.map { statusChange in
            ObservableStatusChange(mode: mode, statusChange: statusChange)
        }

        let endReturn = await database.statusChanges(for: Array(statusChange.endReturn ?? []))
        self.endReturn = endReturn.map { statusChange in
            ObservableStatusChange(mode: mode, statusChange: statusChange)
        }

        let endOnEnd = await database.statusChanges(for: Array(statusChange.endOnEnd ?? []))
        self.endOnEnd = endOnEnd.map { statusChange in
            ObservableStatusChange(mode: mode, statusChange: statusChange)
        }

        localizedDescription = await StatusInfoTable.current.localizedDescription(forStatusID: statusChange.icon.rawValue)
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
