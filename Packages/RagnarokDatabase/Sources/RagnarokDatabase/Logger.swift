//
//  Logger.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2025/2/27.
//

import OSLog
import RagnarokCore

let logger = Logger(subsystem: "RagnarokDatabase", category: "RagnarokDatabase")
let metric = PerformanceMetric(logger: logger)
