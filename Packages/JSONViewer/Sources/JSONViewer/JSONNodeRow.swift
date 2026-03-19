//
//  JSONNodeRow.swift
//  JSONViewer
//
//  Created by Leon Li on 2026/1/12.
//

import SwiftUI

/// Displays a single node in the JSON tree
struct JSONNodeRow: View {
    var node: JSONNode
    var searchText: String

    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    var body: some View {
        HStack(spacing: 6) {
            // Key (if present)
            if let key = node.key {
                Text(key)
                    .fontWeight(.semibold)
                Text(verbatim: ":")
            }

            // Value
            if let value = node.displayValue {
                Text(value)
                    .foregroundStyle(node.color)
            }
        }
        .padding(.vertical, 2)
        .background(
            highlightColor
                .opacity(0.2)
                .clipShape(.rect(cornerRadius: 4))
        )
        .overlay {
            if differentiateWithoutColor && matchesSearch() {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(Color.accentColor, lineWidth: 2)
            }
        }
        .accessibilityElement(children: .combine)
        .contextMenu {
            if let key = node.key {
                Button(LocalizedStringResource("Copy Key", bundle: .module)) {
                    copyToClipboard(key)
                }
            }
            if let value = node.displayValue {
                Button(LocalizedStringResource("Copy Value", bundle: .module)) {
                    copyToClipboard(value)
                }
            }
        }
    }

    /// Highlight color if this node matches the search
    private var highlightColor: Color {
        matchesSearch() ? .accentColor : .clear
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
        #if canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #elseif canImport(UIKit)
        UIPasteboard.general.string = text
        #endif
    }
}

extension JSONNode {
    var color: Color {
        switch payload {
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

#Preview("Different Node Types") {
    VStack(alignment: .leading, spacing: 8) {
        JSONNodeRow(
            node: .string(key: "name", value: "John Doe"),
            searchText: ""
        )
        JSONNodeRow(
            node: .number(key: "age", value: 42),
            searchText: ""
        )
        JSONNodeRow(
            node: .number(key: "price", value: 19.99),
            searchText: ""
        )
        JSONNodeRow(
            node: .boolean(key: "isActive", value: true),
            searchText: ""
        )
        JSONNodeRow(
            node: .null(key: "metadata"),
            searchText: ""
        )
        JSONNodeRow(
            node: .object(key: "address", children: []),
            searchText: ""
        )
        JSONNodeRow(
            node: .array(key: "tags", children: [
                .string(key: "[0]", value: "swift"),
                .string(key: "[1]", value: "swiftui")
            ]),
            searchText: ""
        )
    }
    .padding()
}

#Preview("With Search Highlight") {
    VStack(alignment: .leading, spacing: 8) {
        JSONNodeRow(
            node: .string(key: "username", value: "john_doe"),
            searchText: "user"
        )
        JSONNodeRow(
            node: .string(key: "email", value: "john@example.com"),
            searchText: "user"
        )
        JSONNodeRow(
            node: .number(key: "userId", value: 12345),
            searchText: "user"
        )
    }
    .padding()
}
