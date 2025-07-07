//
//  MapNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/27.
//

import BinaryIO
import Foundation

final public class MapNameTable: Resource {
    let mapNamesByRSW: [String : String]

    init(mapNamesByRSW: [String : String] = [:]) {
        self.mapNamesByRSW = mapNamesByRSW
    }

    public func localizedMapName(forMapName mapName: String) -> String? {
        mapNamesByRSW[mapName]
    }
}

extension ResourceManager {
    public func mapNameTable() async -> MapNameTable {
        if let task = tasks.withLock({ $0["MapNameTable"] }) {
            return await task.value as! MapNameTable
        }

        let task = Task<any Resource, Never> {
            guard let url = Bundle.module.url(forResource: "mapnametable", withExtension: "txt", locale: locale),
                  let stream = FileStream(forReadingFrom: url) else {
                return MapNameTable()
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

            return MapNameTable(mapNamesByRSW: mapNamesByRSW)
        }

        tasks.withLock {
            $0["MapNameTable"] = task
        }

        return await task.value as! MapNameTable
    }
}
