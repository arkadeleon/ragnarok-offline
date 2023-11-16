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

    @State private var thumbnail: FileThumbnailRepresentation?

    var body: some View {
        Group {
            switch thumbnail {
            case .none:
                Image(uiImage: UIImage())
                    .frame(width: 40, height: 40)
            case .icon(let name):
                Image(systemName: name)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color(.label))
                    .frame(width: 40, height: 40)
            case .thumbnail(let image):
                Image(uiImage: UIImage(cgImage: image))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipped()
            }
        }
        .task {
            FileThumbnailCache.shared.generateThumbnail(for: file) { thumbnail in
                self.thumbnail = thumbnail
            }
        }
    }
}
