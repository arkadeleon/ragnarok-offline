//
//  Zlib.swift
//  DataCompression
//
//  Created by Leon Li on 2026/11/4.
//

import zlib

public enum Zlib {
    public struct Result: Sendable {
        public let data: [UInt8]
        public let consumed: Int
    }

    /// Inflates a zlib or gzip stream, ignoring bytes after its end.
    /// The initial output capacity grows as needed.
    public static func inflate(_ bytes: [UInt8], capacity: Int = 262144) throws -> Result {
        guard bytes.count <= Int(UInt32.max) else {
            throw DecompressionError.invalidData
        }
        var capacity = max(capacity, 1)
        while true {
            guard capacity <= Int(UInt32.max) else {
                throw DecompressionError.invalidData
            }
            var stream = z_stream()
            guard inflateInit2_(&stream, MAX_WBITS + 32, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size)) == Z_OK else {
                throw DecompressionError.invalidData
            }
            defer {
                inflateEnd(&stream)
            }
            var output = [UInt8](repeating: 0, count: capacity)
            let status = bytes.withUnsafeBytes { source in
                output.withUnsafeMutableBytes { destination in
                    stream.next_in = UnsafeMutablePointer(mutating: source.bindMemory(to: UInt8.self).baseAddress)
                    stream.avail_in = UInt32(bytes.count)
                    stream.next_out = destination.bindMemory(to: UInt8.self).baseAddress
                    stream.avail_out = UInt32(capacity)
                    return zlib.inflate(&stream, Z_FINISH)
                }
            }
            if status == Z_STREAM_END {
                output.removeLast(capacity - Int(stream.total_out))
                return Result(data: output, consumed: Int(stream.total_in))
            }
            guard (status == Z_OK || status == Z_BUF_ERROR) && stream.avail_out == 0 else {
                throw DecompressionError.invalidData
            }
            capacity *= 2
        }
    }
}
