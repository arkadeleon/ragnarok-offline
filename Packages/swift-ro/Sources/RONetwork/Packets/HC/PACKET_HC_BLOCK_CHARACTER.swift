//
//  PACKET_HC_BLOCK_CHARACTER.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

/// See `chclif_block_character`
public struct PACKET_HC_BLOCK_CHARACTER: DecodablePacket {
    public static var packetType: UInt16 {
        0x20d
    }

    public var packetLength: UInt16 {
        4 + 24 * UInt16(characterList.count)
    }

    public var characterList: [CharacterInfo]

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        let packetLength = try decoder.decode(UInt16.self)

        let characterCount = (packetLength - 4) / 24

        characterList = []
        for _ in 0..<characterCount {
            let characterInfo = try CharacterInfo(from: decoder)
            characterList.append(characterInfo)
        }
    }
}

extension PACKET_HC_BLOCK_CHARACTER {
    public struct CharacterInfo: BinaryDecodable {
        public var gid: UInt32
        public var szExpireDate: String

        public init(from decoder: BinaryDecoder) throws {
            gid = try decoder.decode(UInt32.self)
            szExpireDate = try decoder.decode(String.self, length: 20)
        }
    }
}
