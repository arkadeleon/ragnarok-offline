//
//  PACKET.AC.ACCEPT_LOGIN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

extension PACKET.AC {
    public struct ACCEPT_LOGIN: DecodablePacket {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0069 = 0x0069
            case x0ac4 = 0x0ac4
        }

        public static var packetType: PacketType {
            if PACKET_VERSION < 20170315 {
                .x0069
            } else {
                .x0ac4
            }
        }

        public var authCode: UInt32
        public var aid: UInt32
        public var userLevel: UInt32
        public var lastLoginIP: UInt32
        public var lastLoginTime: String
        public var sex: UInt8
        public var token: [UInt8]
        public var serverList: [ServerInfo]

        public var packetName: String {
            "PACKET_AC_ACCEPT_LOGIN"
        }

        public var packetLength: UInt16 {
            2 + 2 + 4 + 4 + 4 + 4 + 26 + 1 + ServerInfo.size * UInt16(serverList.count)
        }

        public init(from decoder: BinaryDecoder) throws {
            let packetType = try decoder.decode(PacketType.self)

            let packetLength = try decoder.decode(UInt16.self)
            let serverCount = (packetLength - 2 - 2 - 4 - 4 - 4 - 4 - 26 - 1) / ServerInfo.size

            authCode = try decoder.decode(UInt32.self)
            aid = try decoder.decode(UInt32.self)
            userLevel = try decoder.decode(UInt32.self)
            lastLoginIP = try decoder.decode(UInt32.self)
            lastLoginTime = try decoder.decode(String.self, length: 26)
            sex = try decoder.decode(UInt8.self)

            if packetType == .x0ac4 {
                token = try decoder.decode([UInt8].self, length: 17)
            } else {
                token = []
            }

            serverList = []
            for _ in 0..<serverCount {
                let serverInfo = try decoder.decode(ServerInfo.self)
                serverList.append(serverInfo)
            }
        }
    }
}

extension PACKET.AC.ACCEPT_LOGIN {
    public struct ServerInfo: BinaryDecodable {
        public static var size: UInt16 {
            switch PACKET.AC.ACCEPT_LOGIN.packetType {
            case .x0069: 32
            case .x0ac4: 32 + 128
            }
        }

        public var ip: UInt32
        public var port: UInt16
        public var name: String
        public var userCount: UInt16
        public var state: UInt16
        public var property: UInt16

        public init(from decoder: BinaryDecoder) throws {
            ip = try decoder.decode(UInt32.self)
            port = try decoder.decode(UInt16.self)
            name = try decoder.decode(String.self, length: 20)
            userCount = try decoder.decode(UInt16.self)
            state = try decoder.decode(UInt16.self)
            property = try decoder.decode(UInt16.self)

            if PACKET.AC.ACCEPT_LOGIN.packetType == .x0ac4 {
                _ = try decoder.decode([UInt8].self, length: 128)
            }
        }
    }
}
