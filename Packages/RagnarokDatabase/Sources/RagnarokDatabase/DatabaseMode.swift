//
//  DatabaseMode.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/4/8.
//

public enum DatabaseMode: Sendable {
    case prerenewal
    case renewal

    var path: String {
        switch self {
        case .prerenewal: "pre-re"
        case .renewal: "re"
        }
    }
}
