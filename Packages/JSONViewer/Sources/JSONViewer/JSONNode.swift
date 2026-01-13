//
//  JSONNode.swift
//  JSONViewer
//
//  Created by Leon Li on 2026/1/12.
//

import Foundation
import SwiftUI

/// Represents a node in the JSON tree structure
enum JSONNode: Identifiable, Sendable {
    case object(id: UUID, key: String?, children: [JSONNode])
    case array(id: UUID, key: String?, children: [JSONNode])
    case chunk(id: UUID, label: String, children: [JSONNode])
    case string(id: UUID, key: String?, value: String)
    case number(id: UUID, key: String?, value: Double)
    case boolean(id: UUID, key: String?, value: Bool)
    case null(id: UUID, key: String?)

    /// Unique identifier for the node
    var id: UUID {
        switch self {
        case .object(let id, _, _): id
        case .array(let id, _, _): id
        case .chunk(let id, _, _): id
        case .string(let id, _, _): id
        case .number(let id, _, _): id
        case .boolean(let id, _, _): id
        case .null(let id, _): id
        }
    }

    /// The key associated with this node (nil for root)
    var key: String? {
        switch self {
        case .object(_, let key, _): key
        case .array(_, let key, _): key
        case .chunk(_, let label, _): label
        case .string(_, let key, _): key
        case .number(_, let key, _): key
        case .boolean(_, let key, _): key
        case .null(_, let key): key
        }
    }

    /// Children nodes (only for object, array, and chunk types)
    var children: [JSONNode]? {
        switch self {
        case .object(_, _, let children): children
        case .array(_, _, let children): children
        case .chunk(_, _, let children): children
        default: nil
        }
    }

    /// The type of this JSON value
    var valueType: JSONValueType {
        switch self {
        case .object: .object
        case .array: .array
        case .chunk: .chunk
        case .string: .string
        case .number: .number
        case .boolean: .boolean
        case .null: .null
        }
    }

    /// Display value for leaf nodes
    var displayValue: String? {
        switch self {
        case .string(_, _, let value):
            return "\"\(value)\""
        case .number(_, _, let value):
            // Display integers without decimal point
            if value.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(value))"
            } else {
                return "\(value)"
            }
        case .boolean(_, _, let value):
            return value ? "true" : "false"
        case .null:
            return "null"
        case .object(_, _, let children):
            let count = totalItemCount(children: children)
            return "{\(count) \(count == 1 ? "item" : "items")}"
        case .array(_, _, let children):
            let count = totalItemCount(children: children)
            return "[\(count) \(count == 1 ? "item" : "items")]"
        case .chunk(_, _, let children):
            return "(\(children.count) \(children.count == 1 ? "item" : "items"))"
        }
    }

    /// Calculate total item count, accounting for chunked children
    private func totalItemCount(children: [JSONNode]) -> Int {
        // If children are chunks, sum up their item counts
        if let firstChild = children.first, firstChild.valueType == .chunk {
            return children.reduce(0) { sum, chunk in
                sum + (chunk.children?.count ?? 0)
            }
        }
        // Otherwise, just return the count of children
        return children.count
    }
}

/// Type classification for JSON values
enum JSONValueType {
    case object
    case array
    case chunk
    case string
    case number
    case boolean
    case null

    /// Color coding for the type
    var color: Color {
        switch self {
        case .object: .blue
        case .array: .purple
        case .chunk: .cyan
        case .string: .green
        case .number: .orange
        case .boolean: .red
        case .null: .gray
        }
    }
}
