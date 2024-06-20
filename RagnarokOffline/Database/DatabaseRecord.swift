//
//  ObservableDatabaseRecord.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import CoreGraphics
import rAthenaCommon

struct DatabaseRecordDetail {
    enum Section: Identifiable {
        case image(LocalizedStringResource, CGImage)
        case attributes(LocalizedStringResource, [DatabaseRecordAttribute])
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

    var sections: [Section]
}

struct DatabaseRecordAttribute: Identifiable {
    var name: LocalizedStringResource
    var value: String

    var id: String {
        name.key
    }

    init(name: LocalizedStringResource, value: String) {
        self.name = name
        self.value = value
    }

    init(name: LocalizedStringResource, value: Bool) {
        self.name = name
        self.value = value ? String(localized: "Yes") : String(localized: "No")
    }

    init(name: LocalizedStringResource, value: Int) {
        self.name = name
        self.value = value.formatted()
    }

    init(name: LocalizedStringResource, value: Double) {
        self.name = name
        self.value = value.formatted()
    }

    init(name: LocalizedStringResource, value resource: LocalizedStringResource) {
        self.name = name
        self.value = String(localized: resource)
    }
}

protocol DatabaseRecord: Hashable, Identifiable {
    var recordID: String { get }

    var recordName: String { get }

    func recordDetail(for mode: ServerMode) async throws -> DatabaseRecordDetail
}

extension DatabaseRecord {
    static func == (lhs: any DatabaseRecord, rhs: any DatabaseRecord) -> Bool {
        lhs.recordID == rhs.recordID
    }

    public var id: String {
        recordID
    }

    public func hash(into hasher: inout Hasher) {
        recordID.hash(into: &hasher)
    }
}
