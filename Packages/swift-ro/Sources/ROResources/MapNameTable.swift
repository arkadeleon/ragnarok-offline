//
//  MapNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/27.
//

import Foundation

final public class MapNameTable: Sendable {
    public static let shared = MapNameTable(locale: .current)

    let locale: Locale
    let nameTable: [String : String]

    init(locale: Locale) {
        self.locale = locale

        nameTable = {
            guard let string = resourceBundle.string(forResource: "mapnametable", withExtension: "txt", encoding: .isoLatin1, locale: locale) else {
                return [:]
            }

            var nameTable: [String : String] = [:]

            let lines = string.split(separator: "\r\n")
            let encoding = locale.language.preferredEncoding

            for line in lines {
                if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                    continue
                }

                let columns = line.split(separator: "#")
                if columns.count >= 2 {
                    let mapName = columns[0]
                        .replacingOccurrences(of: ".rsw", with: "")
                    let mapDisplayName = columns[1]
                        .trimmingCharacters(in: .whitespaces)
                        .transcoding(from: .isoLatin1, to: encoding)
                    nameTable[mapName] = mapDisplayName
                }
            }

            return nameTable
        }()
    }

    public func localizedMapName(for mapName: String) -> String? {
        nameTable[mapName]
    }
}
