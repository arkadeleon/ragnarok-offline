//
//  DatabaseRecordIcon.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct DatabaseRecordImage: View {
    let loader: () async -> UIImage?

    @State private var phase: AsyncImagePhase = .empty

    var body: some View {
        ZStack {
            switch phase {
            case .empty:
                EmptyView()
            case .success(let image):
                image
            case .failure(let error):
                EmptyView()
            @unknown default:
                fatalError()
            }
        }
        .task {
            if let image = await loader() {
                phase = .success(Image(uiImage: image))
            } else {
                phase = .failure(NSError())
            }
        }
    }
}

#Preview {
    DatabaseRecordImage(loader: { nil })
}
