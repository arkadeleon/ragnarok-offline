//
//  FileThumbnailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/24.
//

import SwiftUI
import ROFileSystem

struct FileThumbnailView: View {
    var file: ObservableFile

    @Environment(\.displayScale) private var displayScale: CGFloat
    @State private var thumbnail: CGImage?

    var body: some View {
        ZStack {
            if let thumbnail {
                Image(thumbnail, scale: 1, label: Text(file.file.name))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipped()
            } else if file.file.isDirectory {
                Image(systemName: file.file.iconName)
                    .symbolRenderingMode(.multicolor)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            } else {
                Image(systemName: file.file.iconName)
                    .symbolRenderingMode(.monochrome)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.primary)
                    .frame(width: 40, height: 40)
            }
        }
        .frame(width: 40, height: 40)
        .task {
            Task {
                let thumbnail = try await FileThumbnailManager.shared.thumbnailTask(for: file.file, scale: displayScale).value
                self.thumbnail = thumbnail
            }
        }
    }
}
