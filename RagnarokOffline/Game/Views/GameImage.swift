//
//  GameImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/9.
//

import ROCore
import RORendering
import ROResources
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
            let components = name.split(separator: "/").map(String.init)
            let path = ResourcePath.userInterface.appending(components: components)
            image = try? await ResourceManager.default.image(at: path, removesMagentaPixels: true)
        }
    }

    init(_ name: String) {
        self.name = name
    }
}

#Preview {
    GameImage("win_msgbox.bmp")
}
