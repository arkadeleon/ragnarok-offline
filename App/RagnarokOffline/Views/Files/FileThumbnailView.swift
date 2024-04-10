//
//  FileThumbnailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/24.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct FileThumbnailView: View {
    @Environment(\.displayScale) var displayScale: CGFloat

    let file: File

    @State private var thumbnail: CGImage?

    var body: some View {
        ZStack {
            if let thumbnail {
                Image(thumbnail, scale: 1, label: Text(file.name))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipped()
            } else if file.isDirectory {
                Image(systemName: file.iconName)
                    .symbolRenderingMode(.multicolor)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            } else {
                Image(systemName: file.iconName)
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
                let thumbnail = try await FileThumbnailManager.shared.thumbnailTask(for: file, scale: displayScale).value
                self.thumbnail = thumbnail
            }
        }
    }
}
