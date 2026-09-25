//
//  PacketProtocol.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2025/11/19.
//

import BinaryIO

public protocol PacketProtocol: Sendable {
}

public protocol DecodablePacket: PacketProtocol {
    static var size: Int { get }

    init(from decoder: BinaryDecoder) throws
}

public protocol EncodablePacket: PacketProtocol {
    func encode(to encoder: BinaryEncoder) throws
}

public typealias CodablePacket = DecodablePacket & EncodablePacket
