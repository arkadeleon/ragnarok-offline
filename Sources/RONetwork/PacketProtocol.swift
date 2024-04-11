//
//  PacketProtocol.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/5.
//

public protocol PacketProtocol {
    associatedtype PacketType: PacketTypeProtocol

    static var packetType: PacketType { get }

    var packetName: String { get }

    var packetLength: UInt16 { get }
}

extension PacketProtocol {
    var packetType: PacketType {
        Self.packetType
    }
}

public protocol DecodablePacket: PacketProtocol, BinaryDecodable {
}

public protocol EncodablePacket: PacketProtocol, BinaryEncodable {
}

public protocol PacketTypeProtocol: BinaryDecodable, BinaryEncodable {
    var rawValue: UInt16 { get }
}

extension RawRepresentable where Self: PacketTypeProtocol, RawValue == UInt16 {
    public init(from decoder: BinaryDecoder) throws {
        let rawValue = try decoder.decode(UInt16.self)
        if let packetType = Self(rawValue: rawValue) {
            self = packetType
        } else {
            throw PacketDecodingError.packetMismatch(rawValue)
        }
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(rawValue)
    }
}
