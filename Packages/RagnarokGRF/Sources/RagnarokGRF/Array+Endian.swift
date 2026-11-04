//
//  Array+Endian.swift
//  RagnarokGRF
//
//  Created by Leon Li on 2026/10/30.
//

extension Array where Element == UInt8 {
    func littleEndianUInt32(at offset: Int) -> UInt32 {
        withUnsafeBytes {
            UInt32(littleEndian: $0.loadUnaligned(fromByteOffset: offset, as: UInt32.self))
        }
    }

    func littleEndianUInt64(at offset: Int) -> UInt64 {
        withUnsafeBytes {
            UInt64(littleEndian: $0.loadUnaligned(fromByteOffset: offset, as: UInt64.self))
        }
    }

    func bigEndianUInt32(at offset: Int) -> UInt32 {
        withUnsafeBytes {
            UInt32(bigEndian: $0.loadUnaligned(fromByteOffset: offset, as: UInt32.self))
        }
    }

    mutating func setLittleEndianUInt32(_ value: UInt32, at offset: Int) {
        withUnsafeMutableBytes {
            $0.storeBytes(of: value.littleEndian, toByteOffset: offset, as: UInt32.self)
        }
    }

    mutating func setBigEndianUInt32(_ value: UInt32, at offset: Int) {
        withUnsafeMutableBytes {
            $0.storeBytes(of: value.bigEndian, toByteOffset: offset, as: UInt32.self)
        }
    }
}
