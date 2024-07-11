//
//  GATFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import SwiftUI
import ROFileFormats

enum GATFilePreviewError: Error {
    case invalidGATFile
}

struct GATFilePreviewView: View {
    var file: ObservableFile

    @State private var status: AsyncContentStatus<CGImage> = .notYetLoaded

    var body: some View {
        AsyncContentView(status: status) { image in
            Image(image, scale: 1, label: Text(file.file.name))
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .task {
            await loadGATFile()
        }
    }

    private func loadGATFile() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        guard let gatData = file.file.contents() else {
            status = .failed(GATFilePreviewError.invalidGATFile)
            return
        }

        guard let gat = try? GAT(data: gatData) else {
            status = .failed(GATFilePreviewError.invalidGATFile)
            return
        }

        if let image = gat.image() {
            status = .loaded(image)
        } else {
            status = .failed(GATFilePreviewError.invalidGATFile)
        }
    }
}

#Preview {
    GATFilePreviewView(file: PreviewFiles.gatFile)
}
