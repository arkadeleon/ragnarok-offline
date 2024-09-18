//
//  MessageStringTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/6/14.
//

import Foundation

final public class MessageStringTable: Sendable {
    public static let shared = MessageStringTable(locale: .current)

    let locale: Locale
    let messageTable: [String]

    init(locale: Locale) {
        self.locale = locale

        messageTable = {
            guard let string = Bundle.module.string(forResource: "msgstringtable", withExtension: "txt", encoding: .isoLatin1, locale: locale) else {
                return []
            }

            var messageTable: [String] = []

            let lines = string.split(separator: "\r\n")
            let encoding = locale.language.preferredEncoding

            for line in lines {
                let columns = line.split(separator: "#")
                if columns.count == 1 {
                    let message = columns[0].transcoding(from: .isoLatin1, to: encoding) ?? ""
                    messageTable.append(message)
                }
            }

            return messageTable
        }()
    }

    public func localizedMessageString(at index: Int) -> String {
        messageTable[index]
    }
}
