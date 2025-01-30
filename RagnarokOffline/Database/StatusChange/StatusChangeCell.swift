//
//  StatusChangeCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/1/29.
//

import SwiftUI

struct StatusChangeCell: View {
    var statusChange: ObservableStatusChange

    var body: some View {
        HStack {
            ZStack {
                if let iconImage = statusChange.iconImage {
                    Image(iconImage, scale: 1, label: Text(statusChange.displayName))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "moon.zzz")
                        .font(.system(size: 25, weight: .thin))
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(width: 40, height: 40)

            Text(statusChange.displayName)
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .task {
            try? await statusChange.fetchIconImage()
        }
    }
}
