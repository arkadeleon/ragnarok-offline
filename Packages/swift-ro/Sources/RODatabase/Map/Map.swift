//
//  Map.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

public struct Map: Equatable, Hashable, Sendable {

    /// Map name.
    public var name: String

    /// Map index.
    public var index: Int
}

extension Map: Identifiable {
    public var id: String {
        name
    }
}

extension Map: Comparable {
    public static func < (lhs: Map, rhs: Map) -> Bool {
        lhs.index < rhs.index
    }
}
