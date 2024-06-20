//
//  StatusChangeDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/10.
//

import Foundation
import rAthenaCommon
import rAthenaResources
import rAthenaYAML

public actor StatusChangeDatabase {
    public static let prerenewal = StatusChangeDatabase(mode: .prerenewal)
    public static let renewal = StatusChangeDatabase(mode: .renewal)

    public static func database(for mode: ServerMode) -> StatusChangeDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: ServerMode

    private var cachedStatusChanges: [StatusChange] = []
    private var cachedStatusChangesByNames: [String : StatusChange] = [:]

    private init(mode: ServerMode) {
        self.mode = mode
    }

    public func statusChanges() throws -> [StatusChange] {
        if cachedStatusChanges.isEmpty {
            let decoder = YAMLDecoder()

            let url = ServerResourceBundle.shared.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("status.yml")
            let data = try Data(contentsOf: url)
            cachedStatusChanges = try decoder.decode(ListNode<StatusChange>.self, from: data).body
        }

        return cachedStatusChanges
    }

    public func statusChange(forName name: String) throws -> StatusChange? {
        if cachedStatusChangesByNames.isEmpty {
            let statusChanges = try statusChanges()
            cachedStatusChangesByNames = Dictionary(statusChanges.map({ ($0.status, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let statusChange = cachedStatusChangesByNames[name]
        return statusChange
    }
}
