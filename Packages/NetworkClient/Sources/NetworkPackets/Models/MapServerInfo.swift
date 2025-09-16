//
//  MapServerInfo.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/26.
//

import Darwin
import BinaryIO

public struct MapServerInfo: BinaryDecodable, Sendable {
    public var ip: String
    public var port: UInt16

    public init(from decoder: BinaryDecoder) throws {
        let ip = try decoder.decode(UInt32.self)
        let addri = in_addr(s_addr: ip)
        if let addrs = inet_ntoa(addri) {
            self.ip = String(cString: addrs)
        } else {
            self.ip = ""
        }

        port = try decoder.decode(UInt16.self)
    }
}
