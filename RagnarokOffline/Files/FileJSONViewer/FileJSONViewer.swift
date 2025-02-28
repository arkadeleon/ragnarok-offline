//
//  FileJSONViewer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/28.
//

import SwiftUI

struct FileJSONViewer: View {
    var file: File

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        #if os(macOS)
        WebView(htmlString: htmlString, baseURL: baseURL)
            .frame(height: 400)
            .navigationTitle("JSON Viewer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        #else
        WebView(htmlString: htmlString, baseURL: baseURL)
            .ignoresSafeArea()
            .navigationTitle("JSON Viewer")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        #endif
    }

    private var htmlString: String {
        guard let json = file.json else {
            return ""
        }

        return """
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

    private var baseURL: URL? {
        Bundle.main.resourceURL
    }
}

#Preview {
    FileJSONViewer(file: .previewRSW)
}
