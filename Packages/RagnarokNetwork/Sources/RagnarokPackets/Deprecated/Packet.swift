//
//  Packet.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2021/7/5.
//

import BinaryIO
import Foundation

@available(*, deprecated)
public protocol _Packet: Sendable {
    var packetType: Int16 { get }
    var packetLength: Int16 { get }
}

@available(*, deprecated)
public protocol _DecodablePacket: _Packet, BinaryDecodable {
    static var packetType: Int16 { get }
}

@available(*, deprecated)
public protocol _EncodablePacket: _Packet, BinaryEncodable {
    init()
}

@available(*, deprecated)
extension _DecodablePacket {
    public var packetType: Int16 {
        Self.packetType
    }
}

@available(*, deprecated)
extension BinaryDecodable {
    static var decodedLength: Int16 {
        let data = Data(count: Int(Int16.max))
        let stream = MemoryStream(data: data)
        defer {
            stream.close()
        }

        let decoder = BinaryDecoder(stream: stream)
        _ = try? Self.init(from: decoder)
        let decodedLength = Int16(stream.position)
        return decodedLength
    }
}

@available(*, deprecated)
extension BinaryDecoder {
    @discardableResult
    func decodePacketType<P>(_ type: P.Type) throws -> Int16 where P: _DecodablePacket {
        let packetType = try decode(Int16.self)
        guard packetType == type.packetType else {
            throw PacketDecodingError.packetMismatch(packetType)
        }
        return packetType
    }
}
