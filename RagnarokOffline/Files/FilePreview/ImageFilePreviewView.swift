//
//  ImageFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import ROFileFormats
import SwiftGzip
import SwiftUI

struct ImageFilePreviewView: View {
    var file: File

    var body: some View {
        AsyncContentView {
            try await loadImageFile()
        } content: { image in
            Image(image, scale: 1, label: Text(file.name))
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

    private func loadImageFile() async throws -> CGImage {
        let data = try await file.contents()

        switch file.utType {
        case .ebm:
            let decompressor = GzipDecompressor()
            let decompressedData = try await decompressor.unzip(data: data)
            guard let imageSource = CGImageSourceCreateWithData(decompressedData as CFData, nil),
                  let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
                throw FileError.imageGenerationFailed
            }
            return image
        case .pal:
            let pal = try PAL(data: data)
            guard let image = pal.image(at: CGSize(width: 256, height: 256)) else {
                throw FileError.imageGenerationFailed
            }
            return image
        default:
            guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
                  let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
                throw FileError.imageGenerationFailed
            }
            return image
        }
    }
}

//#Preview {
//    ImageFilePreviewView(file: <#T##File#>)
//}
