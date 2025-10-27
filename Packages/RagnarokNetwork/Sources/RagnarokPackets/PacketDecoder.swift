//
//  PacketDecoder.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2021/6/28.
//

import Foundation
import BinaryIO

enum PacketDecodingError: Error {
    case packetMismatch(Int16)
    case unknownPacket(Int16)
}

final public class PacketDecoder {
    public init() {
    }

    public func decode(from data: Data) throws -> [any RegisteredPacket] {
        var packets: [any RegisteredPacket] = []

        let stream = MemoryStream(data: data)
        defer {
            stream.close()
        }

        let decoder = BinaryDecoder(stream: stream)

        while stream.length - stream.position >= 2 {
            let packetType = try decoder.decode(Int16.self)
            try stream.seek(-MemoryLayout<Int16>.size, origin: .current)

            if let registeredPacket = registeredPackets[packetType] {
                let packet = try registeredPacket.init(from: decoder)
                packets.append(packet)
            } else if let entry = packetDatabase.entriesByPacketType[packetType] {
                if entry.packetLength == -1 {
                    let packetType = try decoder.decode(Int16.self)
                    let packetLength = try decoder.decode(Int16.self)
                    _ = try decoder.decode([UInt8].self, count: Int(packetLength - 2 - 2))
                    logger.info("Unimplemented packet: 0x\(UInt16(packetType), format: .hex), length: \(packetLength)")
                } else {
                    _ = try decoder.decode([UInt8].self, count: Int(entry.packetLength))
                    logger.info("Unimplemented packet: 0x\(UInt16(entry.packetType), format: .hex), length: \(entry.packetLength)")
                }
            } else {
                logger.info("Unknown packet: 0x\(UInt16(packetType), format: .hex), remaining bytes: \(stream.length - stream.position)")
                break
            }
        }

        return packets
    }
}
