//
//  PACKET.CH.SELECT_ACCESSIBLE_MAPNAME.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/9.
//

extension PACKET.CH {
    public struct SELECT_ACCESSIBLE_MAPNAME: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0841 = 0x0841
        }

        public let packetType: PacketType
        public var slot: UInt8 = 0
        public var mapNumber: UInt8 = 0

        public var packetName: String {
            "PACKET_CH_SELECT_ACCESSIBLE_MAPNAME"
        }

        public var packetLength: UInt16 {
            2 + 1 + 1
        }

        public init(packetVersion: PacketVersion) {
            packetType = .x0841
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)
            slot = try decoder.decode(UInt8.self)
            mapNumber = try decoder.decode(UInt8.self)
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(slot)
            try encoder.encode(mapNumber)
        }
    }
}
