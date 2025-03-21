//
//  Metric.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/21.
//

import OSLog
import Synchronization

final public class Metric: Sendable {
    let logger: Logger

    private let records = Mutex<[String : Double]>([:])

    public init(logger: Logger) {
        self.logger = logger
    }

    public func beginMeasuring(_ name: String) {
        #if DEBUG
        records.withLock {
            let beginTime = CFAbsoluteTimeGetCurrent()
            $0[name] = beginTime
        }
        #endif
    }

    public func endMeasuring(_ name: String) {
        #if DEBUG
        records.withLock {
            guard let beginTime = $0[name] else {
                return
            }
            let endTime = CFAbsoluteTimeGetCurrent()
            logger.info("\(name) (\(endTime - beginTime)s)")
        }
        #endif
    }

    public func endMeasuring(_ name: String, _ error: any Error) {
        #if DEBUG
        records.withLock {
            guard let beginTime = $0[name] else {
                return
            }
            let endTime = CFAbsoluteTimeGetCurrent()
            logger.warning("\(name) (\(endTime - beginTime)s) \(error.localizedDescription)")
        }
        #else
        logger.warning("\(name) \(error.localizedDescription)")
        #endif
    }
}
