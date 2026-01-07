//
//  PACKET_HC_BLOCK_CHARACTER.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/12.
//

import BinaryIO

@available(*, deprecated, message: "Use HEADER_HC_BLOCK_CHARACTER instead.")
public let _HEADER_HC_BLOCK_CHARACTER: Int16 = 0x20d

/// See `chclif_block_character`
@available(*, deprecated, message: "Use PACKET_HC_BLOCK_CHARACTER instead.")
public struct _PACKET_HC_BLOCK_CHARACTER: DecodablePacket {
    public var packetType: Int16
    public var packetLength: Int16
    public var chars: [_CharBlockInfo]

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        packetLength = try decoder.decode(Int16.self)

        let charCount = (packetLength - 4) / _CharBlockInfo.decodedLength

        chars = []
        for _ in 0..<charCount {
            let charBlockInfo = try _CharBlockInfo(from: decoder)
            chars.append(charBlockInfo)
        }
    }
}

extension _PACKET_HC_BLOCK_CHARACTER {
    public struct _CharBlockInfo: BinaryDecodable, Sendable {
        public var charID: UInt32
        public var szExpireDate: String

        public init(from decoder: BinaryDecoder) throws {
            charID = try decoder.decode(UInt32.self)
            szExpireDate = try decoder.decode(String.self, lengthOfBytes: 20)
        }
    }
}
