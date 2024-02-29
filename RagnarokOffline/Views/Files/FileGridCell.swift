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
                .lineLimit(2, reservesSpace: true)
                .font(.subheadline)
                .foregroundColor(.init(uiColor: .label))
        }
    }
}

#Preview {
    FileGridCell(file: .directory(ClientBundle.shared.url))
}
