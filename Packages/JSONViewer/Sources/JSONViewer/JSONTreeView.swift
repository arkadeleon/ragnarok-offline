//
//  JSONTreeView.swift
//  JSONViewer
//
//  Created by Leon Li on 2026/1/12.
//

import SwiftUI

/// Displays the JSON tree using hierarchical List
struct JSONTreeView: View {
    var node: JSONNode
    var searchText: String

    var body: some View {
        List(displayNodes, children: \.children) { item in
            JSONNodeRow(node: item, searchText: searchText)
        }
        .listStyle(.plain)
    }

    /// Nodes to display - expands root node by default if it has no key
    private var displayNodes: [JSONNode] {
        // If root node has no key (it's the actual root), show its children directly
        if node.key == nil, let children = node.children {
            return children
        }
        // Otherwise, show the node itself
        return [node]
    }
}

#Preview("Nested JSON Tree") {
    JSONTreeView(
        node: .object(id: UUID(), key: nil, children: [
            .string(id: UUID(), key: "name", value: "Ragnarok Online"),
            .number(id: UUID(), key: "year", value: 2002),
            .boolean(id: UUID(), key: "isActive", value: true),
            .object(id: UUID(), key: "player", children: [
                .string(id: UUID(), key: "class", value: "Swordsman"),
                .number(id: UUID(), key: "level", value: 99),
                .array(id: UUID(), key: "skills", children: [
                    .string(id: UUID(), key: "[0]", value: "Bash"),
                    .string(id: UUID(), key: "[1]", value: "Provoke"),
                    .string(id: UUID(), key: "[2]", value: "Magnum Break")
                ])
            ]),
            .array(id: UUID(), key: "maps", children: [
                .string(id: UUID(), key: "[0]", value: "prontera"),
                .string(id: UUID(), key: "[1]", value: "geffen"),
                .string(id: UUID(), key: "[2]", value: "morocc")
            ]),
            .null(id: UUID(), key: "metadata")
        ]),
        searchText: ""
    )
}

#Preview("With Search") {
    JSONTreeView(
        node: .object(id: UUID(), key: nil, children: [
            .string(id: UUID(), key: "username", value: "player123"),
            .number(id: UUID(), key: "userId", value: 12345),
            .string(id: UUID(), key: "email", value: "user@example.com")
        ]),
        searchText: "user"
    )
}
