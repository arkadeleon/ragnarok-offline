//
//  Logger.swift
//  WorldRendering
//
//  Created by Leon Li on 2025/9/17.
//

import OSLog
import PerformanceMetric

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "WorldRendering")
let metric = PerformanceMetric(logger: logger)
