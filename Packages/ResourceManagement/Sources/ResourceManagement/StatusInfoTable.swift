//
//  StatusInfoTable.swift
//  ResourceManagement
//
//  Created by Leon Li on 2025/8/5.
//

import Foundation

struct StatusInfo: Decodable {
    var statusDescription: String
}

final public class StatusInfoTable: LocalizedResource {
    let statusInfosByID: [Int : StatusInfo]

    init() {
        self.statusInfosByID = [:]
    }

    init(contentsOf url: URL) throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        self.statusInfosByID = try decoder.decode([Int : StatusInfo].self, from: data)
    }

    public func localizedStatusDescription(forStatusID statusID: Int) -> String? {
        statusInfosByID[statusID]?.statusDescription
    }
}

extension ResourceManager {
    public func statusInfoTable(for locale: Locale) async -> StatusInfoTable {
        let localeIdentifier = locale.identifier(.bcp47)
        let resourceIdentifier = "StatusInfoTable-\(localeIdentifier)"

        if let phase = resources[resourceIdentifier] {
            return await phase.resource as! StatusInfoTable
        }

        let task = ResourceTask {
            if let url = Bundle.module.url(forResource: "StatusInfo", withExtension: "json", locale: locale),
               let statusInfoTable = try? StatusInfoTable(contentsOf: url) {
                return statusInfoTable
            } else {
                return StatusInfoTable()
            }
        }

        resources[resourceIdentifier] = .inProgress(task)

        let statusInfoTable = await task.value as! StatusInfoTable

        resources[resourceIdentifier] = .loaded(statusInfoTable)

        return statusInfoTable
    }
}
