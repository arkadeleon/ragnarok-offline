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

    private enum ParsingState {
        case idle
        case parsing
        case parsed(JSONNode)
        case failed(any Error)
    }

    @State private var parsingState: ParsingState = .idle

    public var body: some View {
        ZStack {
            switch parsingState {
            case .idle:
                EmptyView()
            case .parsing:
                ProgressView(LocalizedStringResource("Parsing JSON...", bundle: .module))
            case .parsed(let node):
                JSONTreeView(node: node)
            case .failed(let error):
                ContentUnavailableView {
                    Label(LocalizedStringResource("Failed to Parse JSON", bundle: .module), systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error.localizedDescription)
                }
            }
        }
        .task {
            await parseJSON()
        }
    }

    public init(data: Data) {
        self.data = data
    }

    /// Parse JSON data asynchronously, off the main actor
    private func parseJSON() async {
        parsingState = .parsing

        do {
            let parser = JSONParser()
            let node = try await parser.parse(data: data)
            parsingState = .parsed(node)
        } catch {
            parsingState = .failed(error)
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
    let invalidJSON = "{this is not valid json}"

    JSONViewer(data: invalidJSON.data(using: .utf8)!)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
