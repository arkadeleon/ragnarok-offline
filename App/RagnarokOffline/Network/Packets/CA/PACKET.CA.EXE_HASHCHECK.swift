//
//  PACKET.CA.EXE_HASHCHECK.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/26.
//

extension PACKET.CA {
    public struct EXE_HASHCHECK: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0204 = 0x0204
        }

        public let packetType: PacketType
        public var hashValue = [UInt8](repeating: 0, count: 16)

        public var packetName: String {
            "PACKET_CA_EXE_HASHCHECK"
        }

        public var packetLength: UInt16 {
            2 + 16
        }

        public init(packetVersion: PacketVersion) {
            packetType = .x0204
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)
            hashValue = try decoder.decode([UInt8].self, length: 16)
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(hashValue)
        }
    }
}
