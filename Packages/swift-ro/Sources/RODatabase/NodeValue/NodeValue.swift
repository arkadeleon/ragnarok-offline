//
//  NodeValue.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/12.
//

public protocol NodeValue: CaseIterable, Sendable {
    var intValue: Int { get }

    var stringValue: String { get }
}

extension NodeValue where Self: RawRepresentable, Self.RawValue == Int {
    public var intValue: Int {
        rawValue
    }
}
