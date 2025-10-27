//
//  StatusChangeDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/5/10.
//

import Foundation
import RagnarokConstants
import RapidYAML

public actor StatusChangeDatabase {
    public let baseURL: URL
    public let mode: DatabaseMode

    private lazy var _statusChanges: [StatusChange] = {
        metric.beginMeasuring("Load status change database")

        do {
            let decoder = YAMLDecoder()

            let url = baseURL.appending(path: "db/\(mode.path)/status.yml")
            let data = try Data(contentsOf: url)
            let statusChanges = try decoder.decode(ListNode<StatusChange>.self, from: data).body

            metric.endMeasuring("Load status change database")

            return statusChanges
        } catch {
            metric.endMeasuring("Load status change database", error)

            return []
        }
    }()

    private lazy var _statusChangesByID: [StatusChangeID : StatusChange] = {
        Dictionary(
            _statusChanges.map({ ($0.status, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }()

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func statusChanges() -> [StatusChange] {
        _statusChanges
    }

    public func statusChange(for statusChangeID: StatusChangeID) -> StatusChange? {
        _statusChangesByID[statusChangeID]
    }

    public func statusChanges(for statusChangeIDs: [StatusChangeID]) -> [StatusChange] {
        statusChangeIDs.compactMap {
            statusChange(for: $0)
        }
    }
}
