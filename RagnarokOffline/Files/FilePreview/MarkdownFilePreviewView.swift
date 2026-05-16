//
//  MarkdownFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/5/16.
//

import SwiftUI

struct MarkdownFilePreviewView: View {
    var file: File

    var body: some View {
        AsyncContentView {
            let data = try await file.contents()
            let markdown = String(data: data, encoding: .utf8) ?? ""
            return markdownToHTML(markdown)
        } content: { html in
            WebView(htmlString: html, baseURL: nil)
                .ignoresSafeArea()
        }
    }

    private func markdownToHTML(_ markdown: String) -> String {
        let lines = markdown.components(separatedBy: "\n")
        var blocks: [String] = []
        var inOrderedList = false

        func closeList() {
            if inOrderedList {
                blocks.append("</ol>")
                inOrderedList = false
            }
        }

        for line in lines {
            if line.hasPrefix("## ") {
                closeList()
                blocks.append("<h2>\(inlineHTML(String(line.dropFirst(3))))</h2>")
            } else if line.hasPrefix("# ") {
                closeList()
                blocks.append("<h1>\(inlineHTML(String(line.dropFirst(2))))</h1>")
            } else if line == "---" {
                closeList()
                blocks.append("<hr>")
            } else if let match = line.wholeMatch(of: /\d+\. (.+)/) {
                if !inOrderedList {
                    blocks.append("<ol>")
                    inOrderedList = true
                }
                blocks.append("<li>\(inlineHTML(String(match.output.1)))</li>")
            } else if line.isEmpty {
                closeList()
            } else {
                closeList()
                blocks.append("<p>\(inlineHTML(line))</p>")
            }
        }
        closeList()

        let body = blocks.joined(separator: "\n")
        return """
        <!doctype html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            :root { color-scheme: light dark; }
            body {
              font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", sans-serif;
              font-size: 16px;
              line-height: 1.6;
              margin: 0;
              padding: 16px;
            }
            h1 { font-size: 1.4em; margin: 0 0 0.5em; }
            h2 { font-size: 1.15em; margin: 1.4em 0 0.4em; }
            p { margin: 0.5em 0; }
            ol { padding-left: 1.5em; margin: 0.4em 0; }
            li { margin: 0.25em 0; }
            hr { border: none; border-top: 1px solid rgba(127,127,127,0.3); margin: 1.2em 0; }
            code {
              font-family: ui-monospace, "SF Mono", Menlo, monospace;
              font-size: 0.85em;
              background: rgba(127,127,127,0.15);
              padding: 0.15em 0.35em;
              border-radius: 4px;
            }
          </style>
        </head>
        <body>
        \(body)
        </body>
        </html>
        """
    }

    private func inlineHTML(_ text: String) -> String {
        var result = text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        result = result.replacing(/\*\*(.+?)\*\*/) { "<strong>\($0.output.1)</strong>" }
        result = result.replacing(/`([^`]+)`/) { "<code>\($0.output.1)</code>" }
        return result
    }
}
