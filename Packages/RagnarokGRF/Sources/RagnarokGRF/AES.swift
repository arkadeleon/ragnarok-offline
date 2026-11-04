//
//  AES.swift
//  RagnarokGRF
//
//  Created by Leon Li on 2026/11/4.
//

import CommonCrypto

/// AES-128 CBC without padding; protected GRF validates its own padding.
enum AES {
    static func decryptCBC(_ data: inout [UInt8], offset: Int, length: Int, key: [UInt8], iv: [UInt8]) throws {
        guard offset >= 0, length >= 0, offset <= data.count,
              length <= data.count - offset, length % kCCBlockSizeAES128 == 0,
              key.count == kCCKeySizeAES128, iv.count == kCCBlockSizeAES128 else {
            throw GRFError.invalidProtectedData("Invalid protected GRF AES block.")
        }
        if length == 0 {
            return
        }
        var output = [UInt8](repeating: 0, count: length)
        var written = 0
        let status = key.withUnsafeBytes { keyBuffer in
            iv.withUnsafeBytes { ivBuffer in
                data.withUnsafeBytes { source in
                    output.withUnsafeMutableBytes { destination in
                        CCCrypt(CCOperation(kCCDecrypt), CCAlgorithm(kCCAlgorithmAES), 0,
                                keyBuffer.baseAddress, key.count, ivBuffer.baseAddress,
                                source.baseAddress!.advanced(by: offset), length,
                                destination.baseAddress, length, &written)
                    }
                }
            }
        }
        guard status == kCCSuccess, written == length else {
            throw GRFError.invalidProtectedData("Protected GRF AES decryption failed: \(status).")
        }
        data.replaceSubrange(offset..<(offset + length), with: output)
    }
}
