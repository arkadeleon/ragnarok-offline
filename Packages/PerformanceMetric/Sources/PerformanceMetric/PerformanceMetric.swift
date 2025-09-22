//
//  PerformanceMetric.swift
//  PerformanceMetric
//
//  Created by Leon Li on 2025/3/21.
//

import OSLog

final public class PerformanceMetric: Sendable {
    let logger: Logger

    private let records = OSAllocatedUnfairLock<[String : Double]>(initialState: [:])

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
        let beginTime = records.withLock {
            let beginTime = $0[name]
            return beginTime
        }

        if let beginTime {
            let endTime = CFAbsoluteTimeGetCurrent()
            logger.info("\(name) (\(endTime - beginTime)s)")
        }
        #endif
    }

    public func endMeasuring(_ name: String, _ error: any Error) {
        #if DEBUG
        let beginTime = records.withLock {
            let beginTime = $0[name]
            return beginTime
        }

        if let beginTime {
            let endTime = CFAbsoluteTimeGetCurrent()
            logger.warning("\(name) (\(endTime - beginTime)s) \(error)")
        }
        #else
        logger.warning("\(name) \(error)")
        #endif
    }
}
