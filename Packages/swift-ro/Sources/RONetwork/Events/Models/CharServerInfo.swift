//
//  CharServerInfo.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/10.
//

import ROGenerated

public struct CharServerInfo: Sendable {
    public let ip: UInt32
    public let port: UInt16
    public let name: String
    public let users: UInt16
    public let type: UInt16
    public let new: UInt16

    init(sub: PACKET_AC_ACCEPT_LOGIN_sub) {
        self.ip = sub.ip
        self.port = sub.port
        self.name = sub.name
        self.users = sub.users
        self.type = sub.type
        self.new = sub.new_
    }
}
