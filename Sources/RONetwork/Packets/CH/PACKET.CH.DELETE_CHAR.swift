//
//  PACKET.CH.DELETE_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

extension PACKET.CH {
    public struct DELETE_CHAR: EncodablePacket {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0068 = 0x0068
            case x01fb = 0x01fb
        }

        public static var packetType: PacketType {
            if PACKET_VERSION <= 20100803 {
                .x0068
            } else {
                .x01fb
            }
        }

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
