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

    var body: some View {
        HStack(spacing: 6) {
            if let key = node.key {
                Text(key)
                    .fontWeight(.semibold)
                Text(verbatim: ":")
            }

            if let value = node.displayValue {
                Text(value)
                    .foregroundStyle(node.color)
            }
        }
        .padding(.vertical, 2)
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
        JSONNodeRow(node: .string(key: "name", value: "John Doe"))
        JSONNodeRow(node: .number(key: "age", value: 42))
        JSONNodeRow(node: .number(key: "price", value: 19.99))
        JSONNodeRow(node: .boolean(key: "isActive", value: true))
        JSONNodeRow(node: .null(key: "metadata"))
        JSONNodeRow(node: .object(key: "address", children: []))
        JSONNodeRow(
            node: .array(key: "tags", children: [
                .string(key: "[0]", value: "swift"),
                .string(key: "[1]", value: "swiftui")
            ])
        )
    }
    .padding()
}
