//
//  ObservableDatabaseRecord.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import rAthenaCommon

typealias DatabaseRecordField = (title: String, value: String)

struct DatabaseRecordDetail {
    enum Section: Identifiable {
        case image(String)
        case attributes(String, [Attribute])
        case description(String, String)
        case script(String, String)
        case references(String, [any DatabaseRecord])

        var id: String {
            switch self {
            case .image(let title):
                title
            case .attributes(let title, _):
                title
            case .description(let title, _):
                title
            case .script(let title, _):
                title
            case .references(let title, _):
                title
            }
        }
    }

    struct Attribute: Identifiable {
        var name: String
        var value: String

        var id: String {
            name
        }
    }

    var sections: [Section]
}

protocol DatabaseRecord: Hashable, Identifiable {
    var recordID: String { get }

    var recordName: String { get }

    func recordDetail(for mode: ServerMode) async throws -> DatabaseRecordDetail
}

extension DatabaseRecord {
    public var id: String {
        recordID
    }

    public func hash(into hasher: inout Hasher) {
        recordID.hash(into: &hasher)
    }
}
