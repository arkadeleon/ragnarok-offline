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
            let lhsRank = switch lhs.node {
            case .directory, .grfArchiveDirectory: 0
            case .grfArchive: 1
            case .regularFile, .grfArchiveEntry: 2
            }

            let rhsRank = switch rhs.node {
            case .directory, .grfArchiveDirectory: 0
            case .grfArchive: 1
            case .regularFile, .grfArchiveEntry: 2
            }

            if lhsRank == rhsRank {
                return lhs.name.localizedStandardCompare(rhs.name)
            } else {
                return NSNumber(integerLiteral: lhsRank).compare(NSNumber(integerLiteral: rhsRank))
            }
        }
    }
}

extension File: Comparable {
    static func < (lhs: File, rhs: File) -> Bool {
        let lhsRank = switch lhs.node {
        case .directory, .grfArchiveDirectory: 0
        case .grfArchive: 1
        case .regularFile, .grfArchiveEntry: 2
        }

        let rhsRank = switch rhs.node {
        case .directory, .grfArchiveDirectory: 0
        case .grfArchive: 1
        case .regularFile, .grfArchiveEntry: 2
        }

        if lhsRank == rhsRank {
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        } else {
            return lhsRank < rhsRank
        }
    }
}
