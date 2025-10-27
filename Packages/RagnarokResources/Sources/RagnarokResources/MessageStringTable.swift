//
//  MessageStringTable.swift
//  RagnarokResources
//
//  Created by Leon Li on 2024/6/14.
//

import Foundation

final public class MessageStringTable: LocalizedResource {
    let messageStringsByID: [Int : String]

    init() {
        self.messageStringsByID = [:]
    }

    init(contentsOf url: URL) throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        self.messageStringsByID = try decoder.decode([Int : String].self, from: data)
    }

    public func localizedMessageString(forID messageID: Int) -> String? {
        messageStringsByID[messageID]
    }
}

extension ResourceManager {
    public func messageStringTable(for locale: Locale) async -> MessageStringTable {
        let localeIdentifier = locale.identifier(.bcp47)
        let resourceIdentifier = "MessageStringTable-\(localeIdentifier)"

        return await cache.resource(forIdentifier: resourceIdentifier) {
            if let url = Bundle.module.url(forResource: "MessageString", withExtension: "json", locale: locale),
               let messageStringTable = try? MessageStringTable(contentsOf: url) {
                return messageStringTable
            } else {
                return MessageStringTable()
            }
        }
    }
}
