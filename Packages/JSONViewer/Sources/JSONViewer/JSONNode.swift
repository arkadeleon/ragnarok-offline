//
//  JSONNode.swift
//  JSONViewer
//
//  Created by Leon Li on 2026/1/12.
//

import Foundation

enum JSONNodePayload: Sendable {
    case object(key: String?, children: [JSONNode])
    case array(key: String?, children: [JSONNode])
    case chunk(label: String, children: [JSONNode])
    case string(key: String?, value: String)
    case number(key: String?, value: Double)
    case boolean(key: String?, value: Bool)
    case null(key: String?)
}

/// Represents a node in the JSON tree structure
struct JSONNode: Identifiable, Sendable {
    static func object(key: String?, children: [JSONNode]) -> JSONNode {
        JSONNode(payload: .object(key: key, children: children))
    }

    static func array(key: String?, children: [JSONNode]) -> JSONNode {
        JSONNode(payload: .array(key: key, children: children))
    }

    static func chunk(label: String, children: [JSONNode]) -> JSONNode {
        JSONNode(payload: .chunk(label: label, children: children))
    }

    static func string(key: String?, value: String) -> JSONNode {
        JSONNode(payload: .string(key: key, value: value))
    }

    static func number(key: String?, value: Double) -> JSONNode {
        JSONNode(payload: .number(key: key, value: value))
    }

    static func boolean(key: String?, value: Bool) -> JSONNode {
        JSONNode(payload: .boolean(key: key, value: value))
    }

    static func null(key: String?) -> JSONNode {
        JSONNode(payload: .null(key: key))
    }

    let id: UUID
    var payload: JSONNodePayload

    /// The key associated with this node (nil for root)
    var key: String? {
        switch payload {
        case .object(let key, _): key
        case .array(let key, _): key
        case .chunk(let label, _): label
        case .string(let key, _): key
        case .number(let key, _): key
        case .boolean(let key, _): key
        case .null(let key): key
        }
    }

    /// Children nodes (only for object, array, and chunk types)
    var children: [JSONNode]? {
        switch payload {
        case .object(_, let children): children
        case .array(_, let children): children
        case .chunk(_, let children): children
        default: nil
        }
    }

    /// Display value
    var displayValue: String? {
        // Calculate total item count, accounting for chunked children
        let totalItemCount: ([JSONNode]) -> Int = { children in
            // If children are chunks, sum up their item counts
            if let firstChild = children.first, case .chunk = firstChild.payload {
                return children.reduce(0) { sum, chunk in
                    sum + (chunk.children?.count ?? 0)
                }
            }
            // Otherwise, just return the count of children
            return children.count
        }

        switch payload {
        case .object(_, let children):
            let count = totalItemCount(children)
            return "{\(count) \(count == 1 ? "item" : "items")}"
        case .array(_, let children):
            let count = totalItemCount(children)
            return "[\(count) \(count == 1 ? "item" : "items")]"
        case .chunk(_, let children):
            return "(\(children.count) \(children.count == 1 ? "item" : "items"))"
        case .string(_, let value):
            return "\"\(value)\""
        case .number(_, let value):
            // Display integers without decimal point
            if value.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(value))"
            } else {
                return "\(value)"
            }
        case .boolean(_, let value):
            return value ? "true" : "false"
        case .null:
            return "null"
        }
    }

    init(payload: JSONNodePayload) {
        self.id = UUID()
        self.payload = payload
    }
}

extension JSONNode {
    var isObject: Bool {
        if case .object = payload { true } else { false }
    }

    var isArray: Bool {
        if case .array = payload { true } else { false }
    }

    var isChunk: Bool {
        if case .chunk = payload { true } else { false }
    }

    var isString: Bool {
        if case .string = payload { true } else { false }
    }

    var isNumber: Bool {
        if case .number = payload { true } else { false }
    }

    var isBoolean: Bool {
        if case .boolean = payload { true } else { false }
    }

    var isNull: Bool {
        if case .null = payload { true } else { false }
    }
}
