//
//  File+Compare.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/28.
//

import Foundation

extension File {
    struct Comparator: SortComparator {
        var order: SortOrder = .forward

        func compare(_ lhs: File, _ rhs: File) -> ComparisonResult {
            if (lhs.rank, lhs.name) < (rhs.rank, rhs.name) {
                .orderedAscending
            } else if (lhs.rank, lhs.name) > (rhs.rank, rhs.name) {
                .orderedDescending
            } else {
                .orderedSame
            }
        }
    }
}

extension File: Comparable {
    static func < (lhs: File, rhs: File) -> Bool {
        (lhs.rank, lhs.name) < (rhs.rank, rhs.name)
    }
}

extension File {
    @inlinable
    var rank: Int {
        switch node {
        case .directory: 0
        case .grfArchive: 1
        case .regularFile: 2
        case .grfArchiveNode(_, let node): node.isDirectory ? 0 : 2
        }
    }
}
