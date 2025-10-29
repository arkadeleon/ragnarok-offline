//
//  FileJSONViewer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/28.
//

import SwiftUI

struct FileJSONViewer: View {
    var file: File
    var onDone: () -> Void

    @State private var htmlString = ""

    var body: some View {
        #if os(macOS)
        WebView(htmlString: htmlString, baseURL: Bundle.main.resourceURL)
            .frame(height: 400)
            .navigationTitle("JSON Viewer")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone)
                }
            }
            .task {
                await loadHTMLString()
            }
        #else
        WebView(htmlString: htmlString, baseURL: Bundle.main.resourceURL)
            .ignoresSafeArea()
            .navigationTitle("JSON Viewer")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone)
                }
            }
            .task {
                await loadHTMLString()
            }
        #endif
    }

    init(file: File, onDone: @escaping () -> Void) {
        self.file = file
        self.onDone = onDone
    }

    private func loadHTMLString() async {
        guard let json = await file.json() else {
            return
        }

        htmlString = """
        <!doctype html>
        <html lang="en">
          <meta charset="utf-8">
          <meta name="viewport" content="height=device-height, initial-scale=1.0, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
          <body>
            <div id="json-viewer"></div>
            <script src="browser.js"></script>
            <script>
              new JsonViewer({
                value: \(json),
                rootName: false,
                enableClipboard: false,
                quotesOnKeys: false,
                displayDataTypes: false
              }).render('#json-viewer')
            </script>
          </body>
        </html>
        """
    }
}

#Preview {
    AsyncContentView {
        try await File.previewRSW()
    } content: { file in
        FileJSONViewer(file: file) {
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
