//
//  ServerMode+DBPath.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

import rAthenaCommon

extension ServerMode {
    var dbPath: String {
        switch self {
        case .prerenewal: "pre-re"
        case .renewal: "re"
        }
    }
}
