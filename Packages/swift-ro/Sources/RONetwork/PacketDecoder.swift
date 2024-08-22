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
    public let decodablePackets: [any DecodablePacket.Type]

    private let decodablePacketsByType: [Int16 : any DecodablePacket.Type]

    public init(decodablePackets: [any DecodablePacket.Type]) {
        self.decodablePackets = decodablePackets
        self.decodablePacketsByType = Dictionary(uniqueKeysWithValues: decodablePackets.map({ ($0.packetType, $0) }))
    }

    public func decode(from data: Data) throws -> [any DecodablePacket] {
        var packets: [any DecodablePacket] = []

        let decoder = BinaryDecoder(data: data)
        while decoder.data.count >= 2 {
            let packetType = decoder.data.prefix(2).withUnsafeBytes({ $0.bindMemory(to: Int16.self) })[0]
            guard let decodablePacket = decodablePacketsByType[packetType] else {
                throw PacketDecodingError.unknownPacket(packetType)
            }
            let packet = try decodablePacket.init(from: decoder)
            packets.append(packet)
        }

        return packets
    }
}
