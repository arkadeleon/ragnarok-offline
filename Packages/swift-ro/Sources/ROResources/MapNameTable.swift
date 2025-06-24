//
//  MapNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/27.
//

import BinaryIO
import Foundation

public struct MapNameTable: Sendable {
    public static let current = MapNameTable(locale: .current)

    let locale: Locale
    let mapNamesByRSW: [String : String]

    init(locale: Locale) {
        self.locale = locale

        self.mapNamesByRSW = {
            guard let url = Bundle.module.url(forResource: "mapnametable", withExtension: "txt", locale: locale),
                  let stream = FileStream(forReadingFrom: url) else {
                return [:]
            }

            let reader = StreamReader(stream: stream, delimiter: "\r\n")
            defer {
                reader.close()
            }

            let encoding = locale.language.preferredEncoding

            var mapNamesByRSW: [String : String] = [:]

            while let line = reader.readLine() {
                if line.trimmingCharacters(in: .whitespaces).starts(with: "//") {
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
