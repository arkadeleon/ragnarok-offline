//
//  StatusChange.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/10/16.
//

import Foundation
import RagnarokPackets

public struct StatusChange: Sendable {
    public let statusID: Int
    public let startTime: TimeInterval

    /// `nil` for a status without a time limit.
    public let duration: TimeInterval?

    public var endTime: TimeInterval? {
        duration.map({ startTime + $0 })
    }

    public init(statusID: Int, startTime: TimeInterval, duration: TimeInterval?) {
        self.statusID = statusID
        self.startTime = startTime
        self.duration = duration
    }

    /// The server sends 9999 as the remaining time of a status without a time limit.
    public init(from packet: PACKET_ZC_MSG_STATE_CHANGE3, startTime: TimeInterval) {
        self.statusID = Int(packet.index)
        self.startTime = startTime
        self.duration = packet.remain == 9999 ? nil : TimeInterval(packet.remain) / 1000
    }
}
