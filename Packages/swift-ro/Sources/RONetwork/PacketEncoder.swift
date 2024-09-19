//
//  PacketEncoder.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/6/28.
//

import Foundation

final class PacketEncoder {
    func encode(_ packet: some EncodablePacket) throws -> Data {
        let encoder = BinaryEncoder()
        try packet.encode(to: encoder)
        return encoder.data
    }
}
