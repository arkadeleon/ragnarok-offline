//
//  PacketMessage.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/1/19.
//

import Foundation
import RagnarokPackets

public struct PacketMessage: Identifiable, Sendable {
    public let id: UUID
    public let packet: any PacketProtocol

    public init(packet: any PacketProtocol) {
        self.id = UUID()
        self.packet = packet
    }
}
