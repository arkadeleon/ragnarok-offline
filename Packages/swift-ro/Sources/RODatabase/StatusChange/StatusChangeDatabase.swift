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

    private lazy var _statusChanges: [StatusChange] = {
        do {
            let decoder = YAMLDecoder()

            let url = ServerResourceManager.default.sourceURL
                .appending(path: "db/\(mode.path)/status.yml")
            let data = try Data(contentsOf: url)
            let statusChanges = try decoder.decode(ListNode<StatusChange>.self, from: data).body

            return statusChanges
        } catch {
            logger.warning("\(error.localizedDescription)")
            return []
        }
    }()

    private lazy var _statusChangesByID: [StatusChangeID : StatusChange] = {
        Dictionary(
            _statusChanges.map({ ($0.status, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }()

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    public func statusChanges() -> [StatusChange] {
        _statusChanges
    }

    public func statusChange(forID statusChangeID: StatusChangeID) -> StatusChange? {
        _statusChangesByID[statusChangeID]
    }

    public func statusChanges(forIDs statusChangeIDs: [StatusChangeID]) -> [StatusChange] {
        statusChangeIDs.compactMap {
            statusChange(forID: $0)
        }
    }
}
