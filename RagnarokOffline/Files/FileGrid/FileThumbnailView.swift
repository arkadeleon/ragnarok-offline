//
//  FileThumbnailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/11.
//

import SwiftUI

struct FileThumbnailView: View {
    var file: File

    @Environment(\.displayScale) private var displayScale
    @Environment(\.fileSystem) private var fileSystem

    @State private var thumbnail: FileThumbnail?

    var body: some View {
        ZStack {
            if let thumbnail {
                Image(thumbnail.cgImage, scale: displayScale, label: Text(file.name))
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.secondary, lineWidth: 1)
                    }
            } else if file.isDirectory {
                Image(systemName: file.iconName)
                    .font(.system(size: 50))
                    .symbolRenderingMode(.multicolor)
            } else {
                Image(systemName: file.iconName)
                    .font(.system(size: 30, weight: .thin))
                    .foregroundStyle(Color.secondary)
                    .symbolRenderingMode(.monochrome)
                    .frame(width: 60, height: 80)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.secondary, lineWidth: 1)
                    }
            }
        }
        .task {
            let size = CGSize(width: 80, height: 80)
            let request = FileThumbnailRequest(file: file, size: size, scale: displayScale)
            thumbnail = try? await fileSystem.thumbnail(for: request)
        }
    }
}

#Preview {
    AsyncContentView {
        try await [
            File.previewGRF(),
            File.previewGAT(),
            File.previewGND(),
            File.previewRSW(),
            File.previewSPR(),
        ]
    } content: { files in
        HStack {
            ForEach(files) { file in
                FileThumbnailView(file: file)
            }
        }
    }
    .frame(width: 400, height: 100)
}
