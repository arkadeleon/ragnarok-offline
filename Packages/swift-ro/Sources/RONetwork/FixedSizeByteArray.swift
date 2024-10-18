//
//  FixedSizeByteArray.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/18.
//

import Foundation

@propertyWrapper
public struct FixedSizeByteArray: BinaryDecodableWithConfiguration {
    public let size: Int

    private var _bytes: [UInt8]
    public var wrappedValue: [UInt8] {
        get {
            _bytes
        }
        set {
            if newValue.count >= size {
                _bytes = Array(newValue[0..<size])
            } else {
                _bytes = newValue + Array(repeating: 0, count: size - newValue.count)
            }
        }
    }

    public init(size: Int) {
        self.size = size
        _bytes = Array(repeating: 0, count: size)
    }

    public init(from decoder: BinaryDecoder, configuration: Int) throws {
        size = configuration
        _bytes = try decoder.decode([UInt8].self, length: size)
    }
}
