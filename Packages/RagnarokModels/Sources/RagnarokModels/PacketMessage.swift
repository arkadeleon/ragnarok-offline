//
//  PacketMessage.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/1/19.
//

import Foundation
import RagnarokPackets

public struct PacketMessage: Identifiable, Sendable {
    public enum Direction: Sendable {
        case outgoing
        case incoming
    }

    public let id: UUID
    public let packet: any PacketProtocol
    public let direction: PacketMessage.Direction

    public init(packet: any PacketProtocol, direction: PacketMessage.Direction) {
        self.id = UUID()
        self.packet = packet
        self.direction = direction
    }
}
