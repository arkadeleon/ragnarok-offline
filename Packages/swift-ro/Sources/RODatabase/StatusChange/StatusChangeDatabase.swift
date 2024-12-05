//
//  StatusChangeDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/10.
//

import Foundation
import ROGenerated
import rAthenaResources

public actor StatusChangeDatabase {
    public static let prerenewal = StatusChangeDatabase(mode: .prerenewal)
    public static let renewal = StatusChangeDatabase(mode: .renewal)

    public static func database(for mode: DatabaseMode) -> StatusChangeDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: DatabaseMode

    private var cachedStatusChanges: [StatusChange] = []
    private var cachedStatusChangesByID: [StatusChangeID : StatusChange] = [:]

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    public func statusChanges() throws -> [StatusChange] {
        if cachedStatusChanges.isEmpty {
            let decoder = YAMLDecoder()

            let url = ServerResourceManager.default.sourceURL
                .appending(path: "db/\(mode.path)/status.yml")
            let data = try Data(contentsOf: url)
            cachedStatusChanges = try decoder.decode(ListNode<StatusChange>.self, from: data).body
        }

        return cachedStatusChanges
    }

    public func statusChange(forID statusChangeID: StatusChangeID) throws -> StatusChange? {
        if cachedStatusChangesByID.isEmpty {
            let statusChanges = try statusChanges()
            cachedStatusChangesByID = Dictionary(statusChanges.map({ ($0.status, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let statusChange = cachedStatusChangesByID[statusChangeID]
        return statusChange
    }

    public func statusChanges(forIDs statusChangeIDs: [StatusChangeID]) throws -> [StatusChange] {
        try statusChangeIDs.compactMap {
            try statusChange(forID: $0)
        }
    }
}
