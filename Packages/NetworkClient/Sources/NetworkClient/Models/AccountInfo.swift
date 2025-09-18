//
//  AccountInfo.swift
//  NetworkClient
//
//  Created by Leon Li on 2025/3/29.
//

import NetworkPackets

public struct AccountInfo: Sendable {
    public let langType: UInt16 = 1

    public private(set) var accountID: UInt32
    public private(set) var loginID1: UInt32
    public private(set) var loginID2: UInt32
    public private(set) var sex: UInt8

    init(packet: PACKET_AC_ACCEPT_LOGIN) {
        self.accountID = packet.AID
        self.loginID1 = packet.login_id1
        self.loginID2 = packet.login_id2
        self.sex = packet.sex
    }

    mutating func update(accountID: UInt32) {
        self.accountID = accountID
    }
}
