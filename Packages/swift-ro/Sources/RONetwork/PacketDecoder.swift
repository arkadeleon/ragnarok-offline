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
            if let decodablePacket = packetsByType[packetType] {
                let packet = try decodablePacket.init(from: decoder)
                packets.append(packet)
                print("Decoded packet: \(packet)")
            } else if let entry = packetDatabase.entriesByPacketType[packetType] {
                if entry.packetLength == -1 {
                    let packetType = try decoder.decode(Int16.self)
                    let packetLength = try decoder.decode(Int16.self)
                    _ = try decoder.decode([UInt8].self, length: Int(packetLength - 2 - 2))
                    print("Unimplemented packet: 0x" + String(packetType, radix: 16) + ", length: \(packetLength)")
                } else {
                    _ = try decoder.decode([UInt8].self, length: Int(entry.packetLength))
                    print("Unimplemented packet: 0x" + String(entry.packetType, radix: 16) + ", length: \(entry.packetLength)")
                }
            } else {
                throw PacketDecodingError.unknownPacket(packetType)
            }
        }

        return packets
    }
}
