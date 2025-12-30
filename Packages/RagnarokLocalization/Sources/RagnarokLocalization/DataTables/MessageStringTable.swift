//
//  MessageStringTable.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2024/6/14.
//

import Foundation

final public class MessageStringTable {
    let messageStringsByID: [Int : String]

    public init(locale: Locale = .current) {
        guard let url = Bundle.module.url(forResource: "MessageString", withExtension: "json", locale: locale) else {
            self.messageStringsByID = [:]
            return
        }

        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            self.messageStringsByID = try decoder.decode([Int : String].self, from: data)
        } catch {
            self.messageStringsByID = [:]
        }
    }

    public func localizedMessageString(forID messageID: Int) -> String? {
        messageStringsByID[messageID]
    }
}
