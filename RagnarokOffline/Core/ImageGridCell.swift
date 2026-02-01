//
//  ImageGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/11.
//

import SwiftUI

struct ImageGridCell<Image, Title, Subtitle>: View where Image: View, Title: View, Subtitle: View {
    var title: () -> Title
    var subtitle: () -> Subtitle
    var image: () -> Image

    private var reservesSubtitleSpace: Bool

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
                    title()
                        .font(.body)
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2, reservesSpace: false)
                        .frame(maxWidth: .infinity)

                    if reservesSubtitleSpace {
                        subtitle()
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                            .lineLimit(1, reservesSpace: false)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    init(
        title: String,
        @ViewBuilder image: @escaping () -> Image
    ) where Title == Text, Subtitle == EmptyView {
        self.title = {
            Text(title)
        }
        self.subtitle = {
            EmptyView()
        }
        self.image = image

        self.reservesSubtitleSpace = false
    }

    init(
        title: String,
        subtitle: String,
        @ViewBuilder image: @escaping () -> Image
    ) where Title == Text, Subtitle == Text {
        self.title = {
            Text(title)
        }
        self.subtitle = {
            Text(subtitle)
        }
        self.image = image

        self.reservesSubtitleSpace = true
    }

    init(
        title: String,
        @ViewBuilder subtitle: @escaping () -> Subtitle,
        @ViewBuilder image: @escaping () -> Image
    ) where Title == Text {
        self.title = {
            Text(title)
        }
        self.subtitle = subtitle
        self.image = image

        self.reservesSubtitleSpace = true
    }
}

#Preview {
    ImageGridCell(title: "Title", subtitle: "Subtitle") {
        Image(systemName: "folder.fill")
            .font(.system(size: 50, weight: .thin))
            .foregroundStyle(Color.accentColor)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
