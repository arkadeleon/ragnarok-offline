//
//  PacketEncoder.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/6/28.
//

import Foundation
import ROCore

final class PacketEncoder {
    func encode(_ packet: some BinaryEncodable) throws -> Data {
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
