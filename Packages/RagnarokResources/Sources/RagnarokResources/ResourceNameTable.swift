//
//  AliasTable.swift
//  RagnarokResources
//
//  Created by Leon Li on 2025/10/30.
//

import BinaryIO
import Foundation

final public class ResourceNameTable: Resource {
    let resourceNamesByAlias: [String : String]

    init(resourceNamesByAlias: [String : String] = [:]) {
        self.resourceNamesByAlias = resourceNamesByAlias
    }

    public func resourceName(forAlias alias: String) -> String? {
        resourceNamesByAlias[alias]
    }
}

extension ResourceManager {
    public func resourceNameTable() async -> ResourceNameTable {
        await cache.resource(forIdentifier: "ResourceNameTable") { [self] in
            let data: Data
            do {
                data = try await contentsOfResource(at: ["data", "resnametable.txt"])
            } catch {
                logger.warning("\(error)")
                return ResourceNameTable()
            }

            let stream = MemoryStream(data: data)
            let reader = StreamReader(stream: stream, delimiter: "\r\n")
            defer {
                reader.close()
            }

            var resourceNamesByAlias: [String : String] = [:]

            while let line = reader.readLine() {
                if line.trimmingCharacters(in: .whitespaces).starts(with: "//") {
                    continue
                }

                let columns = line.split(separator: "#")
                if columns.count >= 2 {
                    let alias = String(columns[0])
                    let resourceName = String(columns[1])
                    resourceNamesByAlias[alias] = resourceName
                }
            }

            return ResourceNameTable(resourceNamesByAlias: resourceNamesByAlias)
        }
    }
}
