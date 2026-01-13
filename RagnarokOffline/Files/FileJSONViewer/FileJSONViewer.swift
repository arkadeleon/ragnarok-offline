//
//  FileJSONViewer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/28.
//

import JSONViewer
import SwiftUI

struct FileJSONViewer: View {
    var file: File
    var onDone: () -> Void

    var body: some View {
        AsyncContentView(load: loadJSON) { json in
            JSONViewer(data: json)
        }
        #if os(macOS)
        .frame(height: 400)
        #endif
        .navigationTitle("JSON Viewer")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarCancelButton(action: onDone)
        }
    }

    private func loadJSON() async -> Data {
        guard let json = await file.json() else {
            return Data()
        }

        return json.data(using: .utf8) ?? Data()
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
