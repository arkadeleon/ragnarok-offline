//
//  PacketRegistration.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/27.
//

protocol PacketRegistration {
    associatedtype Packet: DecodablePacket

    var packetType: Int16 { get }
    var handler: (Packet) -> Void { get }

    func handlePacket(_ packet: any DecodablePacket)
}

struct _PacketRegistration<P>: PacketRegistration where P: DecodablePacket {
    var packetType: Int16
    var handler: (P) -> Void

    func handlePacket(_ packet: any DecodablePacket) {
        if let packet = packet as? P {
            handler(packet)
        }
    }
}
