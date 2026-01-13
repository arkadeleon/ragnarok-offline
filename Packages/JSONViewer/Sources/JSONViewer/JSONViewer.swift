//
//  JSONViewer.swift
//  JSONViewer
//
//  Created by Leon Li on 2026/1/12.
//

import SwiftUI

/// Main public JSON viewer component
public struct JSONViewer: View {
    public var data: Data

    @State private var rootNode: JSONNode?
    @State private var error: (any Error)?
    @State private var searchText = ""

    public var body: some View {
        Group {
            if let error {
                // Error state
                ContentUnavailableView {
                    Label("Failed to Parse JSON", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error.localizedDescription)
                }
            } else if let rootNode {
                // Content state
                JSONTreeView(node: rootNode, searchText: searchText)
                    .searchable(text: $searchText, prompt: "Search keys and values")
            } else {
                // Loading state
                ProgressView("Parsing JSON...")
            }
        }
        .task {
            await parseJSON()
        }
    }

    public init(data: Data) {
        self.data = data
    }

    /// Parse JSON data asynchronously
    private func parseJSON() async {
        do {
            let node = try JSONParser.parse(data: data)
            self.rootNode = node
        } catch {
            self.error = error
        }
    }
}

#Preview("Game Character Data") {
    let jsonString = """
    {
        "character": {
            "name": "Asgard Knight",
            "class": "Lord Knight",
            "level": 99,
            "baseLevel": 99,
            "jobLevel": 70,
            "hp": 32450,
            "sp": 1820,
            "stats": {
                "str": 120,
                "agi": 80,
                "vit": 95,
                "int": 9,
                "dex": 70,
                "luk": 30
            },
            "equipment": [
                "Excalibur",
                "Valkyrja's Shield",
                "Lord's Clothes"
            ],
            "skills": [
                {"id": 1, "name": "Bash", "level": 10},
                {"id": 2, "name": "Provoke", "level": 10},
                {"id": 57, "name": "Bowling Bash", "level": 10}
            ],
            "isOnline": true,
            "guild": null
        }
    }
    """

    JSONViewer(data: jsonString.data(using: .utf8)!)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

#Preview("Simple Array") {
    let jsonString = """
    ["prontera", "geffen", "payon", "morocc", "alberta"]
    """

    JSONViewer(data: jsonString.data(using: .utf8)!)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

#Preview("Invalid JSON - Error State") {
    let invalidJSON = "{this is not valid json}".data(using: .utf8)!

    JSONViewer(data: invalidJSON)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
