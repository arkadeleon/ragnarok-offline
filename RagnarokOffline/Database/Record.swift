//
//  Record.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/2.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import SQLite

protocol Record {

    var id: String { get }
    var name: String { get }
    var fields: [String: RecordValue] { get }
}

struct AnyRecord: Record, Hashable {

    let id: String
    let name: String
    let fields: [String: RecordValue]

    init<R>(_ record: R) where R: Record {
        id = record.id
        name = record.name
        fields = record.fields
    }

    static func == (lhs: AnyRecord, rhs: AnyRecord) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

enum RecordValue {
    case string(String)
    case attributedString(NSAttributedString)
    case records([AnyRecord])
}
