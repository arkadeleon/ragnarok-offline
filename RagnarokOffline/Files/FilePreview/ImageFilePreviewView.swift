//
//  ImageFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import ROFileFormats
import SwiftUI

struct ImageFilePreviewView: View {
    var file: File

    var body: some View {
        AsyncContentView(load: loadImageFile) { image in
            Image(image, scale: 1, label: Text(file.name))
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

    nonisolated private func loadImageFile() async throws -> CGImage {
        guard let data = file.contents() else {
            throw FilePreviewError.invalidImageFile
        }

        switch file.type {
        case .ebm:
            guard let decompressedData = data.unzip() else {
                throw FilePreviewError.invalidImageFile
            }
            guard let imageSource = CGImageSourceCreateWithData(decompressedData as CFData, nil) else {
                throw FilePreviewError.invalidImageFile
            }
            guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
                throw FilePreviewError.invalidImageFile
            }
            return image
        case .pal:
            let pal = try PAL(data: data)
            guard let image = pal.image(at: CGSize(width: 256, height: 256)) else {
                throw FilePreviewError.invalidImageFile
            }
            return image
        default:
            guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
                throw FilePreviewError.invalidImageFile
            }
            guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
                throw FilePreviewError.invalidImageFile
            }
            return image
        }
    }
}

//#Preview {
//    ImageFilePreviewView(file: <#T##File#>)
//}
