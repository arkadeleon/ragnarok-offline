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

    nonisolated private func loadGATFile() async throws -> CGImage {
        guard let gatData = file.contents() else {
            throw FilePreviewError.invalidGATFile
        }

        let gat = try GAT(data: gatData)

        guard let image = gat.image() else {
            throw FilePreviewError.invalidGATFile
        }

        return image
    }
}

#Preview {
    GATFilePreviewView(file: .previewGAT)
}
