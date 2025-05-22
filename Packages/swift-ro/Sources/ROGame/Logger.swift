//
//  Logger.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/3.
//

import OSLog
import ROCore

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "game")
let metric = Metric(logger: logger)
