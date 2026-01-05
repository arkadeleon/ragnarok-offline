//
//  StatusChangeDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/5/10.
//

import Foundation
import RapidYAML

final public class StatusChangeDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func statusChanges() async throws -> [StatusChange] {
        metric.beginMeasuring("Load status changes")

        let decoder = YAMLDecoder()

        let url = baseURL.appending(path: "db/\(mode.path)/status.yml")
        let data = try Data(contentsOf: url)
        let statusChanges = try decoder.decode(ListNode<StatusChange>.self, from: data).body

        metric.endMeasuring("Load status changes")

        return statusChanges
    }
}
