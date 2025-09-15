//
//  StreamReader.swift
//  BinaryIO
//
//  Created by Leon Li on 2024/9/6.
//

import Foundation

public class StreamReader {
    public let stream: any Stream
    public let delimiter: String

    public let encoding: String.Encoding = .isoLatin1

    private let bufferSize = 4096
    private var buffer: [UInt8]
    private var decodedString = ""

    private var endOfStream = false

    public init(stream: any Stream, delimiter: String = "\n") {
        self.stream = stream
        self.delimiter = delimiter

        buffer = [UInt8](repeating: 0, count: bufferSize)
    }

    public func close() {
        stream.close()
    }

    public func readLine() -> String? {
        while !endOfStream {
            if let range = decodedString.firstRange(of: delimiter) {
                let line = decodedString[..<range.lowerBound]
                decodedString.removeSubrange(..<range.upperBound)
                return String(line)
            }

            var bufferLength = 0
            try? buffer.withUnsafeMutableBytes { pointer in
                bufferLength = try stream.read(pointer.baseAddress!, count: bufferSize)
            }

            if bufferLength > 0 {
                if let string = String(bytes: buffer[0..<bufferLength], encoding: encoding) {
                    decodedString.append(string)
                }
            } else {
                endOfStream = true
                if !decodedString.isEmpty {
                    let line = decodedString
                    decodedString = ""
                    return line
                }
            }
        }
        return nil
    }
}
