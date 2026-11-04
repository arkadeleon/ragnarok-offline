//
//  GRF+ProtectedDecoder.swift
//  RagnarokGRF
//
//  Created by Leon Li on 2026/10/29.
//

import CRagnarokGRF
import DataCompression

// Protected entries authenticate the original filename bytes, not a decoded path.
extension GRF {
    enum ProtectedDecoder {
        static let headerSize = 104
        static let maxOutputSize = 256 * 1024 * 1024
        static let maxPackedSize = 258 * 1024 * 1024

        // SHA-256 of "uf8E8qAwHthrLxiS"
        private static let keyBlockDigest: [UInt8] = [
            0x52, 0xf0, 0xd2, 0x65, 0x25, 0x54, 0x0c, 0xd5, 0x5e, 0x2d, 0xa1, 0x3e, 0xe5, 0xc0, 0xdd, 0x3c,
            0x54, 0x7e, 0x56, 0xe2, 0x3a, 0x7b, 0x41, 0x7b, 0x2b, 0x02, 0x83, 0xc1, 0x7b, 0xea, 0x33, 0x94,
        ]

        private static let headerKey: [UInt8] = [
            0x56, 0xfd, 0x7e, 0x71, 0x2f, 0x6d, 0x36, 0xf5, 0x5c, 0xa5, 0x99, 0xe6, 0x7b, 0x18, 0x10, 0x7a,
        ]

        private static let headerIV: [UInt8] = [
            0x4c, 0xe8, 0xa1, 0xae, 0x45, 0xb3, 0x21, 0x60, 0x7e, 0x4f, 0x26, 0xa4, 0xbb, 0x14, 0x0c, 0x96,
        ]

        private static let threeWayHeaderKey: [UInt8] = [
            0xad, 0x61, 0xae, 0xda, 0xbf, 0x20, 0x3e, 0x1d, 0xfe, 0x1d, 0xb7, 0x2b,
        ]

        private static let threeWayHeaderIV: [UInt8] = [
            0xa0, 0x95, 0xdf, 0xcf, 0xd0, 0x4b, 0x74, 0xdb, 0x02, 0x7e, 0xde, 0x09,
        ]

        static func decodeArchiveKeys(_ raw: [UInt8]) throws -> [UInt32 : [UInt8]] {
            if raw.isEmpty {
                return [:]
            }

            guard raw.count >= 20 else {
                throw GRFError.invalidProtectedData("Unsupported or truncated GRF archive key block.")
            }

            let size = Int(raw.littleEndianUInt32(at: 12))
            guard size != 0 && size % 64 == 0 && size / 64 <= 65535 && size == raw.count - 20 else {
                throw GRFError.invalidProtectedData("GRF archive key-block size mismatch.")
            }

            var decoded = Array(raw[20..<(20 + size)])

            if raw[0..<4] != [1, 1, 0, 0] {
                // Falls back to the kRO default keys.
                let keyCount = min(GRF.kRODefaultProtectedKeys.count, decoded.count / 64)
                for i in 0..<keyCount {
                    decoded.setLittleEndianUInt32(UInt32(i + 1), at: 64 * i)
                    decoded.replaceSubrange((64 * i + 4)..<(64 * i + 64), with: GRF.kRODefaultProtectedKeys[UInt32(i + 1)]!)
                }

                guard grf_xxh32(decoded, decoded.count) == raw.littleEndianUInt32(at: 16) else {
                    throw GRFError.invalidProtectedData("Unsupported GRF archive key block.")
                }

                return GRF.kRODefaultProtectedKeys
            }

            try GRF.ProtectedCiphers.decryptChamCBC(&decoded, offset: 0, length: decoded.count, key: Array(keyBlockDigest[0..<16]), iv: Array(keyBlockDigest[16..<32]))
            guard grf_xxh32(decoded, decoded.count) == raw.littleEndianUInt32(at: 16) else {
                throw GRFError.invalidProtectedData("GRF archive key-block checksum mismatch.")
            }

            var keys: [UInt32 : [UInt8]] = [:]
            for offset in stride(from: 0, to: decoded.count, by: 64) {
                let id = decoded.littleEndianUInt32(at: offset)
                guard id != 0 && id <= 65535 && keys[id] == nil else {
                    throw GRFError.invalidProtectedData("Invalid or duplicate GRF archive key-block record.")
                }
                keys[id] = Array(decoded[(offset + 4)..<(offset + 64)])
            }
            return keys
        }

        static func decode(_ payload: [UInt8], rawName: [UInt8], expectedSize: Int, archiveKeys: [UInt32 : [UInt8]]) throws -> [UInt8] {
            guard expectedSize >= 0 && expectedSize <= maxOutputSize else {
                throw GRFError.invalidProtectedData("Protected GRF output size exceeds limit or differs from file table.")
            }

            let nameHash = nativeHash(rawName)
            let header = try decodeHeader(payload, nameHash: nameHash)

            let paddedSize = Int(header.littleEndianUInt32(at: 12))
            let compressedSize = Int(header.littleEndianUInt32(at: 16))
            let outputSize = Int(header.littleEndianUInt32(at: 20))
            guard outputSize == expectedSize && outputSize <= maxOutputSize else {
                throw GRFError.invalidProtectedData("Protected GRF output size exceeds limit or differs from file table.")
            }
            guard paddedSize <= maxPackedSize && paddedSize <= payload.count - headerSize && compressedSize <= paddedSize else {
                throw GRFError.invalidProtectedData("Protected GRF body size lies outside payload or exceeds limit.")
            }

            let cipher = Int(header[8]) | Int(header[9]) << 8
            guard [1, 5, 7, 128, 133].contains(cipher) else {
                throw GRFError.invalidProtectedData("Unsupported protected GRF body cipher \(cipher).")
            }

            let compression = header[10]
            guard compression <= 2 else {
                throw GRFError.invalidProtectedData("Unsupported protected GRF compression \(compression).")
            }

            guard header[11] & ~1 == 0 else {
                throw GRFError.invalidProtectedData("Unsupported protected GRF parameter flags \(header[11]).")
            }

            let keyID = header.littleEndianUInt32(at: 40)
            let material: [UInt8]
            if keyID == 0 {
                material = Array(header[44..<104])
            } else if keyID <= 65535, let key = archiveKeys[keyID], key.count == 60 {
                material = key
            } else {
                throw GRFError.missingProtectedKey(keyID)
            }

            let outputHash = Array(header[24..<40])
            var parameters = [UInt8](repeating: 0, count: 64)
            for i in 0..<60 {
                parameters[i] = material[i] ^ (header[11] & 1 != 0 ? outputHash[i % 16] : 0)
            }

            var body = Array(payload[headerSize..<(headerSize + paddedSize)])
            if compressedSize > 128 {
                switch cipher {
                case 1:
                    let seededNameHash = nativeHash(rawName, seed: UInt64(expectedSize))
                    try GRF.ProtectedCiphers.decryptChamTail(parameters: parameters, seededNameHash: seededNameHash, outputHash: outputHash, data: &body, offset: 128)
                case 5, 7:
                    try GRF.ProtectedCiphers.decryptLegacyTail(cipher: cipher, parameters: parameters, filenameHash: nameHash, outputHash: outputHash, data: &body, offset: 128, compressedLength: compressedSize - 128)
                default:
                    try GRF.ProtectedCiphers.decryptBodyTail(cipher: cipher, parameters: parameters, filenameHash: nameHash, outputHash: outputHash, data: &body, offset: 128)
                }
            }

            let output: [UInt8]
            switch compression {
            case 0:
                guard compressedSize == expectedSize else {
                    throw GRFError.invalidProtectedData("Protected GRF stored output size mismatch.")
                }
                output = Array(body.prefix(expectedSize))
            case 1:
                guard let result = try? Zlib.inflate(Array(body.prefix(compressedSize)), capacity: expectedSize),
                      result.consumed == compressedSize && result.data.count == expectedSize else {
                    throw GRFError.invalidProtectedData("Invalid protected GRF zlib stream: truncated, checksum failed or size differs.")
                }
                output = result.data
            default:
                output = try decodeLZ4(body, compressedSize: compressedSize, expectedSize: expectedSize)
            }

            guard nativeHash(output) == outputHash else {
                throw GRFError.invalidProtectedData("Protected GRF output hash mismatch.")
            }

            return output
        }

        private static func decodeHeader(_ payload: [UInt8], nameHash: [UInt8]) throws -> [UInt8] {
            guard payload.count >= headerSize && payload[0] == 1 else {
                throw GRFError.invalidProtectedData("Unsupported or truncated protected GRF header.")
            }

            var header = Array(payload[0..<headerSize])
            switch header[1] {
            case 1, 2, 15:
                let iv = switch header[1] {
                case 1: headerIV
                case 2: nameHash
                default: nativeHash(Array(header[4..<8]))
                }
                try AES.decryptCBC(&header, offset: 8, length: 96, key: headerKey, iv: iv)
            case 113:
                try GRF.ProtectedCiphers.decryptThreeWayCFB(&header, offset: 8, length: 96, key: threeWayHeaderKey, iv: threeWayHeaderIV)
            default:
                throw GRFError.invalidProtectedData("Unsupported protected GRF header type \(header[1]).")
            }

            guard grf_xxh32(Array(header[8..<104]), 96) == header.littleEndianUInt32(at: 4) else {
                throw GRFError.invalidProtectedData("Protected GRF header checksum mismatch.")
            }

            return header
        }

        private static func decodeLZ4(_ body: [UInt8], compressedSize: Int, expectedSize: Int) throws -> [UInt8] {
            guard compressedSize >= 0, compressedSize <= body.count,
                  let output = try? LZ4.decompress(Array(body.prefix(compressedSize)), expectedSize: expectedSize) else {
                throw GRFError.invalidProtectedData("Invalid protected GRF LZ4 stream or output size mismatch.")
            }
            return output
        }

        /// XXH3-128 with low64 then high64, both little-endian, as stored in protected entries.
        static func nativeHash(_ data: [UInt8], seed: UInt64 = 0) -> [UInt8] {
            var hash = [UInt8](repeating: 0, count: 16)
            grf_xxh3_128(data, data.count, seed, &hash)
            return hash
        }
    }
}
