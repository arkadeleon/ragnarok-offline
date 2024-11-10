//
//  PacketDecoder.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/6/28.
//

import Foundation
import ROCore

enum PacketDecodingError: Error {
    case packetMismatch(Int16)
    case unknownPacket(Int16)
}

final class PacketDecoder {
    let registeredPackets: [Int16 : any DecodablePacket.Type]

    init(registeredPackets: [Int16 : any DecodablePacket.Type]) {
        self.registeredPackets = registeredPackets
    }

    func decode(from data: Data) throws -> [any DecodablePacket] {
        var packets: [any DecodablePacket] = []

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
                print("Decoded packet: \(packet)")
            } else if let entry = packetDatabase.entriesByPacketType[packetType] {
                if entry.packetLength == -1 {
                    let packetType = try decoder.decode(Int16.self)
                    let packetLength = try decoder.decode(Int16.self)
                    _ = try decoder.decode([UInt8].self, count: Int(packetLength - 2 - 2))
                    print("Unimplemented packet: 0x" + String(packetType, radix: 16) + ", length: \(packetLength)")
                } else {
                    _ = try decoder.decode([UInt8].self, count: Int(entry.packetLength))
                    print("Unimplemented packet: 0x" + String(entry.packetType, radix: 16) + ", length: \(entry.packetLength)")
                }
            } else {
                print("Unknown packet: 0x" + String(packetType, radix: 16) + ", remaining bytes: \(stream.length - stream.position)")
                break
            }
        }

        return packets
    }
}
