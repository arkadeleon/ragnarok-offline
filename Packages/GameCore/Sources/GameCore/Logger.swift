//
//  Logger.swift
//  GameCore
//
//  Created by Leon Li on 2025/4/3.
//

import OSLog
import PerformanceMetric

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "GameCore")
let metric = PerformanceMetric(logger: logger)
