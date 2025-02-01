//
//  MapMP3NameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/1.
//

import Foundation

public let mapMP3NameTable = MapMP3NameTable()

public actor MapMP3NameTable {
    lazy var mapMP3NamesByRSW: [String : String] = {
        guard let string = Bundle.module.string(forResource: "mp3nametable", withExtension: "txt", encoding: .koreanEUC, locale: .korean) else {
            return [:]
        }

        var mapMP3NamesByRSW: [String : String] = [:]

        let lines = string.split(separator: "\r\n")

        for line in lines {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                continue
            }

            let columns = line.split(separator: "#")
            if columns.count >= 2 {
                let rsw = columns[0]
                    .replacingOccurrences(of: ".rsw", with: "")
                let mapMP3Name = columns[1]
                    .trimmingCharacters(in: .whitespaces)
                    .replacingOccurrences(of: "bgm\\\\", with: "")
                mapMP3NamesByRSW[rsw] = mapMP3Name
            }
        }

        return mapMP3NamesByRSW
    }()

    public func mapMP3Name(forMapName mapName: String) -> String? {
        mapMP3NamesByRSW[mapName]
    }
}
