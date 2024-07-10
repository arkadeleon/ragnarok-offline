//
//  FileCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/27.
//

import ROFileSystem
import SwiftUI

struct FileCell: View {
    var file: ObservableFile

    @Environment(\.displayScale) private var displayScale: CGFloat

    @State private var thumbnail: FileThumbnail?

    var body: some View {
        VStack {
            ZStack {
                if let thumbnail {
                    Image(thumbnail.cgImage, scale: displayScale, label: Text(file.file.name))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipped()
                } else if file.file.info.type == .directory {
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

            Text(file.file.name)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.primary)
                .font(.subheadline)
                .lineLimit(2, reservesSpace: true)
        }
        .task {
            do {
                thumbnail = try await file.fetchThumbnail(size: CGSize(width: 40, height: 40), scale: displayScale)
            } catch {
                print(error)
            }
        }
    }
}
