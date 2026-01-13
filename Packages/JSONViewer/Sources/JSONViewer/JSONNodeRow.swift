//
//  JSONNodeRow.swift
//  JSONViewer
//
//  Created by Leon Li on 2026/1/12.
//

import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

/// Displays a single node in the JSON tree
struct JSONNodeRow: View {
    var node: JSONNode
    var searchText: String

    var body: some View {
        HStack(spacing: 6) {
            // Key (if present)
            if let key = node.key {
                Text(key)
                    .fontWeight(.semibold)
                Text(":")
            }

            // Value
            if let value = node.displayValue {
                Text(value)
                    .foregroundStyle(node.valueType.color)
            }
        }
        .padding(.vertical, 2)
        .background(
            highlightColor
                .opacity(0.2)
                .cornerRadius(4)
        )
        .contextMenu {
            if let key = node.key {
                Button("Copy Key") {
                    copyToClipboard(key)
                }
            }
            if let value = node.displayValue {
                Button("Copy Value") {
                    copyToClipboard(value)
                }
            }
        }
    }

    /// Highlight color if this node matches the search
    private var highlightColor: Color {
        if searchText.isEmpty {
            return .clear
        }

        let matches = matchesSearch()
        return matches ? .accentColor : .clear
    }

    /// Check if this node matches the search text
    private func matchesSearch() -> Bool {
        guard !searchText.isEmpty else {
            return false
        }

        let lowercasedSearch = searchText.lowercased()

        // Check key
        if let key = node.key, key.lowercased().contains(lowercasedSearch) {
            return true
        }

        // Check value
        if let value = node.displayValue, value.lowercased().contains(lowercasedSearch) {
            return true
        }

        return false
    }

    /// Copy text to clipboard (platform-specific)
    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
}

#Preview("Different Node Types") {
    VStack(alignment: .leading, spacing: 8) {
        JSONNodeRow(
            node: .string(id: UUID(), key: "name", value: "John Doe"),
            searchText: ""
        )
        JSONNodeRow(
            node: .number(id: UUID(), key: "age", value: 42),
            searchText: ""
        )
        JSONNodeRow(
            node: .number(id: UUID(), key: "price", value: 19.99),
            searchText: ""
        )
        JSONNodeRow(
            node: .boolean(id: UUID(), key: "isActive", value: true),
            searchText: ""
        )
        JSONNodeRow(
            node: .null(id: UUID(), key: "metadata"),
            searchText: ""
        )
        JSONNodeRow(
            node: .object(id: UUID(), key: "address", children: []),
            searchText: ""
        )
        JSONNodeRow(
            node: .array(id: UUID(), key: "tags", children: [
                .string(id: UUID(), key: "[0]", value: "swift"),
                .string(id: UUID(), key: "[1]", value: "swiftui")
            ]),
            searchText: ""
        )
    }
    .padding()
}

#Preview("With Search Highlight") {
    VStack(alignment: .leading, spacing: 8) {
        JSONNodeRow(
            node: .string(id: UUID(), key: "username", value: "john_doe"),
            searchText: "user"
        )
        JSONNodeRow(
            node: .string(id: UUID(), key: "email", value: "john@example.com"),
            searchText: "user"
        )
        JSONNodeRow(
            node: .number(id: UUID(), key: "userId", value: 12345),
            searchText: "user"
        )
    }
    .padding()
}
