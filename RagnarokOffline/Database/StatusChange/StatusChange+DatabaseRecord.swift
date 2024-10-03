//
//  StatusChange+DatabaseRecord.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import rAthenaCommon
import RODatabase

extension StatusChange: DatabaseRecord {
    var recordID: String {
        status.stringValue
    }

    var recordName: String {
        status.stringValue
    }

    func recordDetail(for mode: ServerMode) async throws -> DatabaseRecordDetail {
        let statusChangeDatabase = StatusChangeDatabase.database(for: mode)

        var sections: [DatabaseRecordDetail.Section] = []

        let info: [DatabaseRecordAttribute] = [
            .init(name: "Status", value: status.stringValue),
            .init(name: "Icon", value: icon),
        ]
        sections.append(.attributes("Info", info))

        if let fail {
            var failStatusChanges: [StatusChange] = []
            for name in fail {
                if let statusChange = try? await statusChangeDatabase.statusChange(forID: name) {
                    failStatusChanges.append(statusChange)
                }
            }
            sections.append(.references("Fail", failStatusChanges))
        }

        if let endOnStart {
            var endOnStartStatusChanges: [StatusChange] = []
            for name in endOnStart {
                if let statusChange = try? await statusChangeDatabase.statusChange(forID: name) {
                    endOnStartStatusChanges.append(statusChange)
                }
            }
            sections.append(.references("End On Start", endOnStartStatusChanges))
        }

        if let endReturn {
            var endReturnStatusChanges: [StatusChange] = []
            for name in endReturn {
                if let statusChange = try? await statusChangeDatabase.statusChange(forID: name) {
                    endReturnStatusChanges.append(statusChange)
                }
            }
            sections.append(.references("End Return", endReturnStatusChanges))
        }

        if let endOnEnd {
            var endOnEndStatusChanges: [StatusChange] = []
            for name in endOnEnd {
                if let statusChange = try? await statusChangeDatabase.statusChange(forID: name) {
                    endOnEndStatusChanges.append(statusChange)
                }
            }
            sections.append(.references("End On End", endOnEndStatusChanges))
        }

        let detail = DatabaseRecordDetail(sections: sections)
        return detail
    }
}
