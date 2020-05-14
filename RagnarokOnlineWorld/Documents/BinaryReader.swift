//
//  StreamReader.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/11.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

enum StreamError: Error {

    case endOfStream

    case invalidStringEncoding
}

protocol Stream {

    func seek(toOffset offset: Int) throws

    func read(upToCount count: Int) throws -> Data
}

class FileStream: Stream {
    private let fileHandle: FileHandle

    init(url: URL) throws {
        fileHandle = try FileHandle(forReadingFrom: url)
    }

    deinit {
        try? fileHandle.close()
    }

    func seek(toOffset offset: Int) throws {
        try fileHandle.seek(toOffset: UInt64(offset))
    }

    func read(upToCount count: Int) throws -> Data {
        guard let data = try fileHandle.read(upToCount: count) else {
            throw StreamError.endOfStream
        }
        return data
    }
}

class DataStream: Stream {
    private let data: Data
    private var offset = 0

    init(data: Data) {
        self.data = data
    }

    func seek(toOffset offset: Int) throws {
        self.offset = offset
    }

    func read(upToCount count: Int) throws -> Data {
        guard offset + count <= data.count else {
            throw StreamError.endOfStream
        }
        let data = Data(self.data[offset..<(offset + count)])
        offset += count
        return data
    }
}

class BinaryReader {

    let stream: Stream

    init(stream: Stream) {
        self.stream = stream
    }

    func readInt8() throws -> Int8 {
        let data = try stream.read(upToCount: 1)
        return data.withUnsafeBytes { $0.load(as: Int8.self) }
    }

    func readUInt8() throws -> UInt8 {
        let data = try stream.read(upToCount: 1)
        return data.withUnsafeBytes { $0.load(as: UInt8.self) }
    }

    func readInt16() throws -> Int16 {
        let data = try stream.read(upToCount: 2)
        return data.withUnsafeBytes { $0.load(as: Int16.self) }
    }

    func readUInt16() throws -> UInt16 {
        let data = try stream.read(upToCount: 2)
        return data.withUnsafeBytes { $0.load(as: UInt16.self) }
    }

    func readInt32() throws -> Int32 {
        let data = try stream.read(upToCount: 4)
        return data.withUnsafeBytes { $0.load(as: Int32.self) }
    }

    func readUInt32() throws -> UInt32 {
        let data = try stream.read(upToCount: 4)
        return data.withUnsafeBytes { $0.load(as: UInt32.self) }
    }

    func readFloat32() throws -> Float32 {
        let data = try stream.read(upToCount: 4)
        return data.withUnsafeBytes { $0.load(as: Float32.self) }
    }

    func readFloat64() throws -> Float64 {
        let data = try stream.read(upToCount: 8)
        return data.withUnsafeBytes { $0.load(as: Float64.self) }
    }

    func readData(count: Int) throws -> Data {
        let data = try stream.read(upToCount: count)
        return data
    }

    func readString(count: Int, encoding: UInt = String.Encoding.ascii.rawValue) throws -> String {
        let data = try stream.read(upToCount: count)
        guard let string = NSString(data: data, encoding: encoding) else {
            throw StreamError.invalidStringEncoding
        }
        return string as String
    }
}
