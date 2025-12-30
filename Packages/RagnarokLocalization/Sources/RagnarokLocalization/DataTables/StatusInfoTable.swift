//
//  StatusInfoTable.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2025/8/5.
//

import Foundation

struct StatusInfo: Decodable {
    var statusDescription: String
}

final public class StatusInfoTable {
    let statusInfosByID: [Int : StatusInfo]

    public init(locale: Locale = .current) {
        guard let url = Bundle.module.url(forResource: "StatusInfo", withExtension: "json", locale: locale) else {
            self.statusInfosByID = [:]
            return
        }

        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            self.statusInfosByID = try decoder.decode([Int : StatusInfo].self, from: data)
        } catch {
            self.statusInfosByID = [:]
        }
    }

    public func localizedStatusDescription(forStatusID statusID: Int) -> String? {
        statusInfosByID[statusID]?.statusDescription
    }
}
