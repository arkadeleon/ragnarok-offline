//
//  ServerClock.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/7.
//

struct ServerClock {
    private var referenceTick: UInt32?
    private var referenceTime: ContinuousClock.Instant = .now
    private var bestRoundTripTime: Duration?

    mutating func synchronize(
        serverTick: UInt32,
        receiveTime: ContinuousClock.Instant,
        roundTripTime: Duration? = nil
    ) {
        if let bestRoundTripTime {
            guard let roundTripTime, roundTripTime <= bestRoundTripTime else {
                return
            }
        }

        referenceTick = serverTick
        referenceTime = receiveTime - (roundTripTime ?? .zero) / 2
        bestRoundTripTime = roundTripTime
    }

    func time(forServerTick serverTick: UInt32) -> ContinuousClock.Instant {
        guard let referenceTick else {
            return .now
        }

        let elapsedMilliseconds = Int32(bitPattern: serverTick &- referenceTick)
        return referenceTime + .milliseconds(Int(elapsedMilliseconds))
    }
}
