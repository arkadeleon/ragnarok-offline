//
//  OptionSetSequence.swift
//  DatabaseCore
//
//  Created by Leon Li on 2024/10/8.
//

public struct OptionSetSequence<Element>: Sequence where Element: OptionSet, Element.RawValue == Int {
    public let element: Element

    public init(_ element: Element) {
        self.element = element
    }

    public func makeIterator() -> OptionSetIterator<Element> {
        OptionSetIterator(element)
    }
}

public struct OptionSetIterator<Element>: IteratorProtocol where Element: OptionSet, Element.RawValue == Int {
    public let element: Element

    public init(_ element: Element) {
        self.element = element
    }

    private lazy var remainingBits = element.rawValue
    private var bitMask = 1

    public mutating func next() -> Element? {
        while remainingBits != 0 {
            defer { bitMask = bitMask &* 2 }
            if remainingBits & bitMask != 0 {
                remainingBits = remainingBits & ~bitMask
                return Element(rawValue: bitMask)
            }
        }
        return nil
    }
}
