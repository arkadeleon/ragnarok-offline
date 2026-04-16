//
//  Logger.swift
//  RagnarokRealityRendering
//
//  Created by Leon Li on 2025/9/17.
//

import OSLog
import RagnarokCore

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "RagnarokRealityRendering")
let metric = PerformanceMetric(logger: logger)
