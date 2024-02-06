//
//  Stream.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/7/21.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

enum StreamError: Error {
    case invalidURL
    case invalidEncoding
    case invalidSeekOffset
}

enum SeekOrigin: Int32 {
    case begin
    case current
    case end
}

protocol Stream {
    var length: Int { get }

    var position: Int { get }

    func close()

    func seek(_ offset: Int, origin: SeekOrigin) throws

    func read(_ buffer: UnsafeMutableRawPointer, count: Int) throws -> Int

    func write(_ buffer: UnsafeRawPointer, count: Int) throws -> Int
}
