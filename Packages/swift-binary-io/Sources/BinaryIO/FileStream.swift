//
//  FileStream.swift
//  BinaryIO
//
//  Created by Leon Li on 2023/8/2.
//

import Foundation

public class FileStream: Stream {
    private let file: UnsafeMutablePointer<FILE>

    public private(set) var length: Int

    public var position: Int {
        ftell(file)
    }

    public init?(url: URL) {
        guard let file = fopen(url.path.cString(using: .utf8), "rw+") else {
            return nil
        }

        self.file = file

        fseek(file, 0, SEEK_END)
        self.length = ftell(file)
        fseek(file, 0, SEEK_SET)
    }

    public func close() {
        fclose(file)
    }

    public func seek(_ offset: Int, origin: SeekOrigin) throws {
        fseek(file, offset, origin.rawValue)
    }

    public func read(_ buffer: UnsafeMutableRawPointer, count: Int) throws -> Int {
        return fread(buffer, 1, count, file)
    }

    public func write(_ buffer: UnsafeRawPointer, count: Int) throws -> Int {
        return fwrite(buffer, 1, count, file)
    }
}
