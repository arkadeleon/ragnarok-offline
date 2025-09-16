//
//  StatusChangeModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import Constants
import CoreGraphics
import Observation
import RODatabase
import RORendering
import ROResources

@Observable
@dynamicMemberLookup
final class StatusChangeModel {
    private let mode: DatabaseMode
    private let statusChange: StatusChange

    var iconImage: CGImage?
    var fail: [StatusChangeModel] = []
    var endOnStart: [StatusChangeModel] = []
    var endReturn: [StatusChangeModel] = []
    var endOnEnd: [StatusChangeModel] = []
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
            let scriptContext = await ResourceManager.shared.scriptContext(for: .current)
            let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)
            if let path = pathGenerator.generateStatusIconImagePath(statusID: statusChange.icon.rawValue) {
                iconImage = try? await ResourceManager.shared.image(at: path)
            }
        }
    }

    @MainActor
    func fetchDetail(database: DatabaseModel) async {
        if let fail = statusChange.fail {
            self.fail = await database.statusChanges(for: Array(fail))
        }

        if let endOnStart = statusChange.endOnStart {
            self.endOnStart = await database.statusChanges(for: Array(endOnStart))
        }

        if let endReturn = statusChange.endReturn {
            self.endReturn = await database.statusChanges(for: Array(endReturn))
        }

        if let endOnEnd = statusChange.endOnEnd {
            self.endOnEnd = await database.statusChanges(for: Array(endOnEnd))
        }

        let statusInfoTable = await ResourceManager.shared.statusInfoTable(for: .current)
        localizedDescription = statusInfoTable.localizedStatusDescription(forStatusID: statusChange.icon.rawValue)
    }
}

extension StatusChangeModel: Equatable {
    static func == (lhs: StatusChangeModel, rhs: StatusChangeModel) -> Bool {
        lhs.statusChange.status == rhs.statusChange.status
    }
}

extension StatusChangeModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(statusChange.status)
    }
}

extension StatusChangeModel: Identifiable {
    var id: StatusChangeID {
        statusChange.status
    }
}
