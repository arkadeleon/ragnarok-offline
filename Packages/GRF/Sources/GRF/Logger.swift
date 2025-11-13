//
//  Logger.swift
//  GRF
//
//  Created by Leon Li on 2025/9/18.
//

#if !os(Linux)
import OSLog

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "GRF")
#endif
