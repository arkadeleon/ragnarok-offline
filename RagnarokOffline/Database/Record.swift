//
//  Record.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/2.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

enum RecordValue {
    case string(String)
    case attributedString(NSAttributedString)
    case references([AnyRecord])
}

struct RecordField {
    var name: String
    var value: RecordValue
}

protocol Record {
    var id: String { get }
    var name: String { get }
    var fields: [RecordField] { get }
}

struct AnyRecord: Record, Hashable {

    private let record: Record

    init<R>(_ record: R) where R: Record {
        self.record = record
    }

    var id: String {
        record.id
    }

    var name: String {
        record.name
    }

    var fields: [RecordField] {
        record.fields
    }

    static func == (lhs: AnyRecord, rhs: AnyRecord) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
