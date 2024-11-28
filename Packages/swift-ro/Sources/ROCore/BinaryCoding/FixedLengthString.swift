//
//  FixedLengthString.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/10.
//

import Foundation

@propertyWrapper
public struct FixedLengthString: Sendable {
    public let lengthOfBytes: Int
    public let encoding: String.Encoding

    private var _bytes: [UInt8] = []
    public var wrappedValue: String {
        get {
            String(bytes: _bytes, encoding: encoding) ?? ""
        }
        set {
            guard let bytes = newValue.data(using: encoding) else {
                return
            }
            if bytes.count >= lengthOfBytes {
                _bytes = Array(bytes[0..<lengthOfBytes])
            } else {
                _bytes = Array(bytes) + Array(repeating: 0, count: lengthOfBytes - bytes.count)
            }
        }
    }

    public init(lengthOfBytes: Int, encoding: String.Encoding = .ascii) {
        self.lengthOfBytes = lengthOfBytes
        self.encoding = encoding
    }
}

extension FixedLengthString: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        wrappedValue
    }

    public var debugDescription: String {
        wrappedValue
    }
}
