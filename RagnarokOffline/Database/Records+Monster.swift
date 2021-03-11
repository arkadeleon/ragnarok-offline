//
//  Records+Monster.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/11.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import SQLite

extension Records {

    struct Monster: Record {

        private let row: Row

        init(from row: Row) {
            self.row = row
        }

        var id: String {
            let id = Expression<String>("ID")
            return "Monster#\(row[id])"
        }

        var name: String {
            let name = Expression<String>("iName")
            return row[name]
        }

        var fields: [String: RecordValue] {
            return [:]
        }
    }
}
