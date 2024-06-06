//
//  ObservableDatabaseRecord.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import CoreGraphics
import rAthenaCommon

typealias DatabaseRecordField = (title: LocalizedStringResource, value: String)

struct DatabaseRecordDetail {
    enum Section: Identifiable {
        case image(LocalizedStringResource, CGImage)
        case attributes(LocalizedStringResource, [Attribute])
        case description(LocalizedStringResource, String)
        case script(LocalizedStringResource, String)
        case references(LocalizedStringResource, [any DatabaseRecord])

        var id: String {
            switch self {
            case .image(let title, _):
                title.key
            case .attributes(let title, _):
                title.key
            case .description(let title, _):
                title.key
            case .script(let title, _):
                title.key
            case .references(let title, _):
                title.key
            }
        }
    }

    struct Attribute: Identifiable {
        var name: LocalizedStringResource
        var value: String

        var id: String {
            name.key
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
