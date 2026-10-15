//
//  StatusIconTable.swift
//  RagnarokResources
//
//  Created by Leon Li on 2026/10/15.
//

import Foundation

final public class StatusIconTable: Resource {
    let statusIconNamesByID: [Int : String]

    init(statusIconNamesByID: [Int : String] = [:]) {
        self.statusIconNamesByID = statusIconNamesByID
    }

    public func statusIconName(forStatusID statusID: Int) -> String? {
        statusIconNamesByID[statusID]
    }
}

extension ResourceManager {
    public func statusIconTable() async -> StatusIconTable {
        await cache.resource(forIdentifier: "StatusIconTable") {
            guard let url = Bundle.module.url(forResource: "StatusIcon", withExtension: "json") else {
                return StatusIconTable()
            }

            do {
                let decoder = JSONDecoder()
                let data = try Data(contentsOf: url)
                let statusIconNamesByID = try decoder.decode([Int : String].self, from: data)
                return StatusIconTable(statusIconNamesByID: statusIconNamesByID)
            } catch {
                return StatusIconTable()
            }
        }
    }
}
