//
//  FileThumbnailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/11.
//

import ROFileSystem
import SwiftUI

struct FileThumbnailView: View {
    var file: ObservableFile

    @Environment(\.displayScale) private var displayScale: CGFloat

    @State private var thumbnail: FileThumbnail?

    var body: some View {
        ZStack {
            if let thumbnail {
                Image(thumbnail.cgImage, scale: displayScale, label: Text(file.file.name))
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.secondary, lineWidth: 1)
                    }
            } else if file.file.info.type == .directory {
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
            thumbnail = try? await file.fetchThumbnail(size: CGSize(width: 80, height: 80), scale: displayScale)
        }
    }
}

#Preview {
    HStack {
        FileThumbnailView(file: PreviewFiles.dataDirectory)
        FileThumbnailView(file: PreviewFiles.gatFile)
        FileThumbnailView(file: PreviewFiles.gndFile)
        FileThumbnailView(file: PreviewFiles.rswFile)
        FileThumbnailView(file: PreviewFiles.sprFile)
    }
}
