//
//  FileThumbnailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/24.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct FileThumbnailView: View {
    let file: File

    @State private var thumbnail: UIImage?

    var body: some View {
        ZStack {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipped()
            } else {
                Image(systemName: file.iconName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color(.label))
                    .frame(width: 40, height: 40)
            }
        }
        .frame(width: 40, height: 40)
        .task {
            Task {
                let thumbnail = try await FileThumbnailManager.shared.thumbnailTask(for: file).value
                self.thumbnail = thumbnail
            }
        }
    }
}
