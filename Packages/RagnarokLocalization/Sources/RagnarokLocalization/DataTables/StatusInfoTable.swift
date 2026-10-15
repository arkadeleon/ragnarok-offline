//
//  StatusInfoTable.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2025/8/5.
//

import Foundation

struct StatusInfo: Decodable {
    var statusDescription: StatusDescription
}

public struct StatusDescription: Decodable {
    public struct Line: Decodable {
        public var text: String

        /// A color in `#RRGGBB` format.
        public var color: String?
    }

    public var lines: [StatusDescription.Line]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        lines = try container.decode([StatusDescription.Line].self)
    }
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

    /// The first line is the title, and a line of `%s` is where the remaining time goes.
    public func localizedStatusDescription(forStatusID statusID: Int) -> StatusDescription? {
        statusInfosByID[statusID]?.statusDescription
    }
}
