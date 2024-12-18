//
//  PacketRegistration.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/27.
//

import ROCore

protocol PacketRegistration {
    associatedtype Packet: BinaryDecodable

    var type: Packet.Type { get }
    var handler: (Packet) async -> Void { get }

    func handlePacket(_ packet: any BinaryDecodable) async
}

struct _PacketRegistration<Packet>: PacketRegistration where Packet: BinaryDecodable {
    var type: Packet.Type
    var handler: (Packet) async -> Void

    func handlePacket(_ packet: any BinaryDecodable) async {
        if let packet = packet as? Packet {
            await handler(packet)
        }
    }
}
