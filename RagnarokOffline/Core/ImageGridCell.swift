//
//  ImageGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/11.
//

import SwiftUI

struct ImageGridCell<Image>: View where Image: View {
    var title: String
    var subtitle: String?
    var image: () -> Image

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                image()
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .frame(width: 80, height: 80)

            ZStack(alignment: .top) {
                // This VStack is just for reserving space.
                VStack(spacing: 2) {
                    Text(" ")
                        .lineLimit(2, reservesSpace: true)
                        .font(.body)

                    Text(" ")
                        .lineLimit(1, reservesSpace: true)
                        .font(.footnote)
                }

                VStack(spacing: 2) {
                    Text(title)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .lineLimit(2, reservesSpace: false)
                        .foregroundStyle(.primary)
                        .font(.body)

                    if let subtitle {
                        Text(subtitle)
                            .frame(maxWidth: .infinity)
                            .lineLimit(1, reservesSpace: false)
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    init(title: String, subtitle: String? = nil, @ViewBuilder image: @escaping () -> Image) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
}

#Preview {
    ImageGridCell(title: "Title", subtitle: "Subtitle") {
        Image(systemName: "folder")
            .font(.system(size: 50, weight: .light))
            .foregroundStyle(.tertiary)
    }
}
