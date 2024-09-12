//
//  GameImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/9.
//

import ROCore
import SwiftUI

struct GameImage: View {
    var name: String

    @State private var image: CGImage?

    var body: some View {
        ZStack {
            if let image {
                Image(decorative: image, scale: 1)
            }
        }
        .task {
            if let url = Bundle.module.resourceURL?.appending(path: "Images/\(name)"),
               let data = try? Data(contentsOf: url) {
                image = CGImageCreateWithData(data)?.removingMagentaPixels()
            }
        }
    }

    init(_ name: String) {
        self.name = name
    }
}

#Preview {
    GameImage("win_msgbox.bmp")
}
