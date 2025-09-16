//
//  StatusInfoTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/8/5.
//

import Foundation

struct StatusInfo: Decodable {
    var statusDescription: String
}

final public class StatusInfoTable: Resource {
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
        let taskIdentifier = "StatusInfoTable-\(localeIdentifier)"

        if let task = tasks.withLock({ $0[taskIdentifier] }) {
            return await task.value as! StatusInfoTable
        }

        let task = Task<any Resource, Never> {
            if let url = Bundle.module.url(forResource: "StatusInfo", withExtension: "json", locale: locale),
               let statusInfoTable = try? StatusInfoTable(contentsOf: url) {
                return statusInfoTable
            } else {
                return StatusInfoTable()
            }
        }

        tasks.withLock {
            $0[taskIdentifier] = task
        }

        return await task.value as! StatusInfoTable
    }
}
