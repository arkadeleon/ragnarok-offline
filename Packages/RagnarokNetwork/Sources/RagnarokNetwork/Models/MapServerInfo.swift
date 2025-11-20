//
//  MapServerInfo.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/26.
//

import Darwin
import RagnarokPackets

public struct MapServerInfo: Sendable {
    public var ip: String
    public var port: UInt16

    init(from packet: PACKET_HC_NOTIFY_ZONESVR) {
        let addri = in_addr(s_addr: packet.ip)
        if let addrs = inet_ntoa(addri) {
            ip = String(cString: addrs)
        } else {
            ip = ""
        }

        port = packet.port
    }
}
