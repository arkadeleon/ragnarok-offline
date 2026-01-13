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

    var body: some View {
        AsyncContentView(load: loadJSON) { json in
            JSONViewer(data: json)
        }
    }

    private func loadJSON() async throws -> Data {
        try await file.json()
    }
}

#Preview {
    AsyncContentView {
        try await File.previewRSW()
    } content: { file in
        FileJSONViewer(file: file)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
