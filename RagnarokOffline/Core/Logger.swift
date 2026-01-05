//
//  Logger.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/27.
//

import OSLog
import PerformanceMetric

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "RagnarokOffline")
let metric = PerformanceMetric(logger: logger)
