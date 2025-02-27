//
//  CharServerInfo.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/10.
//

import Darwin
import ROGenerated

public struct CharServerInfo: Sendable {
    public let ip: String
    public let port: UInt16
    public let name: String
    public let users: UInt16
    public let type: UInt16
    public let new: UInt16

    init(sub: PACKET_AC_ACCEPT_LOGIN_sub) {
        let addri = in_addr(s_addr: sub.ip)
        if let addrs = inet_ntoa(addri) {
            self.ip = String(cString: addrs)
        } else {
            self.ip = ""
        }

        self.port = sub.port
        self.name = sub.name
        self.users = sub.users
        self.type = sub.type
        self.new = sub.new_
    }
}
