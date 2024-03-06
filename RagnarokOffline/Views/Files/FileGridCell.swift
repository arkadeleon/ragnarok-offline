//
//  FileGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/27.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct FileGridCell: View {
    let file: File

    var body: some View {
        VStack {
            FileThumbnailView(file: file)

            Text(file.name)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.primary)
                .font(.subheadline)
                .lineLimit(2)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    FileGridCell(file: .directory(ClientResourceBundle.shared.url))
}
