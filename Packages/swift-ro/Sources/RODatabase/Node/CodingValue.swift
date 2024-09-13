//
//  CodingValue.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/13.
//

public protocol CodingValue: Sendable {
    var intValue: Int { get }

    var stringValue: String { get }

    init?(intValue: Int)

    init?(stringValue: String)
}

extension CodingValue where Self: RawRepresentable, Self.RawValue == Int {
    public var intValue: Int {
        rawValue
    }
}

extension CodingValue where Self: CaseIterable {
    public init?(intValue: Int) {
        if let value = Self.allCases.first(where: { $0.intValue == intValue }) {
            self = value
        } else {
            return nil
        }
    }

    public init?(stringValue: String) {
        if let value = Self.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = value
        } else {
            return nil
        }
    }
}
