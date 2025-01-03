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
    let mapNamesByRSW: [String : String]

    init(locale: Locale) {
        self.locale = locale

        mapNamesByRSW = {
            guard let string = Bundle.module.string(forResource: "mapnametable", withExtension: "txt", encoding: .isoLatin1, locale: locale) else {
                return [:]
            }

            var mapNamesByRSW: [String : String] = [:]

            let lines = string.split(separator: "\r\n")
            let encoding = locale.language.preferredEncoding

            for line in lines {
                if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                    continue
                }

                let columns = line.split(separator: "#")
                if columns.count >= 2 {
                    let rsw = columns[0]
                        .replacingOccurrences(of: ".rsw", with: "")
                    let mapName = columns[1]
                        .trimmingCharacters(in: .whitespaces)
                        .transcoding(from: .isoLatin1, to: encoding)
                    mapNamesByRSW[rsw] = mapName
                }
            }

            return mapNamesByRSW
        }()
    }

    public func localizedMapName(forMapName mapName: String) -> String? {
        mapNamesByRSW[mapName]
    }
}
