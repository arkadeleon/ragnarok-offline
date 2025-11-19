//
//  PacketHandler.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/8/27.
//

import RagnarokPackets

protocol PacketHandlerProtocol: Sendable {
    associatedtype Packet: DecodablePacket

    var type: Packet.Type { get }

    func handlePacket(_ packet: any DecodablePacket)
}

struct PacketHandler<Packet>: PacketHandlerProtocol where Packet: DecodablePacket {
    var type: Packet.Type
    var handler: @Sendable (Packet) -> Void

    func handlePacket(_ packet: any DecodablePacket) {
        if let packet = packet as? Packet {
            handler(packet)
        }
    }
}
