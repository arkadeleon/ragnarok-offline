//
//  CodingValue.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/13.
//

public protocol CodingValue: Sendable {
    var stringValue: String { get }

    init?(stringValue: String)
}

extension CodingValue where Self: CaseIterable {
    public init?(stringValue: String) {
        if let value = Self.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = value
        } else {
            return nil
        }
    }
}
