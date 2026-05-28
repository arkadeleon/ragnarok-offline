//
//  GRFStream.swift
//  RagnarokGRF
//
//  Created by Leon Li on 2026/5/28.
//

import Foundation

enum GRFStreamSeekOrigin: Int32 {
    case begin = 0
    case current = 1
    case end = 2
}

final class GRFStream {
    private let file: UnsafeMutablePointer<FILE>

    let length: Int

    var position: Int {
        ftell(file)
    }

    var bytesRemaining: Int {
        length - position
    }

    init?(forReadingFrom url: URL) {
        guard let file = fopen(url.path.cString(using: .utf8), "r") else {
            return nil
        }

        self.file = file

        fseek(file, 0, SEEK_END)
        self.length = ftell(file)
        fseek(file, 0, SEEK_SET)
    }

    func close() {
        fclose(file)
    }

    func seek(_ offset: Int, origin: GRFStreamSeekOrigin) {
        fseek(file, offset, origin.rawValue)
    }

    func read(count: Int) throws -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: count)
        _ = bytes.withUnsafeMutableBytes {
            fread($0.baseAddress, 1, count, file)
        }
        return bytes
    }

    func read<T>(_ type: T.Type) throws -> T where T: FixedWidthInteger {
        let bytes = try read(count: MemoryLayout<T>.size)
        let value = bytes.withUnsafeBytes {
            $0.loadUnaligned(as: T.self)
        }
        return T(littleEndian: value)
    }
}
