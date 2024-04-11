//
//  PacketProtocol.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/5.
//

public protocol PacketProtocol {
    static var packetType: UInt16 { get }

    var packetName: String { get }

    var packetLength: UInt16 { get }
}

extension PacketProtocol {
    var packetType: UInt16 {
        Self.packetType
    }
}

public protocol DecodablePacket: PacketProtocol, BinaryDecodable {
}

public protocol EncodablePacket: PacketProtocol, BinaryEncodable {
}

extension BinaryDecoder {
    @discardableResult
    public func decodePacketType<P>(_ type: P.Type) throws -> UInt16 where P: PacketProtocol {
        let packetType = try decode(UInt16.self)
        guard packetType == type.packetType else {
            throw PacketDecodingError.packetMismatch(packetType)
        }
        return packetType
    }
}
