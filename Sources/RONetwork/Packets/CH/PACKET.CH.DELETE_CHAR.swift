//
//  PACKET.CH.DELETE_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

extension PACKET.CH {
    public struct DELETE_CHAR: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0068 = 0x0068
            case x01fb = 0x01fb
        }

        public let packetType: PacketType
        public var gid: UInt32 = 0
        public var key = ""

        public var packetName: String {
            "PACKET_CH_DELETE_CHAR"
        }

        public var packetLength: UInt16 {
            switch packetType {
            case .x0068: 
                2 + 4 + 40
            case .x01fb: 
                2 + 4 + 50
            }
        }

        public init(packetVersion: PacketVersion) {
            if packetVersion.number <= 20100803 {
                packetType = .x0068
            } else {
                packetType = .x01fb
            }
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)
            gid = try decoder.decode(UInt32.self)

            switch packetType {
            case .x0068:
                key = try decoder.decode(String.self, length: 40)
            case .x01fb:
                key = try decoder.decode(String.self, length: 50)
            }
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(gid)

            switch packetType {
            case .x0068:
                try encoder.encode(key, length: 40)
            case .x01fb:
                try encoder.encode(key, length: 50)
            }
        }
    }
}
