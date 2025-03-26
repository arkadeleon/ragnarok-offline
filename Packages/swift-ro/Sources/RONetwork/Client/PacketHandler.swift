//
//  PacketHandler.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/27.
//

import ROCore

protocol PacketHandlerProtocol: Sendable {
    associatedtype Packet: BinaryDecodable

    var type: Packet.Type { get }

    func handlePacket(_ packet: any BinaryDecodable) async
}

struct PacketHandler<Packet>: PacketHandlerProtocol where Packet: BinaryDecodable {
    var type: Packet.Type
    var handler: @Sendable (Packet) async -> Void

    func handlePacket(_ packet: any BinaryDecodable) async {
        if let packet = packet as? Packet {
            await handler(packet)
        }
    }
}
