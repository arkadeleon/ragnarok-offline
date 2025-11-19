//
//  Array+Replacements.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2025/11/19.
//

import Foundation

extension Array where Element == UInt8 {
    @inlinable mutating func replaceSubrange(from lowerBound: Int, with integer: some FixedWidthInteger) {
        let subrange = lowerBound..<(lowerBound + integer.bitWidth / 8)
        let bytes = Swift.withUnsafeBytes(of: integer, [UInt8].init)
        replaceSubrange(subrange, with: bytes)
    }

    @inlinable mutating func replaceSubrange(from lowerBound: Int, with bytes: [UInt8]) {
        let subrange = lowerBound..<(lowerBound + bytes.count)
        replaceSubrange(subrange, with: bytes)
    }

    @inlinable mutating func replaceSubrange(from lowerBound: Int, with data: Data) {
        let subrange = lowerBound..<(lowerBound + data.count)
        replaceSubrange(subrange, with: data)
    }
}
