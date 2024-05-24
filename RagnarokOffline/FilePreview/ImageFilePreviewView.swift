//
//  ImageFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import SwiftUI
import ROFileFormats

enum ImageFilePreviewError: Error {
    case invalidImageFile
}

struct ImageFilePreviewView: View {
    var file: ObservableFile

    @State private var status: AsyncContentStatus<CGImage> = .notYetLoaded

    var body: some View {
        AsyncContentView(status: status) { image in
            Image(image, scale: 1, label: Text(file.file.name))
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .task {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        guard let data = file.file.contents() else {
            status = .failed(ImageFilePreviewError.invalidImageFile)
            return
        }

        var image: CGImage?
        switch file.file.info.type {
        case .ebm:
            guard let decompressedData = data.unzip() else {
                return
            }
            guard let imageSource = CGImageSourceCreateWithData(decompressedData as CFData, nil) else {
                return
            }
            image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        case .pal:
            let pal = try? PAL(data: data)
            image = pal?.image(at: CGSize(width: 256, height: 256))
        default:
            guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
                return
            }
            image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        }

        if let image {
            status = .loaded(image)
        } else {
            status = .failed(ImageFilePreviewError.invalidImageFile)
        }
    }
}

//#Preview {
//    ImageFilePreviewView(file: <#T##File#>)
//}
