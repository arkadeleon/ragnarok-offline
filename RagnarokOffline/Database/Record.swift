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
    var recordID: String { get }
    var recordName: String { get }
    var recordFields: [RecordField] { get }
}

struct AnyRecord: Record, Hashable {

    private let record: Record

    init<R>(_ record: R) where R: Record {
        self.record = record
    }

    var recordID: String {
        record.recordID
    }

    var recordName: String {
        record.recordName
    }

    var recordFields: [RecordField] {
        record.recordFields
    }

    static func == (lhs: AnyRecord, rhs: AnyRecord) -> Bool {
        return lhs.recordID == rhs.recordID
    }

    func hash(into hasher: inout Hasher) {
        recordID.hash(into: &hasher)
    }
}
