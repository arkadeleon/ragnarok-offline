//
//  JSONParser.swift
//  JSONViewer
//
//  Created by Leon Li on 2026/1/12.
//

import Foundation

/// Error types for JSON parsing
public enum JSONParsingError: LocalizedError {
    case invalidData
    case parsingFailed(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .invalidData:
            "Invalid JSON data"
        case .parsingFailed(let error):
            "Failed to parse JSON: \(error.localizedDescription)"
        }
    }
}

/// Parser for converting JSON data into a tree structure
struct JSONParser {
    /// Threshold for chunking large arrays/objects
    static let chunkThreshold = 100

    /// Size of each chunk
    static let chunkSize = 100

    /// Parse JSON data into a tree of nodes
    /// - Parameter data: The JSON data to parse
    /// - Returns: Root node of the parsed tree
    /// - Throws: JSONParsingError if parsing fails
    static func parse(data: Data) throws -> JSONNode {
        let jsonObject: Any
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            throw JSONParsingError.parsingFailed(underlying: error)
        }

        return buildNode(from: jsonObject, key: nil)
    }

    /// Recursively build a node from a JSON value
    /// - Parameters:
    ///   - value: The JSON value (Dictionary, Array, String, Number, Bool, or null)
    ///   - key: Optional key for this node
    /// - Returns: A JSONNode representing the value
    private static func buildNode(from value: Any, key: String?) -> JSONNode {
        let id = UUID()

        // Handle null
        if value is NSNull {
            return .null(id: id, key: key)
        }

        // Handle dictionary (object)
        if let dict = value as? [String: Any] {
            // Note: NSDictionary does not preserve JSON insertion order.
            // Keys will be in the order provided by Foundation's dictionary implementation.
            let allChildren = dict.map { (dictKey, dictValue) in
                buildNode(from: dictValue, key: dictKey)
            }

            // Chunk if too large
            let children: [JSONNode]
            if allChildren.count > chunkThreshold {
                children = chunkNodes(allChildren, type: .object)
            } else {
                children = allChildren
            }

            return .object(id: id, key: key, children: children)
        }

        // Handle array
        if let array = value as? [Any] {
            let allChildren = array.enumerated().map { (index, element) in
                buildNode(from: element, key: "[\(index)]")
            }

            // Chunk if too large
            let children: [JSONNode]
            if allChildren.count > chunkThreshold {
                children = chunkNodes(allChildren, type: .array)
            } else {
                children = allChildren
            }

            return .array(id: id, key: key, children: children)
        }

        // Handle boolean (must check before number, as NSNumber can represent both)
        if let number = value as? NSNumber {
            // Use Core Foundation to distinguish boolean from number
            if CFGetTypeID(number as CFTypeRef) == CFBooleanGetTypeID() {
                return .boolean(id: id, key: key, value: number.boolValue)
            } else {
                return .number(id: id, key: key, value: number.doubleValue)
            }
        }

        // Handle string
        if let string = value as? String {
            return .string(id: id, key: key, value: string)
        }

        // Fallback: treat unknown types as null
        return .null(id: id, key: key)
    }

    /// Chunk a large array of nodes into smaller groups
    /// - Parameters:
    ///   - nodes: The nodes to chunk
    ///   - type: The type of the parent (object or array)
    /// - Returns: Array of chunk nodes
    private static func chunkNodes(_ nodes: [JSONNode], type: JSONValueType) -> [JSONNode] {
        var chunks: [JSONNode] = []
        let totalCount = nodes.count
        let numberOfChunks = (totalCount + chunkSize - 1) / chunkSize

        for chunkIndex in 0..<numberOfChunks {
            let startIndex = chunkIndex * chunkSize
            let endIndex = min(startIndex + chunkSize, totalCount)
            let chunkNodes = Array(nodes[startIndex..<endIndex])

            let label: String
            if type == .array {
                label = "[\(startIndex)..\(endIndex - 1)]"
            } else {
                label = "Items \(startIndex)..\(endIndex - 1)"
            }

            let chunk = JSONNode.chunk(
                id: UUID(),
                label: label,
                children: chunkNodes
            )
            chunks.append(chunk)
        }

        return chunks
    }
}
