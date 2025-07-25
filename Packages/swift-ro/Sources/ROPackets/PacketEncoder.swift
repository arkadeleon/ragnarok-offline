//
//  PacketEncoder.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/6/28.
//

import Foundation
import BinaryIO

final public class PacketEncoder {
    public init() {
    }

    public func encode(_ packet: some BinaryEncodable) throws -> Data {
        let stream = MemoryStream()
        defer {
            stream.close()
        }

        let encoder = BinaryEncoder(stream: stream)
        try packet.encode(to: encoder)

        let data = Data(stream: stream)
        return data
    }
}
