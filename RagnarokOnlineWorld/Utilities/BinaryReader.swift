//
//  BinaryReader.swift
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

    func offset() throws -> UInt64
    func seek(toOffset offset: UInt64) throws
    func read(upToCount count: Int) throws -> Data
    func readToEnd() throws -> Data
}

class FileStream: Stream {

    private let fileHandle: FileHandle

    init(url: URL) throws {
        fileHandle = try FileHandle(forReadingFrom: url)
    }

    deinit {
        try? fileHandle.close()
    }

    func offset() throws -> UInt64 {
        return try fileHandle.offset()
    }

    func seek(toOffset offset: UInt64) throws {
        try fileHandle.seek(toOffset: offset)
    }

    func read(upToCount count: Int) throws -> Data {
        guard let data = try fileHandle.read(upToCount: count) else {
            throw StreamError.endOfStream
        }
        return data
    }

    func readToEnd() throws -> Data {
        guard let data = try fileHandle.readToEnd() else {
            throw StreamError.endOfStream
        }
        return data
    }
}

class DataStream: Stream {
    
    private let data: Data
    private var dataOffset = 0

    init(data: Data) {
        self.data = data
    }

    func offset() throws -> UInt64 {
        return UInt64(dataOffset)
    }

    func seek(toOffset offset: UInt64) throws {
        guard offset <= data.count else {
            throw StreamError.endOfStream
        }
        self.dataOffset = Int(offset)
    }

    func read(upToCount count: Int) throws -> Data {
        guard dataOffset + count <= data.count else {
            throw StreamError.endOfStream
        }
        let data = Data(self.data[dataOffset..<(dataOffset + count)])
        dataOffset += count
        return data
    }

    func readToEnd() throws -> Data {
        let data = Data(self.data[dataOffset...])
        dataOffset += data.count
        return data
    }
}

class BinaryReader {

    let stream: Stream

    init(stream: Stream) {
        self.stream = stream
    }

    func skip(count: UInt64) throws {
        let offset = try stream.offset()
        try stream.seek(toOffset: offset + count)
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

    func readString(count: Int, encoding: UInt = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue))) throws -> String {
        let data = try stream.read(upToCount: count).prefix { $0 != 0 }
        guard let string = NSString(data: data, encoding: encoding) else {
            throw StreamError.invalidStringEncoding
        }
        return string as String
    }
}
