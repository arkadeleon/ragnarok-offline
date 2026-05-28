//
//  Logger.swift
//  RagnarokGRF
//
//  Created by Leon Li on 2025/9/18.
//

#if !os(Linux)
import OSLog

let logger = Logger(subsystem: "RagnarokGRF", category: "RagnarokGRF")
#endif
