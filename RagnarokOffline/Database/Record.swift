//
//  Record.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/2.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import SQLite

enum Record: Hashable {
    case item(row: Row)
    case monster(row: Row)
    case skill(row: Row)

    var id: String {
        switch self {
        case .item(let row):
            let id = Expression<String>("id")
            return "Item#\(row[id])"
        case .monster(let row):
            let id = Expression<String>("ID")
            return "Monster#\(row[id])"
        case .skill(let row):
            let id = Expression<Int64>("SKILL_ID")
            return "Skill#(\(row[id])"
        }
    }

    var name: String {
        switch self {
        case .item(let row):
            let name = Expression<String>("name_english")
            return row[name]
        case .monster(let row):
            let name = Expression<String>("iName")
            return row[name]
        case .skill(let row):
            let info = Expression<String>("INFO")
            return row[info]
        }
    }

    static func == (lhs: Record, rhs: Record) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
