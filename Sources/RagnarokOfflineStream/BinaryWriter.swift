//
//  BinaryWriter.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/7/21.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Foundation

public class BinaryWriter {
    public let stream: Stream

    public init(stream: Stream) {
        self.stream = stream
    }

    public func close() {
        stream.close()
    }

    public func write<T: FixedWidthInteger>(_ value: T) throws {
        let count = MemoryLayout<T>.size
        var value = value
        try withUnsafePointer(to: &value) { pointer in
            _ = try stream.write(pointer, count: count)
        }
    }

    public func write<T: FloatingPoint>(_ value: T) throws {
        let count = MemoryLayout<T>.size
        var value = value
        try withUnsafePointer(to: &value) { pointer in
            _ = try stream.write(pointer, count: count)
        }
    }

    public func write(_ value: [UInt8]) throws {
        _ = try stream.write(value, count: value.count)
    }

    public func write(_ value: String, encoding: String.Encoding) throws {
        guard let data = value.data(using: encoding) else {
            throw StreamError.invalidEncoding
        }
        try data.withUnsafeBytes { pointer in
            _ = try stream.write(pointer.baseAddress!, count: pointer.count)
        }
    }
}
