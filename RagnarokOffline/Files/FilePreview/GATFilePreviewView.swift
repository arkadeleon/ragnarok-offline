//
//  GATFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import RagnarokFileFormats
import SwiftUI

struct GATFilePreviewView: View {
    var file: File

    private enum ViewMode {
        case altitude
        case tree
    }

    @State private var viewMode: ViewMode = .altitude

    var body: some View {
        Group {
            switch viewMode {
            case .altitude:
                GATFileAltitudeView(file: file)
            case .tree:
                FileJSONViewer(file: file)
            }
        }
        .toolbar {
            Menu {
                Picker("View Mode", selection: $viewMode) {
                    Label("Altitude", systemImage: "square.grid.3x3.middle.filled")
                        .tag(ViewMode.altitude)
                    Label("Tree", systemImage: "list.bullet.indent")
                        .tag(ViewMode.tree)
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}

struct GATFileAltitudeView: View {
    var file: File

    var body: some View {
        AsyncContentView {
            try await loadGATFile()
        } content: { image in
            Image(image, scale: 1, label: Text(file.name))
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

    private func loadGATFile() async throws -> CGImage {
        let data = try await file.contents()
        let gat = try GAT(data: data)

        guard let image = gat.image() else {
            throw FileError.imageGenerationFailed
        }

        return image
    }
}

#Preview {
    AsyncContentView {
        try await File.previewGAT()
    } content: { file in
        GATFilePreviewView(file: file)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
