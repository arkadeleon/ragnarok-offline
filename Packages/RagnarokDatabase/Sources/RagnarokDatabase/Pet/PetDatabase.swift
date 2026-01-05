//
//  PetDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/5/8.
//

import Foundation
import RapidYAML

final public class PetDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func pets() async throws -> [Pet] {
        metric.beginMeasuring("Load pets")

        let decoder = YAMLDecoder()

        let url = baseURL.appending(path: "db/\(mode.path)/pet_db.yml")
        let data = try Data(contentsOf: url)
        let pets = try decoder.decode(ListNode<Pet>.self, from: data).body

        metric.endMeasuring("Load pets")

        return pets
    }
}
