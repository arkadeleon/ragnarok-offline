//
//  Logger.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/27.
//

import OSLog
import ROCore

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "file-formats")
let metric = Metric(logger: logger)
