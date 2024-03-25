//
//  ServerStatus+CustomStringConvertible.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/25.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import rAthenaCommon

extension ServerStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notStarted: "NOT STARTED"
        case .starting: "STARTING"
        case .running: "RUNNING"
        case .stopping: "STOPPING"
        case .stopped: "STOPPED"
        @unknown default: ""
        }
    }
}
