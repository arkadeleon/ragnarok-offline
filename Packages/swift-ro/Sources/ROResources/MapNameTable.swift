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
    public func mapNameTable(for locale: Locale) async -> MapNameTable {
        let localeIdentifier = locale.identifier(.bcp47)
        let taskIdentifier = "MapNameTable-\(localeIdentifier)"

        if let task = tasks.withLock({ $0[taskIdentifier] }) {
            return await task.value as! MapNameTable
        }

        let task = Task<any Resource, Never> {
            let path = ResourcePath(components: ["data", "mapnametable.txt"])

            guard let data = try? await contentsOfResource(at: path, locale: locale) else {
                return MapNameTable()
            }

            let stream = MemoryStream(data: data)
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
            $0[taskIdentifier] = task
        }

        return await task.value as! MapNameTable
    }
}
