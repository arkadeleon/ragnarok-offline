//
//  FixedSizeArray.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/18.
//

import Foundation

@propertyWrapper
public struct FixedSizeArray<Element> {
    public let size: Int
    public let initialValue: @Sendable () -> Element

    private var _elements: [Element]
    public var wrappedValue: [Element] {
        get {
            _elements
        }
        set {
            if newValue.count >= size {
                _elements = Array(newValue[0..<size])
            } else {
                _elements = newValue + Array(repeating: initialValue(), count: size - newValue.count)
            }
        }
    }

    public init(size: Int, initialValue: @autoclosure @escaping @Sendable () -> Element) {
        self.size = size
        self.initialValue = initialValue
        _elements = Array(repeating: initialValue(), count: size)
    }
}

extension FixedSizeArray: Sendable where Element: Sendable {
}
