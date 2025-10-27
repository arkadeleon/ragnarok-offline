//
//  PacketHandler.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/8/27.
//

import BinaryIO

protocol PacketHandlerProtocol: Sendable {
    associatedtype Packet: BinaryDecodable

    var type: Packet.Type { get }

    func handlePacket(_ packet: any BinaryDecodable)
}

struct PacketHandler<Packet>: PacketHandlerProtocol where Packet: BinaryDecodable {
    var type: Packet.Type
    var handler: @Sendable (Packet) -> Void

    func handlePacket(_ packet: any BinaryDecodable) {
        if let packet = packet as? Packet {
            handler(packet)
        }
    }
}
