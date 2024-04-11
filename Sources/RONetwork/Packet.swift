//
//  Packet.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/5.
//

public protocol Packet {
    static var packetType: UInt16 { get }

    var packetLength: UInt16 { get }
}

extension Packet {
    public var packetType: UInt16 {
        Self.packetType
    }
}

public protocol DecodablePacket: Packet, BinaryDecodable {
}

public protocol EncodablePacket: Packet, BinaryEncodable {
}

extension BinaryDecoder {
    @discardableResult
    public func decodePacketType<P>(_ type: P.Type) throws -> UInt16 where P: Packet {
        let packetType = try decode(UInt16.self)
        guard packetType == type.packetType else {
            throw PacketDecodingError.packetMismatch(packetType)
        }
        return packetType
    }
}
