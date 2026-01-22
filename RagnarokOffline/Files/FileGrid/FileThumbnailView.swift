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
    @Environment(\.fileThumbnailCache) private var fileThumbnailCache

    @State private var thumbnail: FileThumbnail?

    var body: some View {
        ZStack(alignment: .bottom) {
            if let thumbnail {
                Image(thumbnail.cgImage, scale: displayScale, label: Text(file.name))
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(Color.secondary, lineWidth: 1)
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
            } else if file.isDirectory {
                Image(systemName: file.iconName)
                    .font(.system(size: 50))
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(Color.accentColor)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            } else {
                Image(systemName: file.iconName)
                    .font(.system(size: 30, weight: .thin))
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(Color.secondary)
                    .frame(width: 60, height: 80)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(Color.secondary, lineWidth: 1)
                    }
            }
        }
        .frame(width: 80, height: 80)
        .task {
            let size = CGSize(width: 80, height: 80)
            let request = FileThumbnailRequest(file: file, size: size, scale: displayScale)
            thumbnail = try? await fileThumbnailCache.thumbnail(for: request)
        }
    }
}

#Preview {
    AsyncContentView {
        try await [
            File.previewFolder(),
            File.previewGRF(),
            File.previewGAT(),
            File.previewWideGAT(),
            File.previewTallGAT(),
            File.previewGND(),
            File.previewRSW(),
            File.previewSPR(),
        ]
    } content: { files in
        ScrollView(.horizontal) {
            HStack {
                ForEach(files) { file in
                    FileThumbnailView(file: file)
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
