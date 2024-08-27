//
//  PacketDecoder.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/6/28.
//

import Foundation

public enum PacketDecodingError: Error {
    case packetMismatch(Int16)
    case unknownPacket(Int16)
}

public class PacketDecoder {
    private var packetsByType: [Int16 : any DecodablePacket.Type] = [:]

    public init() {
    }

    public func registerPacket<P>(_ type: P.Type) where P: DecodablePacket {
        packetsByType[type.packetType] = type
    }

    public func decode(from data: Data) throws -> [any DecodablePacket] {
        var packets: [any DecodablePacket] = []

        let decoder = BinaryDecoder(data: data)
        while decoder.data.count >= 2 {
            let packetType = decoder.data.prefix(2).withUnsafeBytes({ $0.bindMemory(to: Int16.self) })[0]
            guard let decodablePacket = packetsByType[packetType] else {
                throw PacketDecodingError.unknownPacket(packetType)
            }
            let packet = try decodablePacket.init(from: decoder)
            packets.append(packet)
        }

        return packets
    }
}
