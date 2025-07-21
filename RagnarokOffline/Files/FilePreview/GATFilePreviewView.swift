//
//  GATFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import ROFileFormats
import SwiftUI

struct GATFilePreviewView: View {
    var file: File

    var body: some View {
        AsyncContentView(load: loadGATFile) { image in
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
    .frame(width: 400, height: 300)
}
