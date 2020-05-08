//
//  FileHandle+Reading.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/2.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

extension FileHandle {

    func readBytes(_ count: Int) throws -> [UInt8] {
        let bytes = readData(ofLength: count)
        guard bytes.count == count else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: nil)
        }
        return Array(bytes)
    }

    func readUInt32() throws -> UInt32 {
        let bytes = readData(ofLength: 4)
        guard bytes.count == 4 else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: nil)
        }
        return bytes.withUnsafeBytes { $0.load(as: UInt32.self) }
    }
}
