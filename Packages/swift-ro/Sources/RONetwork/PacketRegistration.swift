//
//  PacketRegistration.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/27.
//

protocol PacketRegistration {
    associatedtype Packet: DecodablePacket

    var type: Packet.Type { get }
    var handler: (Packet) -> Void { get }

    func handlePacket(_ packet: any DecodablePacket)
}

struct _PacketRegistration<Packet>: PacketRegistration where Packet: DecodablePacket {
    var type: Packet.Type
    var handler: (Packet) -> Void

    func handlePacket(_ packet: any DecodablePacket) {
        if let packet = packet as? Packet {
            handler(packet)
        }
    }
}
