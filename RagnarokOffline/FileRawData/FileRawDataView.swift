//
//  FileRawDataView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/28.
//

import SwiftUI
import ROFileSystem

struct FileRawDataView: View {
    let file: File

    private var htmlString: String {
        guard let rawData = file.rawData, let json = String(data: rawData, encoding: .utf8) else {
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
        Bundle.main.resourceURL?.appendingPathComponent("json-viewer")
    }

    var body: some View {
        WebView(htmlString: htmlString, baseURL: baseURL)
            .ignoresSafeArea()
            .navigationTitle("Raw Data")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
    }
}
