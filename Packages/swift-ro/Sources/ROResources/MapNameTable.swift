//
//  MapNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/27.
//

import Foundation

public let mapNameTable = MapNameTable(locale: .current)

public actor MapNameTable {
    let locale: Locale

    lazy var mapNamesByRSW: [String : String] = {
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

    init(locale: Locale) {
        self.locale = locale
    }

    public func localizedMapName(forMapName mapName: String) -> String? {
        mapNamesByRSW[mapName]
    }
}
