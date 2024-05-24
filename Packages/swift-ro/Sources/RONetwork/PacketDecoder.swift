//
//  PacketDecoder.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/6/28.
//

import Foundation

public enum PacketDecodingError: Error {
    case packetMismatch(UInt16)
    case unknownPacket(UInt16)
}

public class PacketDecoder {
    private let packets: [UInt16 : any DecodablePacket.Type]

    public init() {
        self.packets = Dictionary(uniqueKeysWithValues: PacketManager.shared.decodablePackets.map({ ($0.packetType, $0) }))
    }

    public func decode(from data: Data) throws -> any DecodablePacket {
        let packetTypeDecoder = BinaryDecoder(data: data)
        let packetType = try packetTypeDecoder.decode(UInt16.self)
        guard let packet = packets[packetType] else {
            throw PacketDecodingError.unknownPacket(packetType)
        }
        let decoder = BinaryDecoder(data: data)
        return try packet.init(from: decoder)
    }
}
