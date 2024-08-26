//
//  Packet.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/5.
//

public protocol Packet {
    var packetType: Int16 { get }

    var packetLength: Int16 { get }
}

public protocol DecodablePacket: Packet, BinaryDecodable {
    static var packetType: Int16 { get }
}

public protocol EncodablePacket: Packet, BinaryEncodable {
    init()
}

extension DecodablePacket {
    public var packetType: Int16 {
        Self.packetType
    }
}

extension BinaryDecoder {
    @discardableResult
    public func decodePacketType<P>(_ type: P.Type) throws -> Int16 where P: DecodablePacket {
        let packetType = try decode(Int16.self)
        guard packetType == type.packetType else {
            throw PacketDecodingError.packetMismatch(packetType)
        }
        return packetType
    }
}

extension Array where Element == UInt8 {
    @inlinable mutating func replaceSubrange(from lowerBound: Int, with integer: some FixedWidthInteger) {
        let subrange = lowerBound..<(lowerBound + integer.bitWidth / 8)
        let bytes = Swift.withUnsafeBytes(of: integer, [UInt8].init)
        replaceSubrange(subrange, with: bytes)
    }

    @inlinable mutating func replaceSubrange(from lowerBound: Int, with bytes: [UInt8]) {
        let subrange = lowerBound..<(lowerBound + bytes.count)
        replaceSubrange(subrange, with: bytes)
    }
}
