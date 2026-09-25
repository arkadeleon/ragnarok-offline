//
//  PacketDecoder.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2021/6/28.
//

import BinaryIO
import Foundation
import os

public enum PacketDecodingError: Error, Sendable {
    case packetMismatch(Int16)
    case unknownPacket(Int16)
    case invalidPacketLength(Int16, Int)
}

final public class PacketDecoder: Sendable {
    private let buffer = OSAllocatedUnfairLock(initialState: Data())

    public init() {
    }

    public func decode(from data: Data, packetHandler: (any DecodablePacket) -> Void) throws {
        try buffer.withLockUnchecked { buffer in
            buffer.append(data)

            let stream = MemoryStream(data: buffer)
            defer {
                stream.close()
            }

            let decoder = BinaryDecoder(stream: stream)

            while stream.length - stream.position >= 2 {
                let packetPosition = stream.position

                let packetType = try decoder.decode(Int16.self)

                var packetLength: Int
                if let registeredPacket = registeredPackets[packetType] {
                    packetLength = registeredPacket.size
                } else if let entry = packetDatabase.entriesByPacketType[packetType] {
                    packetLength = Int(entry.packetLength)
                } else {
                    logger.info("Unknown packet: 0x\(UInt16(bitPattern: packetType), format: .hex), remaining bytes: \(stream.length - packetPosition)")
                    buffer.removeAll()
                    throw PacketDecodingError.unknownPacket(packetType)
                }

                if packetLength == -1 {
                    if stream.length - stream.position < 2 {
                        try stream.seek(packetPosition, origin: .begin)
                        break
                    }

                    packetLength = Int(try decoder.decode(UInt16.self))

                    if packetLength < 4 {
                        buffer.removeAll()
                        throw PacketDecodingError.invalidPacketLength(packetType, packetLength)
                    }
                }

                try stream.seek(packetPosition, origin: .begin)

                if stream.length - packetPosition < packetLength {
                    break
                }

                if let registeredPacket = registeredPackets[packetType] {
                    do {
                        let packet = try registeredPacket.init(from: decoder)
                        packetHandler(packet)
                    } catch {
                        logger.warning("Failed to decode packet 0x\(UInt16(bitPattern: packetType), format: .hex): \(error)")
                    }
                } else {
                    logger.info("Unimplemented packet: 0x\(UInt16(bitPattern: packetType), format: .hex), length: \(packetLength)")
                }

                try stream.seek(packetPosition + packetLength, origin: .begin)
            }

            buffer.removeFirst(stream.position)
        }
    }
}
