//
//  MessageStringTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/6/14.
//

import Foundation
import ROCore

public struct MessageStringTable: Sendable {
    public static let current = MessageStringTable(locale: .current)

    let locale: Locale
    let messageStrings: [String]

    init(locale: Locale) {
        self.locale = locale

        self.messageStrings = {
            guard let url = Bundle.module.url(forResource: "msgstringtable", withExtension: "txt", locale: locale),
                  let stream = try? FileStream(url: url) else {
                return []
            }

            let reader = StreamReader(stream: stream, delimiter: "\r\n")
            defer {
                reader.close()
            }

            let encoding = locale.language.preferredEncoding

            var messageStrings: [String] = []

            while let line = reader.readLine() {
                let columns = line.split(separator: "#")
                if columns.count == 1 {
                    let messageString = columns[0].transcoding(from: .isoLatin1, to: encoding) ?? ""
                    messageStrings.append(messageString)
                }
            }

            return messageStrings
        }()
    }

    public func localizedMessageString(at index: Int) -> String {
        messageStrings[index]
    }
}
