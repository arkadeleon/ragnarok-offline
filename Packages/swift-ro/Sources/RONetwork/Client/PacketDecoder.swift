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

struct PacketDecodingResult {
    var packet: any BinaryDecodable
    var packetType: Int16
    var packetHandler: (any BinaryDecodable) async -> Void
}

final class PacketDecoder {
    let packetRegistrations: [Int16 : any PacketRegistration]

    init(packetRegistrations: [Int16 : any PacketRegistration]) {
        self.packetRegistrations = packetRegistrations
    }

    func decode(from data: Data) throws -> [PacketDecodingResult] {
        var results: [PacketDecodingResult] = []

        let stream = MemoryStream(data: data)
        defer {
            stream.close()
        }

        let decoder = BinaryDecoder(stream: stream)

        while stream.length - stream.position >= 2 {
            let packetType = try decoder.decode(Int16.self)
            try stream.seek(-MemoryLayout<Int16>.size, origin: .current)

            if let registration = packetRegistrations[packetType] {
                let packet = try registration.type.init(from: decoder)
                let result = PacketDecodingResult(packet: packet, packetType: packetType, packetHandler: registration.handlePacket)
                results.append(result)
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

        return results
    }
}
