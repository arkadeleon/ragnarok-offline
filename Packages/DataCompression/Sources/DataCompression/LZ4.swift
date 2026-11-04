//
//  LZ4.swift
//  DataCompression
//
//  Created by Leon Li on 2026/11/4.
//

import Compression

public enum LZ4 {
    /// Decompresses a raw LZ4 block with an exact expected output size.
    public static func decompress(_ bytes: [UInt8], expectedSize: Int) throws -> [UInt8] {
        guard expectedSize >= 0, !bytes.isEmpty else {
            throw DecompressionError.invalidData
        }
        if expectedSize == 0 {
            guard bytes == [0] else {
                throw DecompressionError.invalidData
            }
            return []
        }
        var output = [UInt8](repeating: 0, count: expectedSize)
        let written = bytes.withUnsafeBufferPointer { source in
            output.withUnsafeMutableBufferPointer { destination in
                compression_decode_buffer(destination.baseAddress!, destination.count,
                                          source.baseAddress!, source.count, nil, COMPRESSION_LZ4_RAW)
            }
        }
        guard written == expectedSize else {
            throw DecompressionError.invalidData
        }
        return output
    }
}
