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
        node: .object(key: nil, children: [
            .string(key: "name", value: "Ragnarok Online"),
            .number(key: "year", value: 2002),
            .boolean(key: "isActive", value: true),
            .object(key: "player", children: [
                .string(key: "class", value: "Swordsman"),
                .number(key: "level", value: 99),
                .array(key: "skills", children: [
                    .string(key: "[0]", value: "Bash"),
                    .string(key: "[1]", value: "Provoke"),
                    .string(key: "[2]", value: "Magnum Break")
                ])
            ]),
            .array(key: "maps", children: [
                .string(key: "[0]", value: "prontera"),
                .string(key: "[1]", value: "geffen"),
                .string(key: "[2]", value: "morocc")
            ]),
            .null(key: "metadata")
        ]),
        searchText: ""
    )
}

#Preview("With Search") {
    JSONTreeView(
        node: .object(key: nil, children: [
            .string(key: "username", value: "player123"),
            .number(key: "userId", value: 12345),
            .string(key: "email", value: "user@example.com")
        ]),
        searchText: "user"
    )
}
