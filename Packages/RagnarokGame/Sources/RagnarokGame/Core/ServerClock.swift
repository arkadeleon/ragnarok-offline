//
//  ServerClock.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/7.
//

import Foundation
import QuartzCore

struct ServerClock {
    private var referenceTick: UInt32?
    private var referenceTime: TimeInterval = CACurrentMediaTime()
    private var bestRoundTripTime: TimeInterval?

    mutating func synchronize(
        serverTick: UInt32,
        receiveTime: TimeInterval,
        roundTripTime: TimeInterval? = nil
    ) {
        if let bestRoundTripTime {
            guard let roundTripTime, roundTripTime <= bestRoundTripTime else {
                return
            }
        }

        referenceTick = serverTick
        referenceTime = receiveTime - (roundTripTime ?? 0) / 2
        bestRoundTripTime = roundTripTime
    }

    func time(forServerTick serverTick: UInt32) -> TimeInterval {
        guard let referenceTick else {
            return CACurrentMediaTime()
        }

        let elapsedMilliseconds = Int32(bitPattern: serverTick &- referenceTick)
        return referenceTime + TimeInterval(elapsedMilliseconds) / 1000
    }
}
