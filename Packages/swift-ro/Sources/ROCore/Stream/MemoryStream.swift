//
//  MemoryStream.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/7/21.
//

import Foundation

public class MemoryStream: Stream {
    fileprivate var storage: UnsafeMutableRawPointer
    private var capacity: Int

    public private(set) var length: Int
    public private(set) var position: Int

    public init() {
        storage = UnsafeMutableRawPointer.allocate(byteCount: 0, alignment: MemoryLayout<UInt>.alignment)
        capacity = 0
        length = 0
        position = 0
    }

    public init(data: Data) {
        storage = UnsafeMutableRawPointer.allocate(byteCount: data.count, alignment: MemoryLayout<UInt>.alignment)
        capacity = data.count
        length = data.count
        position = 0

        data.withUnsafeBytes { pointer in
            let target = UnsafeMutableRawBufferPointer(start: storage, count: pointer.count)
            target.copyMemory(from: pointer)
        }
    }

    deinit {
        storage.deallocate()
    }

    public func close() {
    }

    public func seek(_ offset: Int, origin: SeekOrigin) throws {
        var position: Int

        switch origin {
        case .begin: position = offset
        case .current: position = self.position + offset
        case .end: position = length + offset
        }

        switch position {
        case 0...length: self.position = position
        default: throw StreamError.invalidSeekOffset
        }
    }

    public func read(_ buffer: UnsafeMutableRawPointer, count: Int) throws -> Int {
        let count = min(count, length - position)

        buffer.copyMemory(from: storage.advanced(by: position), byteCount: count)

        position += count

        return count
    }

    public func write(_ buffer: UnsafeRawPointer, count: Int) throws -> Int {
        length += count
        ensureCapacity(length)

        storage.advanced(by: position).copyMemory(from: buffer, byteCount: count)

        position += count

        return count
    }

    private func ensureCapacity(_ capacity: Int) {
        guard capacity > self.capacity else {
            return
        }

        var newCapacity = 256
        while newCapacity < capacity {
            newCapacity <<= 1
        }

        let storage = UnsafeMutableRawPointer.allocate(byteCount: newCapacity, alignment: MemoryLayout<UInt>.alignment)
        storage.copyMemory(from: self.storage, byteCount: self.capacity)
        self.storage.deallocate()
        self.storage = storage
        self.capacity = newCapacity
    }
}

extension Data {
    public init(stream: MemoryStream) {
        self = Data(bytes: stream.storage, count: stream.length)
    }
}
