//
//  PACKET_ZC_FRIENDS_LIST.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

import ROCore

/// See `clif_friendslist_send`
public struct PACKET_ZC_FRIENDS_LIST: DecodablePacket {
    public static var packetType: Int16 {
        0x201
    }

    public var packetLength: Int16 {
        -1
    }

    public var friends: [FriendInfo]

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        let packetLength = try decoder.decode(Int16.self)

        let friendCount = (packetLength - 4) / FriendInfo.decodedLength

        friends = []
        for _ in 0..<friendCount {
            let friendInfo = try FriendInfo(from: decoder)
            friends.append(friendInfo)
        }
    }
}

extension PACKET_ZC_FRIENDS_LIST {
    public struct FriendInfo: BinaryDecodable {
        public var accountID: UInt32
        public var charID: UInt32
        public var name: String

        public init(from decoder: BinaryDecoder) throws {
            accountID = try decoder.decode(UInt32.self)
            charID = try decoder.decode(UInt32.self)

            if !(PACKET_VERSION_MAIN_NUMBER >= 20180307 || PACKET_VERSION_RE_NUMBER >= 20180221 || PACKET_VERSION_ZERO_NUMBER >= 20180328) || PACKET_VERSION >= 20200902 {
                name = try decoder.decodeString(24)
            } else {
                name = ""
            }
        }
    }
}
