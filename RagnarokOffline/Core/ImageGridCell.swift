//
//  ImageGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/11.
//

import SwiftUI

struct ImageGridCell<Image>: View where Image: View {
    var title: String
    var reservesSubtitleSpace: Bool
    var subtitle: String?

    @ViewBuilder var image: () -> Image

    var body: some View {
        VStack {
            image()

            ZStack(alignment: .top) {
                // This VStack is just for reserving space.
                VStack(spacing: 2) {
                    Text(verbatim: " ")
                        .font(.body)
                        .lineLimit(2, reservesSpace: true)

                    if reservesSubtitleSpace {
                        Text(verbatim: " ")
                            .font(.footnote)
                            .lineLimit(1, reservesSpace: true)
                    }
                }

                VStack(spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2, reservesSpace: false)
                        .frame(maxWidth: .infinity)

                    if let subtitle, reservesSubtitleSpace {
                        Text(subtitle)
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                            .lineLimit(1, reservesSpace: false)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

#Preview {
    ImageGridCell(title: "Title", reservesSubtitleSpace: true, subtitle: "Subtitle") {
        Image(systemName: "folder.fill")
            .font(.system(size: 50, weight: .thin))
            .foregroundStyle(Color.accentColor)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
