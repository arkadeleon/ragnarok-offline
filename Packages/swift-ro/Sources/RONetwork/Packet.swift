//
//  Packet.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/5.
//

public protocol Packet {
    static var packetType: Int16 { get }

    var packetLength: Int16 { get }
}

extension Packet {
    public var packetType: Int16 {
        Self.packetType
    }
}

public protocol DecodablePacket: Packet, BinaryDecodable {
}

public protocol EncodablePacket: Packet, BinaryEncodable {
}

extension BinaryDecoder {
    @discardableResult
    public func decodePacketType<P>(_ type: P.Type) throws -> Int16 where P: Packet {
        let packetType = try decode(Int16.self)
        guard packetType == type.packetType else {
            throw PacketDecodingError.packetMismatch(packetType)
        }
        return packetType
    }
}
