//
//  PACKET.CH.EXE_HASHCHECK.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/26.
//

extension PACKET.CH {
    public struct EXE_HASHCHECK: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x020b = 0x020b
        }

        public let packetType: PacketType
        public var clientType: UInt8 = 0
        public var hashValue = [UInt8](repeating: 0, count: 16)

        public var packetName: String {
            "PACKET_CH_EXE_HASHCHECK"
        }

        public var packetLength: UInt16 {
            2 + 1 + 16
        }

        public init(packetVersion: PacketVersion) {
            packetType = .x020b
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)
            clientType = try decoder.decode(UInt8.self)
            hashValue = try decoder.decode([UInt8].self, length: 16)
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(clientType)
            try encoder.encode(hashValue)
        }
    }
}
