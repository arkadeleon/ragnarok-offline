//
//  MessageLocalization.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/6/14.
//

import Foundation

public actor MessageLocalization {
    public static let shared = MessageLocalization(locale: .current)

    let locale: Locale

    var messageStringTable: [String] = []
    var isMessageStringTableLoaded = false

    init(locale: Locale) {
        self.locale = locale
    }

    public func localizedMessage(at index: Int) -> String {
        try? loadMessageStringTableIfNeeded()

        let message = messageStringTable[index]
        return message
    }

    private func loadMessageStringTableIfNeeded() throws {
        guard !isMessageStringTableLoaded else {
            return
        }

        guard let url = Bundle.module.url(forResource: "msgstringtable", withExtension: "txt", locale: locale) else {
            return
        }

        let data = try Data(contentsOf: url)

        guard let string = String(data: data, encoding: .isoLatin1) else {
            return
        }

        let lines = string.split(separator: "\r\n")
        let encoding = locale.language.preferredEncoding

        for line in lines {
            let columns = line.split(separator: "#")
            if columns.count == 1 {
                let message = String(columns[0]).data(using: .isoLatin1)?.string(using: encoding) ?? ""
                messageStringTable.append(message)
            }
        }

        isMessageStringTableLoaded = true
    }
}
